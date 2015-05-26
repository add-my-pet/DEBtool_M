function r = findchi (x)
  global NU f;
  r = surv_chi(NU,x) - f;
