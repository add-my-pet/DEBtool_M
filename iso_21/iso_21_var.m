%% iso_21_var
% computes age and length at birth, intitial reserve of the iso_21 model

%%
function [L_b a_b M_E10 M_E20 info] = iso_21_var(m_E1b, m_E2b, p)
  % created 2012/03/06 by Bas Kooijman

  %% Syntax
  % [L_b a_b M_E10 M_E20 info] = <../iso_21_var.m *iso_21_var*> (m_E1b, m_E2b, p)

  %% Description
  % computes age and length at birth, intitial reserve of the iso_21 model
  %
  % Input:
  %
  % * m_E1b: scalar with reserve density 1 at birth (mol/mol)
  % * m_E2b: scalar with reserve density 2 at birth (mol/mol)
  % * p: 14-vector with parameters: v, kap, mu_E1, mu_E2, mu_V, j_E1M, MV, k_J, kap_G, kap_E1, kap+E2, E_Hb
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
  j_E1M     = p(6);  % mol/d.mol, specific som maint costs
  MV        = p(7);  % mol/cm^3, [M_V] density of structure                
  %k_J       = p(8);  % 1/d, mat maint rate coeff                                
  kap_G     = p(9);  % -, preference for reserve 1 to be used for som maint
  %kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
  %kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
  E_Hb      = p(12);% J, maturity threshold at birth

  % initial guess for M_E0 given m_Eb
  E_G = MV * mu_V/ kap_G;            % J/cm^3, [E_G] spec cost for structure
  V_b = E_Hb * kap/ E_G/ (1 - kap);  % cm^3, initial guess for length at birth
  M_Vb = MV * V_b;                   % mol, initial guess for structural mass at birth
  M_E1b = M_Vb * m_E1b; M_E2b = M_Vb * m_E2b; % mol, initial guess for reserve mass at birth
  L_b = V_b^(1/3);                   % cm. initial guess for langth at birth
  mu_E1V = mu_E1/ mu_V; mu_E2V = mu_E2/ mu_V; % -, ratios of mu's
  M_E1G = MV * V_b/ mu_E1V; M_E2G = (1/ kap_G - 1) * MV * V_b/ mu_E2V; % mol, cost for structure at birth
  M_E10 = M_E1b + M_E1G/ kap;        % mol, initial guess for initial reserve 1
  J_E2Mb = M_Vb * j_E1M * mu_E1/ mu_E2; % mol/d, som maint for 2 at birth
  M_E2M = 0.75 * J_E2Mb * L_b/ v;     % mol, initial guess for initial reserve 2
  M_E20 = M_E2b + (M_E2M + M_E2G)/ kap; % mol, initial guess for initial reserve 2

  % solve initial amounts of reserves
  [M_E0 fn info] = fsolve(@fniso_21_var, [M_E10; M_E20], [], m_E1b, m_E2b, p);
  info
  M_E10 = M_E0(1); M_E20 = M_E0(2);

  % get L_b and a_b
  [F L_b a_b] = fniso_21_var(M_E0, m_E1b, m_E2b, p);

% subfunction fniso_21_var

function [F L_b a_b] = fniso_21_var(M_E0, m_E1b, m_E2b, p)
% for use by fsolve in iso_21: F = 0 if M_E0 are such that m_Eb are specified values

% unpack variables
M_E10 = M_E0(1); M_E20 = M_E0(2);    % mol, initial reserve

% unpack some parameters, see diso_21_var for a full list
v         = p(1);  % cm/d, energy conductance
kap       = p(2);  % -, allocation fraction to soma
mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
mu_V      = p(5);  % J/mol, chemical potenial of structure
%j_E1M     = p(6);  % mol/d.mol, specific som maint costs
MV        = p(7);  % mol/cm^3, [M_V] density of structure                
%k_J       = p(8);  % 1/d, mat maint rate coeff                                
kap_G     = p(9);  % -, preference for reserve 1 to be used for som maint
%kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
%kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
E_Hb     = p(12);% J, maturity threshold at birth

% conditions for small age a_0 as fraction of guess value for a_b at which 
%   maintenance is not yet important and m_E0 not very large any longer
mu_E1V = mu_E1/ mu_V; mu_E2V = mu_E1/mu_V; % mol/mol
E_G = MV * mu_V/ kap_G;              % J/cm^3, [E_G] spec cost for structure
V_b = E_Hb * kap/ E_G/ (1 - kap);    % cm, initial guess for length at birth
a_b = V_b^(1/3) * 3/ v;              % d, initial guess for age at birth
a_0 = a_b/ 100;                      % d, initial age from where integration starts
L_0 = a_0 * v/ 3;                    % cm, initial structural length
M_V0 = MV * L_0^3;                   % mol, initial structural mass
y_VE1 = mu_E1V; y_VE2 = mu_E2V * kap_G/ (1 - kap_G); % mol/mol, yield coefficients
E_H0 = M_V0 * (mu_E1/ y_VE1 + mu_E2/ y_VE2) * (1 - kap)/ kap;  % J, initial maturity
m_E10 = M_E10/ M_V0 - 1/ kap/ y_VE1; % mol/mol, initial reserve density 1
m_E20 = M_E20/ M_V0 - 1/ kap/ y_VE2; % mol/mol, initial reserve density 2

[E_H LEa] = ode45(@diso_21_var,[E_H0; E_Hb], [L_0; m_E10; m_E20; a_0], [], p);
F = [m_E1b; m_E2b] - LEa(end,[2 3])'; % mol/mol, norm function set to zero

L_b = LEa(end,1); % cm, length at birth
a_b = LEa(end,4); % d, age at birth

% subfunction diso_21_var

function dLEa = diso_21_var(E_H, LEa, p)
% ode's for iso_21:
%   derivatives of (L, m_E1, m_E2, a) with respect to E_H during embryo stage, used by iso_21

% unpack parameters
v         = p(1);  % cm/d, energy conductance
kap       = p(2);  % -, allocation fraction to soma
mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
mu_V      = p(5);  % J/mol, chemical potenial of structure
j_E1M     = p(6);  % mol/d.mol, specific som maint costs
MV        = p(7);  % mol/cm^3, [M_V] density of structure                
k_J       = p(8);  % 1/d, mat maint rate coeff                                
kap_G     = p(9);  % -, preference for reserve 1 to be used for som maint
kap_E1    = p(10); % -, fraction of rejected mobilised flux that is returned to reserve
kap_E2    = p(11); % -, fraction of rejected mobilised flux that is returned to reserve
%E_Hb     = p(12);% J, maturity threshold at birth

% unpack states
L = LEa(1);                                                   % cm, structural length
m_E1 = LEa(2);                                                % mol/mol, reserve density 1
m_E2 = LEa(3);                                                % mol/mol, reserve density 2
%a = LEa(4);                                                  % d, age
M_V = MV * L^3;                                               % mol, structural mass 

%growth
j_E2M = j_E1M * mu_E1/ mu_E2;                                 % mol/d.mol, spec som maint for 2
[r, j_E1_M, j_E2_M, j_E1C, j_E2C, j_E1P, j_E2P] = ...                      % cm/d, change in L, ..
    sgr_iso_21_var (m_E1, m_E2, j_E1M, j_E2M, mu_E1, mu_E2, mu_V, v/L, kap_G, kap);
J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V; % mol/d, mobilisation flux
dL = r * L/ 3; 

% maturation
p_C = mu_E1 * J_E1C + mu_E2 * J_E2C;                          % J/d, total mobilisation
dE_H = (1 - kap) * p_C - k_J * E_H;                           % J/d, maturation

% reserve dynamics
dm_E1 = kap_E1 * j_E1P - m_E1 * v/ L;                         % mol/d.mol, change in m_E1
dm_E2 = kap_E2 * j_E2P - m_E2 * v/ L;                         % mol/d.mol, change in m_E2

dLEa = [dL; dm_E1; dm_E2; 1]/ dE_H;                           % pack output
