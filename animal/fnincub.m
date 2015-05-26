function fn = fnincub (x, a, x_b)
  % created 2000/08/17 by Bas Kooijman, modified 2007/03/24
  % called from 'incub'

  fn = 1./((1 - x) .* x .^ (2/ 3) .* (a - beta0(x, x_b)));
