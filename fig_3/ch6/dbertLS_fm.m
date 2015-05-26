function dLShq = dbertLS_fm(t, LShq)
  global kM v g ha sG
  
  L = LShq(1); S = LShq(2); h = LShq(3); q = LShq(4);
  ee = 1; LT = 0; Lm = v/ (kM * g);
  rB = 1/ (3/ kM + 3 * Lm/ v);
  r = v * (ee/ L - (1 + LT/ L)/ Lm)/ (ee + g);

  dL = rB * (Lm - L);
  dq = (q * (L/ Lm)^3 * sG + ha) * (v/ L - r) - r * q;
  dh = q - h * r;
  dS = - S * h;
  dLShq = [dL; dS; dh; dq];
