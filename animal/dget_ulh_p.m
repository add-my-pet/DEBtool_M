function dULH = dget_ulh_p(t, ULH)
  %  change in state variables during juvenile stage
  %  dULH = dget_ulh_p(ULH)
  %  ULH: 3-vector
  %   U: scaled reserve M_E/ {J_{EAm}}
  %   L: structural length
  %   H: scaled maturity M_H/ {J_{EAm}}
  %  dULH: change in scaled reserve, length, scaled maturity
  %  called by get_pars_r, fnget_lnpars_r
  
  global Li Lm v g kJ kap f

  %  unpack variables
  U = ULH(1); L = ULH(2); H = ULH(3);
 
  eL3 = U * v; % eL3 = L^3 * m_E/ m_Em
  gL3 = g * L^3; 
  SC = L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3); % J_EC/{J_EAm}
  dU = f * L^2 - SC; % difference with dget_ulh: assimilation f * L^2
  dL = v * (eL3 - L^4/ Lm)/ (3 * (eL3 + gL3));
  dH = (1 - kap) * SC - kJ * H;

  %  pack derivatives
  dULH = [dU; dL; dH];
