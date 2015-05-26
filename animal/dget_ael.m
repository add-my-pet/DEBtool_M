function dx = dget_ael(H, aEL)
  % dx = dget_ael(H, aEL)
  % H: scalar with M_H (cum investment in maturation, mol reserve)
  % aEL: 3-vector with (a, M_E, L) of embryo
  % dx: 3-vector with (da/dM_H, dM_E/dM_H, dL/dM_H)
  % called by get_ael, get_e0
  
  global JEAm kap v kJ g Lm

  % Input:
  % H: maturity M_H
  % a = aEL(1); % age
  E = aEL(2); % reserve M_E
  L = max(0,aEL(3)); % length L

  eL3 = E * v/ (kap * JEAm); % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  JEC = JEAm * L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC
  
  % first generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * JEC - kJ * H;
  dE = - JEC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dt/dH, dE/dH, dL/dH, 
  dx = [1/dH; dE/dH; dL/dH];