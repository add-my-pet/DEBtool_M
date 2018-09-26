%% dstate_std
% Gets changes in state of the std-model and in/output fluxes

%%
function [dstate, flux] = dstate_std(t, state, par, T, f)
  % created 2018/09/10 by Bas Kooijman
  
  %% Syntax
  % [dstate, flux] = <../dstate_std.m *dstate_std*> (t, state, par, T, f)
  
  %% Description
  % Gets changes in state of the std-model and in/output fluxes
  %
  % Input
  %
  % * t: scalar with time
  % * state: 6-vector with state values: L, E, E_R, E_H, q, h_A
  % * par: structure with parameters: Tpars
  % * T: scalar with temperature
  % * f: scalar with scaled functional response
  %
  % Output
  %
  % * dstate: 6-vector with changes in state
  % * flux: 8-vector with in/output fluxes: J_X, J_P, J_ER, J_C, J_O, J_H, J_N, p_T
  
  %% Remarks
  % to think about: buffer handling rules
  % meant to be used in ibm's
  
  vars_pull(par); % unpack par
  TC = tempcorr(spline1(t, tT), C2K(20), Tpars); % -, temp correction factor
  f = spline1(t, tf);                            % - , scaled func response
  
  % unpack state
  L = state(1);   % cm, struc length 
  E = state(2);   % J/cm^3, [E] reserve density
  E_R = state(3); % J, reprod buffer
  E_H = min(E_Hp, state(4)); % J, maturity
  q = state(5);   % 1/d^2, damage-compound accel 
  h_A = state(6); % 1/d, hazard rate
  
  
  % help quantities
  % mass-energy coupling
  kap_G = mu_V * M_V/ E_G;                    % -, growth efficiency
  eta_O = [-1/kap_X/mu_X 0 0; 0 0 kap_G/ mu_V; 1/mu_E, -1/mu_E, -1/mu_E; kap_P/ kap_X/ mu_P, 0 0]; % mass-energy coupler
  %
  % powers
  pT_A = TC * (E_H > E_Hb) * f * p_Am * L^2;  % J/d, assimilation
  pT_S = TC * (p_M * L^3 + (E_H > E_Hb) * p_T * L^2); % J/d, som maint
  if E > p_S * L/ v/ kap % positive growth
    r = (E * v/ L - p_S/ kap/ L^3)/ (E + E_G/ kap); % 1/d, spec growth rate
  elseif E_R > 0 % maintenance paid from E_R
    r = 0;                                    % 1/d, spec growth rate
  else % shrinking
    r = (E * v/ L - p_S/ kap/ L^3)/ (E + E_G * kap_G/ kap); % 1/d, spec growth rate
  end
  pT_C = TC * E * L^3 * (v/ L - r);           % J/d, mobilisation
  if (1 - kap) * pT_C >= TC * k_T * E_H % positive maturation/reprod investment
    pT_J = TC * k_J * E_H;                    % J/d, mat maint
  else % rejuvenation
    pT_J = TC * kprime_J * E_H;               % J/d, mat maint
  end
  pT_R = (1 - kap) * pT_C - pT_J;             % J/d, maturation/ reprod allocation
  if E_H < E_Hp
    pT_D = pT_S + pT_J + pT_R;                % J/d, dissipation
  else
    pT_D = pT_S + pT_J + (1 - kap_R) * pT_R;  % J/d, dissipation
  end
  pT_G = kap * pT_C - pT_S;                   % J/d, growth allocation
  if pT_G < 0 && E_R > 0
    pT_G = 0;                                 % J/d, growth allocation
  end
  
  % changes in state
  dL = L * r/3;                               % cm/d, change in structural length
  if E_H < E_Hb
    dE = - TC * E * v/ L;                     % J/d.cm^3, change in reserve density
  else
    dE = TC * (f * p_Am - E * v)/ L;          % J/d.cm^3, change in reserve density
  end
  if E_H < E_Hp
    dE_H = (1 - kap) * pT_C - pT_J;           % J/d, change in maturity
  elseif E_R <- 0
    dE_H = - TC * kprime_J * (E_H - (1 - kap) * pT_C/ k_J/ TC); % J/d, change in maturity
  else
    dE_H = 0;                                 % J/d, change in maturity
  end
    
  

  dstate = [dL; dE; dE_R; dE_H; dq; dh_A];          % pack dstate
  flux = [J_X; J_P; J_ER; J_C; J_O; J_H; J_N; p_tot]; % pack flux 