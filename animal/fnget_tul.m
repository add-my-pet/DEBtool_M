function fn = fnget_tul(lb)
  % called by get_tul

  global g f vHb k % for dget_tul
  l0 = 1e-4;
  uE0 = get_ue0([g k],f, lb);
  vH0 = uE0 * l0^2 * (g + l0)/ (uE0 + l0^3)/ k;
  [vH, tul] = ode23s('dget_tul', [vH0; vHb], [0; uE0; l0]);
  lb = tul(end,3); uEb = tul(end,2);
  fn = f * lb^3/ g - uEb;
