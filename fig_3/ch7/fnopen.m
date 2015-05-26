function [jXR jYR jYP jZP] = fnopen (p, jXF)

  %% unpack parameters; see below Eq (2.19) {50}
  kX = p(1); kY = p(2); kZ = p(3);
  rX = p(4); rY = p(5); yXY = p(6); yYZ = p(7);
  c = p(8); s = p(9);

  A = c * (kX + kY); B = A - rX * jXF; C = B * s * kZ;
  tc = A ./ B; ts = C ./ (C - rX * jXF * c * rY * kY / yXY);

  jXR = kX * (1 - tc) * c - jXF .* (1 - rX * tc);
  jYR = (1 - rY * ts) * kY .* (1 - tc) * c/ yXY;
  jYP = kY * (1 - tc) * c/ yXY;
  jZP = kZ * (1 - ts) * s/ yYZ;
