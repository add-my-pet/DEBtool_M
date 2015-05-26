function dvH = fnget_tb_foetus(t, vH, g, k, vHb)
  %% t: scaled age
  %% vH: scaled maturity

  dvH = g^3 * t^2 * (1 + t/ 3)/ 9 - k * vH;
