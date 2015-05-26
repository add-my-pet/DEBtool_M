function F = chemo0(XY) % no socialization
  global Kx Ky jxm kE ld g dy Xr h; 

  x = XY(1)/ Kx; y = XY(2)/ Ky;

  %% scaled functional response
  f = x/ (1 + x); % no socialization

  %% spec growth rate
  r = kE * (f - ld)/ (f + g);

  F = [h * (Xr - x * Kx) - f * jxm * y * Ky; h - r];
