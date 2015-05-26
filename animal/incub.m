function t_b = incub (f, g, l_b, kT_M)
  % created 2000/08/17 by Bas Kooijman, modified 2007/03/24
  %
  %% Description
  %  calculates age at birth t_b

  x_b = g/ (f + g); a = 3 * g * x_b^(1/ 3)/ l_b;
  eps = 0.01;
  t_b = (3/ kT_M) * fnincub0(min(x_b, eps), a, x_b);
  if x_b > eps
    t_b = t_b + (3/kT_M)*quad(@fnincub, eps, x_b, [], [], a);
  end