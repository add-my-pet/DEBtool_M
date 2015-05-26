function UN = fncum_reprod (a)
  %% called by cum_reprod, cum_reprod_metam
  
  global f g kap kJ UHp LB LP LM LT rB sM

  Li = sM * (f * LM - LT);
  L = Li - (Li - LB) * exp(-a * rB);
  SC = f .* L.^3 .* (g * sM ./ L + (1 + LT * sM ./ L)/ LM)/ (f + g);
  UN = (L>=LP) .* ((1 - kap) * SC - kJ * UHp);
