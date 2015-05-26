function dx = degg_j(a, HEL)
  % dx = degg_j(a, HEL)
  % HEL: 3-vector with (M_H, M_E, L) of embryo
  % dx: 3-vector with (dM_H/da, dM_E/da, dL/da)
  % called by egg_j
  
  global JEAm kap v kJ g Lm

  H = HEL(1); % maturity M_H
  E = HEL(2); % reserve M_E
  L = HEL(3); % length L

  eL3 = E * v/ (kap * JEAm); % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  JEC = JEAm * L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3);
  
  % first generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * JEC - kJ * H;
  dE = - JEC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));

  dx = [dH; dE; dL];