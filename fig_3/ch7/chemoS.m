function F = chemoS(XY) % sequential socialization
  global Kx Ky jxm kE ld g dy Xr h; 

  x = XY(1)/ Kx; y = XY(2)/ Ky;

  %% scaled functional response
  %%  f = x/ (1 + x); % no socialization
  f = x/ (1 + x + y); % sequential case
  %%  f = x/ (1 + x + y + x * y/ (1 + dy + dy * y)); % parallel case

  %% spec growth rate
  r = kE * (f - ld)/ (f + g);

  F = [h * (Xr - x * Kx) - f * jxm * y * Ky; h - r];
