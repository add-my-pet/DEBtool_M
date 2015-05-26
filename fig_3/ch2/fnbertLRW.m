function LR = fnbertLRW (a)
  global Lb Li rB w2 w3 w0
  L = Li - (Li - Lb) * exp(- rB * a);
  LR = w2 * L.^2 + w3 * L.^3 - w0; % integrated reproductive mass
  LR = max(0,LR).^(1/3); % conversion from mass to a length measure

