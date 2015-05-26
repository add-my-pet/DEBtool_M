function dY = dclim(t, Y)
  % Created 2002/02/11 by Bas Kooijman

  global K yEV kC kE k0 kCB kBC;

  % unpack state vector
  B = Y(1); C = Y(2); m = Y(3); X = Y(4);

  jC = kC * C/ (K + C);
  r = kE * m/ (m + yEV);

  dB = kCB * C - kBC * B; 
  dC = ((kE - r) * m - r * yEV - jC) * X - kCB * C + kBC * B;
  dm = jC - kE * m;
  dX = r * X;


  dY = [dB; dC; dm; dX];