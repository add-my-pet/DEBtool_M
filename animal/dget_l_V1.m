function dl = dget_l_V1(vH, l, k, lT, g, f, lref)
  % vH: -, scaled maturity
  % l: -, scaled length
  % lref: -,scaled length when acceleration starts (can be lb or ls)
  % dl: d/dvH l during exponential growth
  % called from get_lp, get_lj, get_ls
  
  r   = g * (f - lT - lref)/ lref/ (g + f); % specific growth rate
  dl  = r * l/ 3;                           % d/dt l
  dvH = f * l^3 * (1/ lref - r/ g) - k * vH;% d/dt vH
  dl  = dl/ dvH;                            % dl/ dvH
end