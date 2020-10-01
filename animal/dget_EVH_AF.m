function dAF = dget_EVH_AF(t, EVH_AF, p)
  % ode specification for get_EVH_AF
  
  % created by Dina Lika & Nina Marn 2019/06/11
  
  % unpack state variables
  E  = EVH_AF(1); V  = EVH_AF(2); E_R  = EVH_AF(3);       % mother, energy in reserve, structural volume, energy in reproductive reserve
  E_F  = EVH_AF(4); V_F  = EVH_AF(5); EH_F  = EVH_AF(6);  % foetus, energy in reserve, structural volume, energy invested to maturation

  % unpack p
  p_Am = p(1);       % J/d.cm^2, max surface-spec assimilation flux
  p_FAm = p(2);      % J/d.cm^2, foetal-specific assimilation parameter
  v = p(3);          % cm/d, energy conductance
  v_F = p(4);        % cm/d, foetal energy conductance
  kap = p(5);        % -, allocation fraction to soma
  kap_R = p(6);      % -, reproduction efficiency of the mother, and repro reserve assimilation efficiency of the foetus
  kap_RL = p(7);     % -, milk production efficiency of the mother, and milk assimilation efficiency of the foetus
  p_M = p(8);        % J/d.cm^3, vol-spec somatic maint
  k_J = p(9);        % 1/d, maturity maint rate coefficient
  E_G = p(10);       % J/cm^3, spec cost for structure
  E_Hb = p(11);      % J, maturity at birth
  E_Hx = p(12);      % J, maturity at weaning
  E_Hp = p(13);      % J, maturity at puberty
  E_m = p(14);       % J/cm^3, reserve capacity 
  t_0 = p(15);       % d, time at start development (since mating) 
  S_eff = p(16);     % -, effective placenta surface area coefficient
  Npups = p(17);     % -, number of foetuses
  f = p(18);         % -, scaled functional response
  t_mate = p(19) ;   % d, age of mother at mating
  
  L = V^(1/3);     % cm, structural length
  L_F = V_F^(1/3); % cm, structural length of foetus
  e_R = E_R/V/E_m; % -, scaled reserve density, e_R = [E_R] / [E_m]
  
% Fluxes (mother)
  pA = p_Am * f * L^2;                                 % J/d, assimilation
  pAR = (t > t_0 + t_mate & EH_F <= E_Hx) * S_eff * Npups * p_Am * f * L_F^2; % upregulated assimilation
  pS = p_M * V;                                        % J/d, somatic maintenance
  pJ = k_J * E_Hp;                                     % J/d, maturity maintenance for adults
  pC = E * (E_G * v * L^2 + pS) / (kap * E + E_G * V); % J/d, mobilization
  pG = kap * pC - pS;                                  % J/d, growth
  pR = (1 - kap) * pC - pJ + pAR;                      % J/d, allocation to reproduction
   
  if EH_F < E_Hb  % gestation
     pFL = (t > t_0 + t_mate)* S_eff * e_R * p_FAm * L_F^2/kap_R;  % from mother allocation to each foetus
     pA_F = kap_R * pFL;                                             % foetal assimilation 
     pC_F = (p_M * V_F + E_G * v_F * V_F^(2/3)) / kap;               % demand dynamics, foetus mobilization rate
  elseif  EH_F >= E_Hb && EH_F < E_Hx  % lactation
     pFL = S_eff * e_R * p_FAm * L_F^2/kap_RL;                       % from mother allocation to each foetus
     pA_F = kap_RL * pFL;                                            % foetal assimilation 
     pC_F = (p_M * V_F + E_G * v * V_F^(2/3)) / kap;                 % demand dynamics, but with mother's v
  else
     pFL = 0;
     pA_F = p_Am * f * L_F^2; % assimilation;
     pC_F = E_F * (E_G * v * L_F^2 + p_M * V_F) / (kap * E_F + E_G * V_F); % v of the mother
  end
  
  % Differential equations for the adults
  dE = pA - pC;        % J/d, dE/dt
  dV = pG / E_G;       % cm^3/d, dV/dt
  dR = (pR - Npups * pFL); % J/d, dE_R/dt
                    
  % Differential equations for foetus/newborn
  if EH_F < E_Hb
      dE_F = (t> t_0 + t_mate) * (pA_F - pC_F);  
      dV_F = (t> t_0 + t_mate) * v_F * V_F^(2/3);
      dH_F = (t> t_0 + t_mate) * ((1 - kap) * pC_F - k_J * EH_F); 
  elseif EH_F >=E_Hb && EH_F < E_Hx 
      dE_F = pA_F - pC_F; 
      dV_F = v* V_F^(2/3); % exponential growth; v of the mother
      dH_F = (1 - kap) * pC_F - k_J * EH_F;       
  else
      dE_F = pA_F - pC_F; 
      dV_F = kap * pC_F - p_M * V_F; % von B growth!
      dH_F = (1 - kap) * pC_F - k_J * EH_F; 
  end
  
% pack derivatives
  dAF = [dE; dV; dR; dE_F; dV_F; dH_F]; 
  end
