function F = fnget_pars_g(p,xyw)
  % called by get_pars_g
  % calls dget_ul
  
  global Lb Lm rB ab g v f
  
  % unpack variables
  g   = p(1); % energy investment ratio
  kM  = p(2); % somatic maintenance rate coefficient
  v   = p(3); % energy conductance
  U0  = p(4); % scaled reserve at age 0: M_E^0/{J_EAm}
  
  f1 = Lm - v/ (kM * g);
  
  f2 = rB - kM * g/ (3 * (f + g));
  
  [a UL] = ode23('dget_ul', [0; ab], [U0; 1e-6]);
  f3 = UL(end,1) - f * Lb^3/ v ;
  f4 = UL(end,2) - Lb;

  % pack output
  F = [f1;f2;f3;f4];
