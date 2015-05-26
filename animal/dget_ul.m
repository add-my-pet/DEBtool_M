function dUL = dget_ul(a, UL)
  % change in state variables during embryo stage
  % called by fnget_pars_g, get_pars_g, get_pars

  global v g Lm 
  
  % unpack state variables
  U = UL(1); % U = M_E/{J_{EAm}}
  L = UL(2); % structural length

  eL3 = U * v; % L^3 * M_E/ M_{Em}
  gL3 = g * L^3;
  dU = - L^2 * (1 + L/ (g * Lm)) * g * eL3/ (gL3 + eL3);
  dL = v * (eL3 - L^4/ Lm)/ (3 * eL3 + 3 * gL3);

  % pack derivatives
  dUL = [dU; dL];