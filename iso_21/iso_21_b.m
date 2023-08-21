%% iso_21_b
% gets values of variables at birth and initial reserves

%%
function [var_b, a_b, M_E10, M_E20] = iso_21_b(p)

  %% Syntax
  % [var_b, a_b, M_E10, M_E20] = <../iso_21_b.m *iso_21_b*> (p)

  %% Description
  % gets values of variables at birth and initial reserves
  % assumptions: no aging during embryo stage; reserves of mother are maximally filled
  %
  % Input:
  %
  % * p: structure with parameters, see diso_211 for a full list
  %
  % Output:
  %
  % * var_b: 13-vector with state variables 
  %      cM_X1, cM_X2, M_E1, M_E2, E_H, max_E_H, M_V, max_M_V, cM_ER1, cM_ER2, q, h,  S
  % * a_b: scalar with age at birth at T_ref
  % * M_E10, M_E20: scalars with initial reserves

  % reserve density at birth m_Eb
  J_E1Am_X1 = p.y_E1X1 * p.J_X1Am; J_E2Am_X1 = p.y_E2X1 * p.J_X1Am;     % mol/d, max assim rate
  J_E1Am_X2 = p.y_E1X2 * p.J_X2Am; J_E2Am_X2 = p.y_E2X2 * p.J_X2Am;     % mol/d, max assim rate
  m_E1b = max(J_E1Am_X1/ p.v/ p.MV, J_E1Am_X2/ p.v/ p.MV);    % mol/mol, reserve density 1 at birth
  m_E2b = max(J_E2Am_X1/ p.v/ p.MV, J_E2Am_X2/ p.v/ p.MV);    % mol/mol, reserve density 2 at birth
  
  % guess for M_E0 given m_Eb
  E_G = 2 * (p.y_VE1 * p.mu_E1 + p.y_VE2 * p.mu_E2) * p.MV; % J/cm^3, guess for spec cost for structure
  % fuzz factor 2 roughly accounts for maintenance costs during embryo period
  V_b = p.E_Hb * p.kap/ (1 - p.kap)/ E_G; % cm^3, guess for struc vol at birth, see DEB3 Eq (2.32)
  M_Vb = p.MV * V_b; % mol, initial guess for mass at birth
  M_E10 = M_Vb * (1 + 1/ p.y_VE1/ (m_E1b + m_E2b)) * m_E1b; % mol, guess for initial reserve 1
  M_E20 = M_Vb * (1 + 1/ p.y_VE2/ (m_E1b + m_E2b)) * m_E2b; % mol, guess for initial reserve 2
  M_E0 = [M_E10; M_E20]; % mol, guess for initial reserves

  % get states: initial and at birth 
  M_E0 = fsolve(@fniso_21, M_E0, [], m_E1b, m_E2b, p); % mol, initial reserves
  [M_E0, fn, info] = fsolve(@fniso_21, M_E0, [], m_E1b, m_E2b, p); % continuate and assign output
  if ~info; fprintf('Warning from iso_21_b: fsolve did not converge to the initial reserves\n'); end
  M_E10 = M_E0(1); M_E20 = M_E0(2); % assign output
  [~, L_b, a_b] = fniso_21(M_E0, m_E1b, m_E2b, p); % cm, d, length and age at birth
  M_Vb = p.MV * L_b^3; M_E1b = m_E1b * M_Vb; M_E2b = m_E2b * M_Vb; % mol, masses at birth

  % compose variables at birth
  %        1     2       3       4      5      6     7      8      9      10     11 12 13
  %      cM_X1  cM_X2  M_E1    M_E2    E_H  max_E_H M_V  max_M_V cM_ER1  cM_ER2   q  h  S
  var_b = [0,    0,   M_E1b,  M_E2b,  p.E_Hb,  p.E_Hb, M_Vb,  M_Vb,    0,      0,     0  0  1]; % mol, 
end

function [F, L_b, a_b] = fniso_21(M_E0, m_E1b, m_E2b, p)
  % for use by fsolve in iso_21: F = 0 if M_E0 are such that m_Eb are specified values

  LE12H_0 = [1e-4; M_E0(1); M_E0(2); 0]; % states at birth
  options = odeset('Events',@birth, 'RelTol',1e-9, 'AbsTol',1e-9);

  [a, LE12H, a_b, LE12H_b] = ode45(@diso_21,[0; 1e3], LE12H_0, options, p);
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
  [dL, j_E1_M, j_E2_M, j_E1C, j_E2C] = ...        % cm/d, change in L, ..
    gr_iso_21 (L, m_E1, m_E2, p.j_E1M, p.j_E2M, p.y_VE1, p.y_VE2, p.v, p.kap, p.rho1);
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
