function [L S] = bertLS(p, aL, aS)
  %% e = 1; LT = 0; 
  global kM v g ha sG
  %% unpack parameters
  Lb = p(1); g = p(2); kM = p(3);
  v = p(4); ha = 1E-6 * p(5); sG = p(6);

  Lm = v/ kM/ g;
  rB = 1/ (3/ kM + 3 * Lm/ v); % von Bert growth rate
  L = Lm - (Lm - Lb) * exp(- rB * aL(:,1));

  [a LS] = ode23('dbertLS', [-1e-6; aS(:,1)], [Lb; 1; 0; 0]);
  S = LS(:,2); S(1) = [];
