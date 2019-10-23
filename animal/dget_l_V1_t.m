function dvHl = dget_l_V1_t(t, vHl, k, lT, g, f, lref, vHj)
  % t: -, scaled time
  % vH: -, scaled maturity
  % l: -, scaled length
  % lref: -,scaled length when acceleration starts (can be lb or ls)
  % dl: d/dvH l during exponential growth
  % called from get_lp, get_lj, get_ls
  
  vH = vHl(1); l = vHl(2); % unpack vars
  
  r   = g * (f - lT - lref)/ lref/ (g + f); % specific growth rate
  dl  = r * l/ 3;                           % d/dt l
  dvH = f * l^3 * (1/ lref - r/ g) - k * vH;% d/dt vH
  
  dvHl  = [dvH; dl];                        % pack output
end