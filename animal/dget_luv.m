function dluv = dget_luv(t, luv, g, k)
  % change in state variables during embryo stage (2,26-29)

  
  % unpack state variables
  l = luv(1); % -, scaled length
  u = luv(2); % -, scaled reserve
  v = luv(3); % -, scaled maturity

  l2 = l * l; l3 = l * l2; l4 = l * l3; ul3 = u + l3;

  dl = (g * u - l4)/ 3/ ul3;
  du = - u * l2 * (g + l)/ ul3;
  dv = - du - k * v;
  
  % pack derivatives
  dluv = [dl; du; dv];
