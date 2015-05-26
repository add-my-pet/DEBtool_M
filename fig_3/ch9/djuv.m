function rR = djuv (apR)
  %% calls fndjuv
  global ApR
  na = length(apR); rR = apR;
  for i = 1:na
    ApR = apR(i);
    rR(i) = fsolve('fndjuv', exp(-ApR));
  end
