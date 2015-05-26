function d = deLqhS(t, eLqhS)
  
  global kM v g ha sG f0

  ee = eLqhS(1); L = eLqhS(2); q = eLqhS(3); h = eLqhS(4); S = eLqhS(5);
  
  LT = 0; Lm = v/ (kM * g);
  rB = 1/ (3/ kM + 3 * Lm/ v);
  
  r = v * (ee/ L - (1 + LT/ L)/ Lm)/ (ee + g);

  if t > 100 & t < 600
    f = f0;
  else
    f = 1;
  end

  de = (f - ee) * v/ L;
  dL = r * L/ 3;
  dq = (q * (L/ Lm)^3 * sG + ha) * ee * (v/ L - r) - r * q;
  dh = q - h * r;
  dS = - S * h;
  
  d = [de; dL; dq; dh; dS];
