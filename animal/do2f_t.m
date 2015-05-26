function dt = do2f_t(L, t)
  % called by o2f_init

  global rB Li tc

  cor_T = spline1(t, tc);
  dL = cor_T * rB * (Li - L);

  dt = 1/dL;
