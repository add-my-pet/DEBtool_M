%% get_ael
% Gets age, reserve and length at birth

%%
function [aEL E0 lb] = get_ael(par, F)
  % created by Bas Kooijman at 2006/08/28, modified 2009/02/13
  
  %% Syntax
  % [aEL E0 lb] = <../get_ael.m *get_ael*> (par, F)
  
  %% Description
  %  Obtains state variables at age zero and at birth from parameters and scaled reserve density at birth. 
  %
  % Input
  %
  % * par: 8-vector with parameters: 
  %
  %    1 {J_EAm},  mol/d.cm^2, max spec assimilation rate
  %    2 kap, -, allocation fraction to soma
  %    3 v, cm/d, energy conductance
  %    4 [J_EM], mol/d.cm^3 spec somatic maintenance
  %    5 k_J, 1/d, maturity maintenance rate coefficient
  %    6 y_VE, mol/mol, yiles of structure on reserve
  %    7 M_H^b, d.cm^2, scaled maturity at birth
  %    8 [M_V], mol/cm^3, vol-spec mass of structure
  %
  % * F: n-vector with scaled functional responses  
  %  
  % Output
  %
  % * aEL: (n,3)-matrix with a_b, M_E^b, L_b
  % * E0: n-vector with M_E^0
  % * lb: n-vector with L_b/ L_m
  
  %% Remarks
  % The output values are numerically obtained, starting from the values for a foetus; 
  %  the age at birth of this foetus must again be obtained numerically, 
  %  which is done starting from the assumption kJ/ kM = (1 - kap)/ kap, which gives a constant maturity density mH = yEV (1 - kap)/ kap.
  % See <get_ael_f.html *get_ael_f*> for foetuses, which differ from eggs by not being limited by reserve availability.
  
  %% Example of use
  % See <../mydata_get_ael.m *mydata_get_ael*>
  
  % unpack par
  JEAm = par(1); % {J_EAm}
  kap  = par(2); % \kappa
  v    = par(3); % v
  JEM  = par(4); % [J_EM]
  kJ   = par(5); % k_J
  yVE  = par(6); % y_VE
  MHb  = par(7); % M_H^b
  MV   = par(8); % [M_V]

  g = v * MV/ (kap * JEAm * yVE); % energy investment ratio
  Lm = kap * JEAm/ JEM;           % maximum length L_m

  nf = size(F,1); aEL = zeros(nf,3); E0 = zeros(nf,1); lb = zeros(nf,1);
  options = optimset('display','off');
  
  for i = 1:nf % loop over different scaled functional responses
    f = F(i);  % current scaled functional response
    [x, E00] = get_ael_f(par, f);          % first get M_E^0 for foetus 
    [E0(i), x, info] = fsolve(@get_e0, E00, options, JEAm, kap, v, kJ, g, Lm, f, MHb); % get M_E^0 for egg, copy to output
    if info ~= 1
      fprintf('no convergence for E0\n');
    end

    aEL0 = [0; E0(i); 1e-10]; % set initial (a, M_E, L)
    H = [0; MHb];             % set (M_H^0, M_H^b)
    [H A] = ode45(@dget_ael, H, aEL0, [], JEAm, kap, v, kJ, g, Lm);
    aEL(i,:) = A(end,:);      % copy (a_b, M_E^b, L_b) to output
    lb(i) = A(end,3)/ Lm;	  % copy l_b to output
  end
end

% subfunctions

function dx = dget_ael(H, aEL, JEAm, kap, v, kJ, g, Lm)
  % H: scalar with M_H (cum investment in maturation, mol reserve)
  % aEL: 3-vector with (a, M_E, L) of embryo
  % dx: 3-vector with (da/dM_H, dM_E/dM_H, dL/dM_H)
  % called by get_ael, get_e0
  
  % a = aEL(1); % age
  E = aEL(2); % reserve M_E
  L = max(0,aEL(3)); % length L
  % H maturity M_H

  eL3 = E * v/ (kap * JEAm); % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  JEC = JEAm * L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC
  
  % first generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * JEC - kJ * H;
  dE = - JEC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dt/dH, dE/dH, dL/dH, 
  dx = [1/dH; dE/dH; dL/dH];
end

function F = get_e0(E0, JEAm, kap, v, kJ, g, Lm, f, MHb)
  %  Finds M_E^0 such that m_E(a_b) = f m_Em
  %  E0: scalar with M_E^0
  %  F: scalar that is set to zero
  %  called by get_ael

  aEL0 = [0; E0; 1e-10]; H = [0; MHb];
  [H, A] = ode45(@dget_ael, H, aEL0, [], JEAm, kap, v, kJ, g, Lm);
  MEb = A(end,2); Lb = A(end,3);
  F = MEb - f * Lb^3 * JEAm/ v;
end