%% iso_21_var_e
% computes age and length at birth, intitial reserve of the iso_21 model
% created by Bas kooijman, modified 2023/07/16

%%
function [L_b, a_b, M_E10, M_E20, info] = iso_21_var_e(m_E1b, m_E2b, p)
  % created 2012/03/06 by Bas Kooijman

  %% Syntax
  % [L_b, a_b, M_E10, M_E20, info] = <../iso_21_var.m *iso_21_var*> (m_E1b, m_E2b, p)

  %% Description
  % computes age and length at birth, intitial reserve of the iso_21 model
  %
  % Input:
  %
  % * m_E1b: scalar with reserve density 1 at birth (mol/mol)
  % * m_E2b: scalar with reserve density 2 at birth (mol/mol)
  % * p: 12-vector with parameters: v, kap, mu_E1, mu_E2, mu_V, j_E1M, j_E2M, MV, k_J, kap_E1, kap_E2, E_Hb
  %
  % Output:
  %
  % * L_b: scalar with length at birth (cm)
  % * a_b: scalar with age at birth (d)
  % * M_E10: scalar with initial reserve 1 (mol)
  % * M_E20: scalar with initial reserve 2 (mol)
  % * info: indicator for failure (0) or success (1)
  
  %% Remarks
  % requires fniso_21_var, diso_21_var (see below)

  % unpack some parameters, see diso_21_var for a full list
  v         = p(1);  % cm/d, energy conductance
  kap       = p(2);  % -, allocation fraction to soma
  mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
  mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
  mu_V      = p(5);  % J/mol, chemical potenial of structure
  MV        = p(6);  % mol/cm^3, [M_V] density of structure                
  j_E1M     = p(7);  % mol/d.mol, specific som maint costs
  j_E2M     = p(8);  % mol/d.mol, specific som maint costs
  k_J       = p(9);  % 1/d, mat maint rate coeff                                
  kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
  kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
  E_Hb      = p(12);% J, maturity threshold at birth

  % initial guess for M_E0 given m_Eb
  kap_G = 0.8;                       % -, initial guess for growth efficiency
  E_G = MV * mu_V/ kap_G;            % J/cm^3, [E_G] spec cost for structure
  V_b = E_Hb * kap/ E_G/ (1 - kap);  % cm^3, initial guess for length at birth
  M_Vb = MV * V_b;                   % mol, initial guess for structural mass at birth
  M_E1b = M_Vb * m_E1b; M_E2b = M_Vb * m_E2b; % mol, initial guess for reserve mass at birth
  L_b = V_b^(1/3);                   % cm. initial guess for langth at birth
  mu_E1V = mu_E1/ mu_V; mu_E2V = mu_E2/ mu_V; % -, ratios of mu's
  M_E1G = MV * V_b/ mu_E1V; M_E2G = (1/ kap_G - 1) * MV * V_b/ mu_E2V; % mol, cost for structure at birth
  M_E10 = M_E1b + M_E1G/ kap;        % mol, initial guess for initial reserve 1
  J_E2Mb = M_Vb * j_E2M;             % mol/d, som maint for 2 at birth
  M_E2M = 0.75 * J_E2Mb * L_b/ v;     % mol, initial guess for initial reserve 2
  M_E20 = M_E2b + (M_E2M + M_E2G)/ kap; % mol, initial guess for initial reserve 2

  % solve initial amounts of reserves
  [L_b, fn, info] = fzero(@fniso_21_var, [.01 100], [], m_E1b, m_E2b, p);

  % get L_b and a_b
  [F, L_b, a_b] = fniso_21_var(L_b, m_E1b, m_E2b, p);

end
% subfunction fniso_21_var

function [F, L_b, a_b] = fniso_21_var(L, m_E1b, m_E2b, p)
  % for use by fsolve in iso_21: F = 0 if L(0) = 0

  % unpack parameters
  v         = p(1);  % cm/d, energy conductance
  kap       = p(2);  % -, allocation fraction to soma
  mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
  mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
  mu_V      = p(5);  % J/mol, chemical potenial of structure
  MV        = p(6);  % mol/cm^3, [M_V] density of structure                
  j_E1M     = p(7);  % mol/d.mol, specific som maint costs
  j_E2M     = p(8);  % mol/d.mol, specific som maint costs
  k_J       = p(9);  % 1/d, mat maint rate coeff                                
  kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
  kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
  E_Hb      = p(12);% J, maturity threshold at birth

  % struc mass, reserve at birth
  M_b = MV * L^3; % mol, struc mass at birth
  M_E1b = m_E1b * M_b; M_E2b = m_E2b * M_b; % mol, reserve 

  % back-integrate back in E_H 
  LE12a_b = [L; M_E1b; M_E2b; 0]; % states at birth
  [E_H, LE12a] = ode23(@diso_21_var,[E_Hb;0], LE12a_b, [], p);

  % complete outputs
  L_b = LE12a(1,1); % cm, length at birth
  a_b = -LE12a(end,4); % d, age at birth

  F = LE12a(end,1); % cm, initial length
end

% subfunction diso_21_var

function dLE12a = diso_21_var(E_H, LE12a, p)
% ode's for iso_21:
%   derivatives of (L, m_E1, m_E2, a) with respect to maturity during embryo stage, used by iso_21

% unpack parameters
  v         = p(1);  % cm/d, energy conductance
  kap       = p(2);  % -, allocation fraction to soma
  mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
  mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
  mu_V      = p(5);  % J/mol, chemical potenial of structure
  MV        = p(6);  % mol/cm^3, [M_V] density of structure                
  j_E1M     = p(6);  % mol/d.mol, specific som maint costs
  j_E2M     = p(8);  % mol/d.mol, specific som maint costs
  k_J       = p(9);  % 1/d, mat maint rate coeff                                
  kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
  kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
  %E_Hb      = p(12);% J, maturity threshold at birth

% unpack states
L = LE12a(1);                                                   % cm, structural length
M_E1 = LE12a(2);                                                % mol/mol, reserve density 1
M_E2 = LE12a(3);                                                % mol/mol, reserve density 2
a = LE12a(4);                                                   % d, age
%
M_V = MV * L^3;                                               % mol, mass of structure
m_E1 = M_E1/ M_V; m_E2 = M_E2/ M_V;                           % mol/mol, reserve densities

%growth
[r, j_E1_M, j_E2_M, j_E1C, j_E2C, j_E1P, j_E2P] = ...                      % cm/d, change in L, ..
    sgr_iso_21_var (m_E1, m_E2, j_E1M, j_E2M, mu_E1, mu_E2, mu_V, v/L, kap);
J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V; % mol/d, mobilisation flux
dL = r * L/ 3; 

% maturation
p_C = mu_E1 * J_E1C + mu_E2 * J_E2C;                          % J/d, total mobilisation
dE_H = (1 - kap) * p_C - k_J * E_H;                           % J/d, maturation

% reserve dynamics
dm_E1 = kap_E1 * j_E1P - m_E1 * v/ L;                         % mol/d.mol, change in m_E1
dM_E1 = M_V * (r * m_E1 + dm_E1);                             % mol/d, change in M_E1
dm_E2 = kap_E2 * j_E2P - m_E2 * v/ L;                         % mol/d.mol, change in m_E2
dM_E2 = M_V * (r * m_E2 + dm_E2);                             % mol/d, change in M_E2

dLE12a = [dL; dM_E1; dM_E2; 1]/ dE_H;                         % pack output
end

