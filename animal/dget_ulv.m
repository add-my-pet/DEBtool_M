function dulv = dget_ulv(t,ulv)
  %  change in state variables during embryo stage
  %  t: a/ k_M
  %  ulv: [u_E, l, v_H]
  %  called by get_eb_min

  global g k 
  
  %  unpack state variables
  u = ulv(1); % scaled reserve u = E/(g [E_m] L_m^3)
  l = ulv(2); % scaled structural length l = L/ L_m
  v = ulv(3); % scaled maturity v = E_H/ (g [E_m] L_m^3 (1 - kap)

  ul3 = u + l^3;
  du = - u * l^2 * (g + l)/ ul3;
  dl = (g * u - l^4)/ 3/ ul3;
  dv = u * l^2 * (g + l)/ ul3 - k * v;
  
  %  pack derivatives
  dulv = [du; dl; dv];