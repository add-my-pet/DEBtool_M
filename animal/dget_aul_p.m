function dx = dget_aul_p(H, aUL, kap, v, kJ, g, Lm, f)
  %  dx = dget_aul_p(H, aUL, kap, v, kJ, g, Lm, f)
  %  H: scalar with M_H/{J_EAm} (cum invest in mat.)
  %  aUL: 3-vector with (a, U, L) of juvenile
  %   a = age, U= M_E/{J_EAm}, L = structural length
  %  dx: 3-vector with (da/dH, dU/dH, dL/dH)
  %  called by iget_pars, fniget_pars
  %  similar to dget_aul except for dU

  %  global kap v kJ g Lm f

  % a = aUL(1); % age
  U = aUL(2); % scaled reserve M_E/{J_EAm}
  L = aUL(3); % structural length
  
  eL3 = U * v; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  
  % first generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;
  dU = f * L^2 - SC; % this is the difference with dget_aul
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  
  % then obtain dt/dH, dU/dH, dL/dH, 
  dx = [1/dH; dU/dH; dL/dH];
