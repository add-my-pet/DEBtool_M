function rR = cjuv (apR)
  %% calls fnjuv
  global ApR
  na = length(apR); rR = na;
  for i = 1:na
    ApR = apR(i);
    rR(i) = fsolve('fnjuv', exp(-ApR));
  end
