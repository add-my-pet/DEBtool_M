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
  % requires fniso_21_var_e, diso_21_var_e, sgr_iso_21_var_e (see below)

  % guess L_b
  kap_G = 0.8;                       % -, initial guess for growth efficiency
  E_G = p.MV * p.mu_V/ kap_G;        % J/cm^3, [E_G] spec cost for structure
  V_b = p.E_Hb * p.kap/ E_G/ (1 - p.kap); % cm^3, initial guess for length at birth
  L_b = V_b^(1/3);                   % cm. initial guess for length at birth
  
  % solve struc length at birth L_b
  [L_b, fn, info] = fzero(@fniso_21_var_e, L_b, [], m_E1b, m_E2b, p);
  if ~(info == 1)
    fprintf('Warning from iso_21_var_e: no convergence for L_b')
  end

  % get L_b and a_b
  LE12H_b = [L_b; m_E1b; m_E2b; p.E_Hb]; % states at birth, L_b is guessed
  options = odeset('Events',@start,'RelTol', 1e-9, 'AbsTol', 1e-9);
  [a, LE12H, a_start, LE12H_start] = ode45(@diso_21_var_e,[0,-1e3], LE12H_b, options, p);
  a_b = -a_start; % d, age at birth
  % get initial reserves
  M_E10 = p.MV * LE12H(end,1)^3 * LE12H(end,2); % mol, initial reserve 1
  M_E20 = p.MV * LE12H(end,1)^3 * LE12H(end,3); % mol, initial reserve 2
end

function F = fniso_21_var_e(L, m_E1, m_E2, p)
  % for use by fzero in iso_21_var_e: F = 0 if L(0) = 0
  % parameters p are only used to pass to diso_21_var
 
  % back-integrate back in time till L(t)=0
  options = odeset('Events',@start, 'RelTol', 1e-9, 'AbsTol', 1e-9);
  LE12H_b = [L; m_E1; m_E2; p.E_Hb]; % states at birth
  try
    [~, LE12H] = ode45(@diso_21_var_e,[0;-1e3], LE12H_b, options, p); 
    F = LE12H(end,1)-1e-3; % cm, norm
  catch % L (at birth) too low, which leads to failure of the integration near start
    F = 1; % just a value different from zero, so fzero will not select this L
  end

end

function dLE12H = diso_21_var_e(a, LE12H, p)
% ode's for iso_21_var_e:
%   derivatives of (L, m_E1, m_E2, a) with respect to time during embryo stage, used by iso_21_var_e

% unpack states
  L    = LE12H(1);                                            % cm, structural length
  m_E1 = LE12H(2);                                            % mol/mol, reserve density 1
  m_E2 = LE12H(3);                                            % mol/mol, reserve density 2
  E_H  = LE12H(4);                                            % J, maturity

%growth
[r, j_E1_M, j_E2_M, j_E1C, j_E2C, j_E1P, j_E2P] = ...         % cm/d, change in L, ..
    sgr_iso_21_var_e (m_E1, m_E2, p.j_E1M, p.j_E2M, p.mu_E1, p.mu_E2, p.mu_V, p.v/L, p.kap);
dL = r * L/ 3; 

% maturation
M_V = p.MV * L^3;                                             % mol, mass of structure
J_E1C = j_E1C * M_V; J_E2C = j_E2C * M_V;                     % mol/d, mobilisation flux
p_C = p.mu_E1 * J_E1C + p.mu_E2 * J_E2C;                      % J/d, total mobilisation
dE_H = (1 - p.kap) * p_C - p.k_J * E_H;                       % J/d, maturation

% reserve dynamics
dm_E1 = p.kap_E1 * j_E1P - m_E1 * p.v/ L;                     % mol/d.mol, change in m_E1
dm_E2 = p.kap_E2 * j_E2P - m_E2 * p.v/ L;                     % mol/d.mol, change in m_E2

dLE12H = [dL; dm_E1; dm_E2; dE_H];                            % pack output
end

function [r, j_E1_S, j_E2_S, j_E1C, j_E2C, j_E1P, j_E2P] = ...
    sgr_iso_21_var_e (m_E1, m_E2, j_E1S, j_E2S, mu_E1, mu_E2, mu_V, k_E, kap)
  % like sgr_iso_21_var, but for embryos, with mode =  1 assumed
  
  r = mu_E1 * kap * m_E1 * k_E/ (mu_V + mu_E1 * kap * m_E1);  % 1/d, specific growth rate if mode = 1
  j_E1C = (k_E - r) * m_E1; j_E2C = (k_E - r) * m_E2; % mol/d.mol mobilisation rates if mode = 1
  j_E2G = kap * j_E2C - j_E2S;   % mol/d.mol growth allocations if mode = 1
  kap_G = mu_V * r/ (mu_E1 * (kap * j_E1C - j_E1S) + mu_E2 * (kap * j_E2C - j_E2S)); % -, growth efficiency
  j_E2_S = min(kap * j_E2C, j_E2S); j_E1_S = min(kap * j_E1C, j_E1S * (1 - j_E2_S/ j_E2S)); % mol/d.mol specific som maint rates
  j_E1P = 0; j_E2P = j_E2G - r * (1/ kap_G - 1) * mu_V/ mu_E2;  % mol/d.mol, specific rejection flux
end
    
% event start development
function [value,isterminal,direction] = start(t, LE12H, r, varargin)
  value = LE12H(1) - 1e-3;  % trigger 
  isterminal = 1;   % terminate after the first event
  direction  = [];  % get all the zeros
end

