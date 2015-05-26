function F = fnget_u0(p, x)
  % p: 8-vector with parameters
  % x: dummy variable
  % used to find U^0 such that m_E(a_b) = f
  % called by initial_scaled_reserve1, fnget_lnpars_s
   
  U0 = p(1); % U^0 = M_E^0/{J_EAm}
  v = p(2);  f = p(3);   Hb = p(4);   kap = p(5);
  kJ = p(6); g = p(7);   Lm = p(8);
  
  [H, aUL] = ode45(@dget_aul, [0; Hb], [0; U0; 1e-10], [], kap, v, kJ, g, Lm);
  F = aUL(end,2) - f * aUL(end,3)^3/ v;