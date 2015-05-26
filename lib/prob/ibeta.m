function f = ibeta (t)
  %  Created: 28 aug 2000 by Bas Kooijman
  %  incomplete beta function: B_x(a,b) = int_0^x t^(a-1) (1-t)^(b-1) dt
  %  usage: quad('ibeta',0,x), after par_ibeta = [a b], par_beta global
  %  Requires: -
  
  global par_ibeta;
  f = t^(par_ibeta(1) - 1)*(1 - t)^(par_ibeta(2)-1);
