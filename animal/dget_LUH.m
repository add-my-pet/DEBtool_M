  function dLUH = dget_LUH(a, LUH, kap, v, kJ, g, Lm)
  % a: scalar with age
  % LUH: 3-vector with (L, U= M_E/{J_EAm}, H = M_H/{J_EAm}) of embryo
  % dLUH: 3-vector with (dL/da, dU/da, dH/da)
  
  L = LUH(1); % cm, structural length
  U = LUH(2); % d.cm^2, scaled reserve M_E/{J_EAm}
  H = LUH(3); % d.cm^2, scaled maturity M_H/{J_EAm}
  
  eL3 = U * v;   % cm^3, eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3; % cm^3
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % cm^2, J_EC/{J_EAm}
  
  % generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;                % cm^2
  dU = - SC;                                   % cm^2
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3)); % cm/d
  
  % pack dL/da, dU/da, dH/da, 
  dLUH = [dL; dU; dH];