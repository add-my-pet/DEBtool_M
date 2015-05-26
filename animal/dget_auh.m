function dx = dget_auh(L, aUH, kap, v, kJ, g, Lm)
  % dx = dget_auh(L, aUH)
  % aUH: 3-vector with (a, U, H) of embryo
  %  a = age, U= M_E/{J_EAm}, H = M_H/{J_EAm} (cum invest in mat.)
  % L: scalar with structural length
  % dx: 3-vector with (da/dL, dU/dL, dH/dL)
  % called by fnget_pars_s

  % a = aUH(1); % age
  U = aUH(2); % scaled reserve M_E/{J_EAm}
  H = aUH(3); % scaled matruity M_H/{J_EAm}

  eL3 = U * v/ kap; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  
  % first generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;
  dU = - SC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dt/dL, dU/dL, dH/dL, 
  dx = [1/dL; dU/dL; dH/dL];

