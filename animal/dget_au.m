function dx = dget_au(L, aU, v, g, Lm)
  % dx = dget_au(L, aU, v, g, Lm)
  % L = structural length
  % aU: 2-vector with (a, U) of embryo
  %  a = age, U= M_E/{J_EAm};
  % dx: 2-vector with (da/dL, dU/dL)
  % called by iget_pars_g, maturity

  % a = aU(1); % age
  U = aU(2); % scaled reserve M_E/{J_EAm}
  
  eL3 = U * v; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  
  % first generate dU/dt, dL/dt
  dU = - SC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dt/dL, dU/dL
  dx = [1/dL; dU/dL];
