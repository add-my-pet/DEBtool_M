function dX = fnconc_v1(t, X)
  global K k
  dX = - k * X/ (K+X);
