function dH = dget_h_p(t,H)
  % dH = dget_h_p(t,H)
  % modified 2009/09/29
  % t : time since birth a - ab
  % H : scaled maturity M_H/ {J_{EAm}}
  % dH: change in scaled maturity at abundant food
  % called by get_pars, fnget_pars_r
  
  global Lb Lm rB kJ kap G

  L = Lm - (Lm - Lb) * exp(- rB * t); % length at time since birth
  
  dH = (1 - kap) * L^2 * (G/ (G + 1)) * (1 + L/ (G * Lm)) - kJ * H;

