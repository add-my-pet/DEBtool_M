function [L1 L2] = bert2(p, aL1, aL2)
  %% unpack parameters
  Lb = p(1); g = p(2); kM = p(3); v = p(4); f1 = p(5); f2 = p(6);

  Lm = v/ (kM * g); Li1 = f1 * Lm; Li2 = f2 * Lm; % max and ulit lengths
  %% notice that if f1 and f2 are not known, Lm can not be known
  %%      and one parameter is redundant
  rB1 = 1/ (3/ kM + 3 * Li1/ v); rB2 = 1/ (3/ kM + 3 * Li2/ v);

  L1 = Li1 - (Li1 - Lb) * exp( - rB1 * aL1(:,1));
  L2 = Li2 - (Li2 - Lb) * exp( - rB2 * aL2(:,1));
