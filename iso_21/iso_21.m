%% iso_21
% gets length and age at birth, intitial reserves of the 21-model

%%
function [L_b a_b M_E10 M_E20 info] = iso_21(m_E1b, m_E2b, p)
  % created 2011/08/06 by Bas Kooijman
  
  %% Syntax
  % [L_b a_b M_E10 M_E20 info] = <../iso_21.m *iso_21*> (m_E1b, m_E2b, p)
  
  %% Description
  % gets length and age at birth, intitial reserves of the 21-model
  
  % Input:
  %
  % * m_E1b: scalar with reserve density 1 at birth (mol/mol)
  % * m_E2b: scalar with reserve density 2 at birth (mol/mol)
  % * p: 14-vector with parameters
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

  % unpack some parameters, see diso_21 for a full list
  v         = p(1);  % cm/d, energy conductance
  kap       = p(2);  % -, allocation fraction to soma
  mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
  mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
  mu_V      = p(5);  % J/mol, chemical potenial of structure
  j_E1M     = p(6);  % mol/d.mol, specific som maint costs
  MV        = p(7);  % mol/cm^3, [M_V] density of structure                
  y_VE1     = p(10); % mol/mol, yield of structure on reserve 1
  y_VE2     = p(11); % mol/mol, yield of structure on reserve 2 
  E_Hb      = p(14); % J, maturity threshold at birth

  % initial guess for M_E0 given m_Eb
  kap_G = mu_V/ (mu_E1 * y_VE1 + mu_E2 * y_VE2); % -, growth efficiency
  E_G = MV * mu_V/ kap_G;            % J/cm^3, [E_G] spec cost for structure
  V_b = E_Hb * kap/ E_G/ (1 - kap);  % cm, initial guess for length at birth
  M_Vb = MV * V_b;                   % mol,initial guess for mass at birth
  a_b = V_b^(1/3) * 3/ v;            % d, initial gues for age at birth
  M_E10 = M_Vb * (m_E1b + 1/ y_VE1/ kap); % mol, initial guess for initial reserve 1
  j_E2M = j_E1M * mu_E1/ mu_E2;      % mol/d.mol, spec som maint for 2
  M_E20 = M_Vb * (m_E2b + (1/ y_VE2 + j_E2M * a_b)/ kap); % mol, initial guess for initial reserve 2

  [M_E0 fn info] = fsolve(@fniso_21, [M_E10; M_E20], [], m_E1b, m_E2b, p);

  [F L_b a_b] = fniso_21(M_E0, m_E1b, m_E2b, p);
  M_E10 = M_E0(1); M_E20 = M_E0(2);

% subfunction fniso_21

function [F L_b a_b] = fniso_21(M_E0, m_E1b, m_E2b, p)
% for use by fsolve in iso_21: F = 0 if M_E0 are such that m_Eb are specified values

% unpack variables
M_E10 = M_E0(1); M_E20 = M_E0(2);    % mol, initial reserve

% unpack some parameters, see diso_21 for a full list
v         = p(1);  % cm/d, energy conductance
kap       = p(2);  % -, allocation fraction to soma
mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
mu_V      = p(5);  % J/mol, chemical potenial of structure
j_E1M     = p(6);  % mol/d.mol, specific som maint costs
MV        = p(7);  % mol/cm^3, [M_V] density of structure                
rho1      = p(9);  % -, preference for reserve 1 to be used for som maint
y_VE1     = p(10); % mol/mol, yield of structure on reserve 1
y_VE2     = p(11); % mol/mol, yield of structure on reserve 2 
E_Hb      = p(14); % J, maturity at birth

% conditions for small age a_0 as fraction of guess value for a_b at which 
%   maintenance is not yet important and m_E0 not very large any longer
kap_G = mu_V/ (mu_E1 * y_VE1 + mu_E2 * y_VE2); % -, growth efficiency
E_G = MV * mu_V/ kap_G;              % J/cm^3, [E_G] spec cost for structure
V_b = E_Hb * kap/ E_G/ (1 - kap);    % cm, initial guess for length at birth
a_b = V_b^(1/3) * 3/ v;              % d, initial gues for age at birth
a_0 = a_b/ 100;                      % d, initial age from where integration starts
L_0 = a_0 * v/ 3;                    % cm, initial structural length
M_V0 = MV * L_0^3;                   % mol, initial structural mass
E_H0 = M_V0 * (mu_E1/ y_VE1 + mu_E2/ y_VE2) * (1 - kap)/ kap;  % J, initial maturity
m_E10 = M_E10/ M_V0 - 1/ kap/ y_VE1; % mol/mol, initial reserve density 1
m_E20 = M_E20/ M_V0 - 1/ kap/ y_VE2; % mol/mol, initial reserve density 2

% initialise v_H in gr_iso_21, by call with v_B_0 = []; gr_iso_21 continuates
j_E2M = j_E1M * mu_E1/ mu_E2;        % mol/d.mol, spec som maint for 2
[dL, j_E1_M, j_E2_M, j_E1C, j_E2C, info] = gr_iso_21(L_0, m_E10, m_E20, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1, []); % cm/d, change in L, ..
if info == 0
  fprintf('warning in fniso_21: initiaton of growth rate failed \n')
end
if (v/3 - dL) > 1e-4
  fprintf('warning in fniso_21: initial age is too large \n')
end

[E_H LEa] = ode45(@diso_21,[E_H0; E_Hb], [L_0; m_E10; m_E20; a_0], [], p);
F = [m_E1b; m_E2b] - LEa(end,[2 3])';% mol/mol, norm function set to zero

L_b = LEa(end,1); % cm, length at birth
a_b = LEa(end,4); % d, age at birth

% subfunction diso_21

function dLEa = diso_21(E_H, LEa, p)
% ode's for iso_21:
%   derivatives of (L, m_E1, m_E2, a) with respect to E_H during embryo stage, used by iso_21

% unpack parameters
v         = p(1);  % cm/d, energy conductance
kap       = p(2);  % -, allocation fraction to soma
mu_E1     = p(3);  % J/mol, chemical potential of reserve 1
mu_E2     = p(4);  % J/mol, chemical potential of reserve 2
%mu_V     = p(5);  % J/mol, chemical potenial of structure
j_E1M     = p(6);  % mol/d.mol, specific som maint costs
MV        = p(7);  % mol/cm^3, [M_V] density of structure                
k_J       = p(8);  % 1/d, mat maint rate coeff                                
rho1      = p(9);  % -, preference for reserve 1 to be used for som maint
y_VE1     = p(10); % mol/mol, yield of structure on reserve 1
y_VE2     = p(11); % mol/mol, yield of structure on reserve 2 
kap_E1    = p(12); % -, fraction of rejected mobilised flux that is returned to reserve
kap_E2    = p(13); % -, fraction of rejected mobilised flux that is returned to reserve
%E_Hb     = p(14);% J, maturity threshold at birth

% unpack states
L = LEa(1);                                                   % cm, structural length
m_E1 = LEa(2);                                                % mol/mol, reserve density 1
m_E2 = LEa(3);                                                % mol/mol, reserve density 2
%a = LEa(4);                                                  % d, age
M_V = MV * L^3;                                               % mol, structural mass 

%growth
j_E2M = j_E1M * mu_E1/ mu_E2;                                 % mol/d.mol, spec som maint for 2
[dL, j_E1_M, j_E2_M, j_E1C, j_E2C] = ...                      % cm/d, change in L, ..
    gr_iso_21 (L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1);
J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V;                     % mol/d, mobilisation flux
r = 3 * dL/ L;                                                % 1/d, spec growth rate

% maturation
p_C = mu_E1 * J_E1C + mu_E2 * J_E2C;                          % J/d, total mobilisation
dE_H = (1 - kap) * p_C - k_J * E_H;                           % J/d, maturation

% reserve dynamics
j_E1P = kap * j_E1C - j_E1_M - r/ y_VE1;                      % mol/d.mol, rejected flux 1 from growth SU's
j_E2P = kap * j_E2C - j_E2_M - r/ y_VE2;                      % mol/d.mol, rejected flux 2 from growth SU's
dm_E1 = kap_E1 * j_E1P - m_E1 * v/ L;                         % mol/d.mol, change in m_E1
dm_E2 = kap_E2 * j_E2P - m_E2 * v/ L;                         % mol/d.mol, change in m_E2

dLEa = [dL; dm_E1; dm_E2; 1]/ dE_H;                           % pack output
