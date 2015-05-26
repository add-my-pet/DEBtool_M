function F = get_u0(U0, x, v, f, Hb, kap, kJ, g, Lm)
  % U0: scalar with U^0 = M_E^0/{J_EAm}
  % x: dummy variable
  % used to find U^0 such that m_E(a_b) = f
  % called by initial_scaled_reserve1, fnget_lnpars_s
  % see fnget_u0 for alternative with nrregr, because fsolve is lousy
   
  
  [H, aUL] = ode45(@dget_aul, [0; Hb], [0; U0; 1e-10], [], kap, v, kJ, g, Lm);
  F = aUL(end,2) - f * aUL(end,3)^3/ v;