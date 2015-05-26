function el3_0 = el3_init (f,g,l_b)
  % created 2000/09/05 by Bas Kooijman
  % calculates el^3 for t=0
  % called from subroutines of 'animal'
  
  x_b = g./(f + g);
  el3_0 = 1./(1./(l_b*(g + f)^(1/3)) - beta0(0,x_b)/(3*g^(4/3))).^3;
