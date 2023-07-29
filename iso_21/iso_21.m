%% iso_21
% gets length and age at birth, intitial reserves of the 21-model

%%
function [L_b, a_b, M_E10, M_E20, info] = iso_21(m_E1b, m_E2b, p)
  % created 2011/08/06 by Bas Kooijman, modified 2023/07/29
  
  %% Syntax
  % [L_b, a_b, M_E10, M_E20, info] = <../iso_21.m *iso_21*> (m_E1b, m_E2b, p)
  
  %% Description
  % gets length and age at birth, intitial reserves of the 21-model
  
  % Input:
  %
  % * m_E1b: scalar with reserve density 1 at birth (mol/mol)
  % * m_E2b: scalar with reserve density 2 at birth (mol/mol)
  % * p: structure with parameters
  %
  % Output:
  %
  % * L_b: scalar with length at birth (cm)
  % * a_b: scalar with age at birth (d)
  % * M_E10: scalar with initial reserve 1 (mol)
  % * M_E20: scalar with initial reserve 2 (mol)
  % * info: indicator for failure (0) or success (1)
  
  %% Remarks
  % requires fniso_21, diso_21 (see below) and gr_iso_21

  % initial guess for M_E0 given m_Eb
  V_b = p.E_Hb * p.kap/ p.E_G/ (1 - p.kap);  % cm^3, initial guess for struc vol at birth
  M_Vb = p.MV * V_b;                   % mol,initial guess for mass at birth
  a_b = V_b^(1/3) * 3/ p.v;            % d, initial gues for age at birth
  M_E10 = M_Vb * (m_E1b + 1/ p.y_VE1/ p.kap); % mol, initial guess for initial reserve 1
  j_E2M = p.j_E1M * p.mu_E1/ p.mu_E2;      % mol/d.mol, spec som maint for 2
  M_E20 = M_Vb * (m_E2b + (1/ p.y_VE2 + j_E2M * a_b)/ p.kap); % mol, initial guess for initial reserve 2

  M_E0 = fsolve(@fniso_21, [M_E10; M_E20], [], m_E1b, m_E2b, p);
  [M_E0, fn, info] = fsolve(@fniso_21, M_E0, [], m_E1b, m_E2b, p);
  if ~info; fprintf('Warning from iso_21: fsolve did not converge to the initial reserves'); end

  [F, L_b] = fniso_21(M_E0, m_E1b, m_E2b, p);
  M_E10 = M_E0(1); M_E20 = M_E0(2);
end

function [F, L_b] = fniso_21(M_E0, m_E1b, m_E2b, p)
  % for use by fsolve in iso_21: F = 0 if M_E0 are such that m_Eb are specified values

  LE12H_0 = [1e-4; M_E0(1); M_E0(2); 0]; % states at birth
  options = odeset('Events',@birth, 'RelTol',1e-9, 'AbsTol',1e-9);

  [a, LE12H, a_b, LE12H_b] = ode45(@diso_21,[0; 1e3], LE12H_0, options, p);
  %LE12H_b = LE12H(end,:); % just for security with evert is not reached
  L_b = LE12H_b(1); M_Vb = L_b^3 * p.MV; % cm, mol, structural length, mass at birth
  F = [m_E1b; m_E2b] - LE12H_b([2 3])'/M_Vb; % mol/mol, norm function set to zero

end

function dLE12H = diso_21(a, LE12H, p)
  % ode's for iso_21:
  %   derivatives of (L, M_E1, M_E2, E_H) with respect to age during embryo stage, used by iso_21

  % unpack states
  L = LE12H(1);                                   % cm, structural length
  M_E1 = LE12H(2);                                % mol, reserve 1
  M_E2 = LE12H(3);                                % mol, reserve 2
  E_H = LE12H(4);                                 % J, maturity
  M_V = p.MV * L^3;                               % mol, structural mass 
  m_E1 = M_E1/ M_V; m_E2 = M_E2/ M_V;             % mol/mol, reserve density 1,2

  %growth
  j_E2M = p.j_E1M * p.mu_E1/ p.mu_E2;             % mol/d.mol, spec som maint for 2
  [dL, j_E1_M, j_E2_M, j_E1C, j_E2C] = ...        % cm/d, change in L, ..
    gr_iso_21 (L, m_E1, m_E2, p.j_E1M, j_E2M, p.y_VE1, p.y_VE2, p.v, p.kap, p.rho1);
  J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V;       % mol/d, mobilisation flux
  r = 3 * dL/ L;                                  % 1/d, spec growth rate

  % maturation
  p_C = p.mu_E1 * J_E1C + p.mu_E2 * J_E2C;        % J/d, total mobilisation
  dE_H = (1 - p.kap) * p_C - p.k_J * E_H;         % J/d, maturation

  % reserve dynamics
  j_E1P = p.kap * j_E1C - j_E1_M - r/ p.y_VE1;    % mol/d.mol, rejected flux 1 from growth SU's
  j_E2P = p.kap * j_E2C - j_E2_M - r/ p.y_VE2;    % mol/d.mol, rejected flux 2 from growth SU's
  dm_E1 = p.kap_E1 * j_E1P - m_E1 * p.v/ L;       % mol/d.mol, change in m_E1
  dm_E2 = p.kap_E2 * j_E2P - m_E2 * p.v/ L;       % mol/d.mol, change in m_E2
  dM_E1 = M_V * (dm_E1 + m_E1 * r);               % mol/d, change in M_E1
  dM_E2 = M_V * (dm_E2 + m_E2 * r);               % mol/d, change in M_E2

  dLE12H = [dL; dM_E1; dM_E2; dE_H];              % pack output
end 

% event birth
function [value,isterminal,direction] = birth(a, LE12H, p)
  value = LE12H(4) - p.E_Hb;  % trigger E_H(a_b) = E_Hb
  isterminal = 1;   % terminate after the first event
  direction  = [];  % get all the zeros
end
