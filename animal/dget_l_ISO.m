function dl = dget_l_ISO(vH, l, k, lT, g, f, sM)
  % vH: scalar with scaled maturity
  % l: scalar with scaled length
  % dl: scalar with d/dvH l
  % called from get_lp, get_lj, get_ls
    
  r = g * (f * sM - lT * sM - l)/ l/ (f + g); % specific growth rate
  dl = l * r/ 3;                              % d/dt l
  dvH = f * l^2 * (sM - l * r/ g) - k * vH;   % d/dt vH
  dl = dl/ dvH;                               % dl/ dvH
end