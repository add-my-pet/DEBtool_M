function [R, elong, rm] = RNAdensity(p, rRNA, re, rmax)
  %% unpack parameters
  thv = p(1); the = p(2); w = p(3);
  kM = p(4); g = p(5); ld = p(6);

  rm = kM * (1/ ld - 1)/ (1/ g + 1); % max spec growth rate

  %% for r to f using the simple V1-morph relationship
  f = g * (kM + rRNA(:,1)) ./ (g * kM/ ld - rRNA(:,1));
  R = (thv + the * w * f) ./ (1 + w * f); 

  f = g * (kM + rm * re(:,1)) ./ (g * kM/ ld - rm* re(:,1));
  elong = re(:,1) ./ f;
