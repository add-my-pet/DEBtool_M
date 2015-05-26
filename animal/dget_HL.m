function dHL = dget_HL(a, HL)
  % V1-morphic juvenile I, a_b < a < a_j
  % used in add_my_pet/get_pars_Danio_rerio

  global v L_b L_m g f L_T kap kJ morph
  UH = HL(1);
  L = HL(2);

  vj = v * (L/ L_b)^morph; % shape corr function propto L^morph
  L_mj = L_m * (L/ L_b)^morph; % shape corr function propto L^morph
  r = vj * (f/ L - (1 + L_T/ L)/ L_mj)/ (f + g);
  dL = r * L /3;
  dUH = (1 - kap) * f * L^2 * (g + L/ L_m)/ (g + f) - kJ * UH;

  dHL = [dUH; dL];