function dx = dget_l_p(H, L)
  % dx = dget_l_p(H, L)
  % H: scalar with M_H/{J_EAm} (cum invest in mat.)
  % L: scalar with structural length L of juvenile
  % dx: scalar with dL/dH
  % called by iget_pars, fniget_pars
  
  global kap v kJ g Lm
 
  eL3 = L^3; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  
  % first generate dH/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dL/dH, 
  dx = dL/dH;
