function dulhMJ = dget_ulhMJ_foetus(t,ulhMJ)
  % change in state variables during embryo stage
  % called by get_EMJG_foetus to get energy fractions at birth

  global g kap k 
  
  % unpack state variables
  %u = ulhMJ(1);  % u_E scaled reserve
  l = ulhMJ(2);  % l, scaled length
  h = ulhMJ(3);  % u_H, scaled maturity
  
  l2 = l * l; l3 = l2 * l;

  du = 0;                                 % d/dt u_E 
  dl = g/ 3;                              % d/dt l
  dh = (1 - kap) * l2 * (g + l) - k * h;  % d/dt u_H
  dM = kap * l3;                          % d/dt u_M, som maint
  dJ = k * h;                             % d/dt u_J, mat maint

  % pack derivatives
  dulhMJ = [du; dl; dh; dM; dJ];
