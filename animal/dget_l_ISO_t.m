function dvHl = dget_l_ISO_t(t, vHl, k, lT, g, f, sM, vHp)
  % vH: scalar with scaled maturity
  % l: scalar with scaled length
  % dl: scalar with d/dvH l
  % called from get_lp, get_lj, get_ls
  vH = vHl(1); l = vHl(2);   
  
  r = g * (f * sM - lT * sM - l)/ l/ (f + g); % specific growth rate
  dl = l * r/ 3;                              % d/dt l
  dvH = f * l^2 * (sM - l * r/ g) - k * vH;   % d/dt vH
  
  dvHl = [dvH; dl]; 
end