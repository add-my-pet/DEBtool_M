function dULH = dget_ulh(t,ULH)
  % change in state variables during embryo stage
  % called by fnget_lnpars_r, get_pars

  global v g Lm kJ kap
  
  % unpack state variables
  U = ULH(1); % U = M_E/{J_{EAm}}
  L = ULH(2); % structural length
  H = ULH(3); % H = M_H/{J_{EAm}}

  eL3 = U * v; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3;
  SC = L^2 * (1 + L/(g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  dU = - SC;
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  dH = (1 - kap) * SC - kJ * H;

  % pack derivatives
  dULH = [dU; dL; dH];
