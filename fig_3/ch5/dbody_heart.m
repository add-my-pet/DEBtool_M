function dWWH = dbody_heart(t, WWH)
  global Lh v kM kMH d dH
  %% unpach state vars
  W = max(1e-3,WWH(1)); WH = max(1e-3,WWH(2));

  dW = d * ((v + kM * Lh)/ W^(1/3) + kM) * W - kM * W * (1 + Lh/ W^(1/3));
  dWH = dH * ((v + kM * Lh)/ W^(1/3) + kM) * W - kMH * WH;
  
  %% pack derivatives
  dWWH = [dW; dWH];