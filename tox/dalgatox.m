function dY = dalgatox(t, Y)

  global K yEV kN kE k0 kNB kBN c0 cH cy b ci

  %% unpack state vector
  B = Y(1); N = Y(2); m = Y(3); X = Y(4); Xd = Y(5); X0 = Y(6);

  jN = kN * N/ (K + N);
  yEVc = yEV*(1 + max(0, (ci-c0)/cy));
  rc = kE * m/ (m + yEVc);
  hc = max(0, (ci-c0)*b);

  dB = kNB * N - kBN * B; 
  dN = ((kE - rc) * m - rc * yEVc - jN) * X - kNB * N + kBN * B;
  dm = jN - kE * m;
  dX = (rc - hc)*X;
  dXd = hc*X - k0*Xd;
  dX0 = k0*Xd;

  dY = [dB; dN; dm; dX; dXd; dX0];
  