function daL = dget_aL(UH, aL)
  % used in add_my_pet/get_pars_Danio_rerio

  a = aL(1);
  L = aL(2);

  dHL = dget_HL(a, [UH; L]);
  daL = [1; dHL(2)]/ dHL(1);