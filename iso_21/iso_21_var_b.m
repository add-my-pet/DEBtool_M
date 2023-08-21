%% iso_21_var_b
% computes age and length at birth, initial reserve of the iso_21_var model

%%
function [L_b, a_b, M_E10, M_E20, info] = iso_21_var_b(m_E1b, m_E2b, p)
  % created 2012/03/06 by Bas Kooijman, modified 2023/07/16

  %% Syntax
  % [L_b, a_b, M_E10, M_E20, info] = <../iso_21_var_b.m *iso_21_var_b*> (m_E1b, m_E2b, p)

  %% Description
  % computes age and length at birth, initial reserves of the iso_21_var model
  %
  % Input:
  %
  % * m_E1b: scalar with reserve density 1 at birth (mol/mol)
  % * m_E2b: scalar with reserve density 2 at birth (mol/mol)
  % * p: structure with parameters, see mydata_iso_221_var
  %
  % Output:
  %
  % * L_b: scalar with length at birth (cm)
  % * a_b: scalar with age at birth (d)
  % * M_E10: scalar with initial reserve 1 (mol)
  % * M_E20: scalar with initial reserve 2 (mol)
  % * info: indicator for failure (0) or success (1)
  
  %% Remarks
  % requires fniso_21_var_b, diso_21_var_b, sgr_iso_21_var_b (see below)
  
  %  guess for M_E0 given m_Eb
  E_G = 2 * (p.y_VE1 * p.mu_E1 + p.y_VE2 * p.mu_E2) * p.MV; % J/cm^3, guess for spec cost for structure
  % fuzz factor 2 roughly accounts for maintenance costs during embryo period
  V_b = p.E_Hb * p.kap/ E_G/ (1 - p.kap); % cm^3, guess for struc vol at birth
  M_Vb = p.MV * V_b; % mol, guess for mass at birth
  M_E10 = M_Vb * (m_E1b + 1/ p.y_VE1/ p.kap); % mol, guess for initial reserve 1
  M_E20 = M_Vb * (m_E2b + 1/ p.y_VE2/ p.kap); % mol, guess for initial reserve 2
  M_E0 = [M_E10; M_E20]; % mol, guess for initial reserves
  
  % get states: at initial and at birth 
  M_E0 = fsolve(@fniso_21_var_b, M_E0, [], m_E1b, m_E2b, p); % mol, initial reserves
  [M_E0, fn, info] = fsolve(@fniso_21_var_b, M_E0, [], m_E1b, m_E2b, p); % continuate and assign output
  if ~info; fprintf('Warning from iso_21_var_b: fsolve did not converge to the initial reserves'); end
  M_E10 = M_E0(1); M_E20 = M_E0(2); % assign output
  [~, L_b, a_b] = fniso_21_var_b(M_E0, m_E1b, m_E2b, p); % cm, d, length and age at birth
      
end

function [F, L_b, a_b] = fniso_21_var_b(M_E0, m_E1b, m_E2b, p)
  % for use by fsolve in iso_21_var_b: F = 0 if M_E0 are such that m_Eb are specified values

  LE12H_0 = [1e-3; M_E0(1); M_E0(2); 0]; % states at birth
  %options = odeset('Events',@birth, 'RelTol',1e-9, 'AbsTol',1e-9);
  options = odeset('Events',@birth); % default accuracy because of mode-switching in sgr_21_var
  [a, LE12H, a_b, LE12H_b] = ode45(@diso_21_var_b,[0; 1e3], LE12H_0, options, p);
  LE12H_b = LE12H(end,:); a_b = a(end); % just in case event b is not reached
  L_b = LE12H_b(1); M_Vb = L_b^3 * p.MV; % cm, mol, structural length, mass at birth
  F = [m_E1b; m_E2b] - LE12H_b([2 3])'/M_Vb; % mol/mol, norm function set to zero
end

function dLE12H = diso_21_var_b(a, LE12H, p)
  % ode's for iso_21_var_b:
  %   derivatives of (L, m_E1, m_E2, a) with respect to time during embryo stage, used by iso_21_var_b

  % unpack states
  L    = LE12H(1); % cm, structural length
  M_E1 = LE12H(2); % mol, reserve mass 1
  M_E2 = LE12H(3); % mol, reserve mass 2
  E_H  = LE12H(4); % J, maturity
  M_V = L^3 * p.MV;% mol, structural mass
  m_E1 = M_E1/ M_V; m_E2 = M_E2/ M_V; % mol/mol reserve densities

  %growth
  [r, j_E1_M, j_E2_M, j_E1C, j_E2C, j_E1P, j_E2P] = ...         % 1/d, spec growth rate, notice k_E = v/L      
    sgr_iso_21_var (m_E1, m_E2, p.j_E1M, p.j_E2M, p.mu_E1, p.mu_E2, p.mu_V, p.v/L, p.kap, p.y_VE1);
  dL = r * L/ 3;                                                % cm/d, change in L, ..

  % maturation
  J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V;                     % mol/d, mobilisation flux
  p_C = p.mu_E1 * J_E1C + p.mu_E2 * J_E2C;                      % J/d, total mobilisation
  dE_H = (1 - p.kap) * p_C - p.k_J * E_H;                       % J/d, maturation

  % reserve dynamics
  dm_E1 = p.kap_E1 * j_E1P - m_E1 * p.v/ L;                     % mol/d.mol, change in m_E1
  dm_E2 = p.kap_E2 * j_E2P - m_E2 * p.v/ L;                     % mol/d.mol, change in m_E2
  dM_E1 = M_V * (dm_E1 + r * m_E1);                             % mol/d, chnage in M_E1
  dM_E2 = M_V * (dm_E2 + r * m_E2);                             % mol/d, chnage in M_E2

  dLE12H = [dL; dM_E1; dM_E2; dE_H];                            % pack output
end

% event birth
function [value,isterminal,direction] = birth(t, LE12H, p)
  value = LE12H(4) - p.E_Hb;  % trigger E_H(a_b) = E_Hb
  isterminal = 1;   % terminate after the first event
  direction  = [];  % get all the zeros
end
