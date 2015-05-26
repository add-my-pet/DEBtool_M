%% get_ael_f
% Gets age, reserve and length at birth for foetal development

%%
function [aEL E0 lb] = get_ael_f(par, F)
  % created by Bas Kooijman at 2006/08/28, modified 2009/03/14
  
  %% Syntax
  % [aEL E0 lb] = <../get_ael_f.m *get_ael_f*> (par, F)
  
  %% Description
  %  Obtains state variables at age zero and at birth from parameters and scaled reserve density at birth. 
  %  get_ael does so for eggs, and get_ael_f for foetuses, which differ from eggs by not being limited by reserve availability.
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
  % * aEL: (n,3)-matrix with a_b, M_E^b, L_b for foetus
  % * E0: n-vector with M_E^0 for foetus
  % * lb: n-vector with L_b/ L_m for foetus
  
  %% Remarks
  % The output values are numerically obtained, starting from the values for a foetus; 
  %  the age at birth of this foetus must again be obtained numerically, 
  %  which is done starting from the assumption kJ/ kM = (1 - kap)/ kap, which gives a constant maturity density mH = yEV (1 - kap)/ kap.
  
  %% Example of use
  % See <../mydata_get_ael.m *mydata_get_ael*>
  
  % unpack parameters
  JEAm = par(1); % {J_EAm}
  kap  = par(2); % \kappa
  v    = par(3); % v
  JEM  = par(4); % [J_EM]
  kJ   = par(5); % k_J
  yVE  = par(6); % y_VE
  MHb  = par(7); % M_H^b
  MV   = par(8); % [M_V]

  g = v * MV/ (kap * JEAm * yVE); % energy investment ratio
  Lm = kap * JEAm/ JEM; % maximum length
  kM = yVE * JEM/ MV; % som maint rate coefficient
  
  % Lb if (1 - kap) kM = kap kJ
  Lb = (MHb * yVE * kap/ (MV * (1 - kap)))^(1/3);
  ab = 3 * Lb/ v;
  [ab, x, info] = fsolve(@get_ab, ab, optimset('Display','off'), kJ, kM, MV, yVE, kap, MHb, v);
  if info ~= 1
    fprintf('no convergence for a_b\n');
  end
  Lb = ab * v/ 3; % Lb if (1 - kap) kM ~= kap kJ
  
  nf = size(F,1); aEL = zeros(nf,3); E0 = zeros(nf,1); lb = zeros(nf,1);

  for i = 1:nf
    f = F(i);
    E0(i) = JEAm * (f + (1 - kap) * g * (1 + 0.25 * ab * kM)) * Lb^3/ v;
    aEL(i,:) = [ab, JEAm * f * Lb^3/ v, Lb]; 
    lb(i) = Lb/ Lm;	   
  end
end

% subfunctions

function F = get_ab(a, kJ, kM, MV, yVE, kap, MHb, v)
  % find age at birth for foetal development

  akJ = a * kJ;
  A = 3 * (akJ * (akJ - 2) + 2);
  B = (akJ * (akJ * (akJ - 3) + 6) - 6) * kM/ kJ;
  C = 6 * (kM/ kJ - 1) * exp(- akJ);
  D = (3 * kJ/ v)^3 * kap * yVE/ ((1 - kap) * MV);
  F = MHb - (A + B + C)/ D;
end