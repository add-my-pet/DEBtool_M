function [jXR jYR jYP jZP] = fnclosed (p, jXF)

  %% unpack parameters; see below Eq (2.17) {49}
  kX = p(1); kY = p(2); kZ = p(3);
  rX = p(4); rY = p(5); yXY = p(6); yYZ = p(7);
  c = p(8); s = p(9);

  kY1 = rY * kY/ yXY; jXF1 = rX * jXF - c * kX;
  k1dd = rX * jXF * (s * kZ + c * kY1) + c * s * (kY - kX) * kZ;
  kdd = sqrt(k1dd.^2 - 4 * c * s^2 * kY * kZ^2 * jXF1);
  tc = (2 * c^2 * kX * kY1 + 2 * c * s * kY * kZ - k1dd - kdd) ./ ...
      (- 2 * c * kY1 * jXF1);
  ts = (k1dd + kdd)/ (2 * c * s * kY * kZ);

  jXR = kX * (1 - tc) * c - jXF .* (1 - rX * tc);
  jYR = (1 - rY) * kY * (1 - tc) .* ts * c/ yXY;
  jYP = kY * ts .* (1 - tc) * c/yXY;
  jZP = kZ * (1 - ts) * s/ yYZ;
