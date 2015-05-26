function f = fnincub0 (y, a, x_b) 
  % created 2000/09/30 by Bas Kooijman, modified 2007/03/24
  % called from 'incub'

  f = -log(- 1 + y^(1/ 3)) + 1/ 2 * log(y^(2/ 3) + y^(1/ 3) + 1) + ...
    3^(1/ 2) * atan(1/ 3 * 3^(1/ 2) * (2 * y^(1/ 3) + 1)) + i * pi - 1/ 6 * 3^(1/ 2) * pi;
  f = f/ (a - beta0(y, x_b));