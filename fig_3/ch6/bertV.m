function [V1, V2, V3] = bertV(p, aV1, aV2, aV3)
  %% since Vb increases with Vi, tb is probably before t=0
  Lb = p(1)^(1/3); Li1 = p(2)^(1/3); Li2 = p(3)^(1/3); Li3 = p(4)^(1/3);
  kM = p(5); v = p(6); da = p(7);
  rB1 = 1/(3/kM + 3 * Li1/ v);
  rB2 = 1/(3/kM + 3 * Li2/ v);
  rB3 = 1/(3/kM + 3 * Li3/ v);
  
  V1 = (Li1 - (Li1 - Lb) * exp( -rB1 * (da + aV1(:,1)))) .^ 3;
  V2 = (Li2 - (Li2 - Lb) * exp( -rB2 * (da + aV2(:,1)))) .^ 3;
  V3 = (Li3 - (Li3 - Lb) * exp( -rB3 * (da + aV3(:,1)))) .^ 3;
