function [L Lt W] = bertLRW(p, aLw, aRw, aWw)
  global Lb Li rB w2 w3 w0
   
  %% unpack parameters aLw(:,1) = aRw (:,1) = aWw (:,1)
  Lb = p(1); Li = p(2); rB = p(3);
  w2 = p(4); w3 = p(5); delM1 = p(6); delM2 = p(7); %% shape coefficient2
  w0 = w2 * Lb^2 + w3 * Lb^3; % zero reproduction at birth

  L = Li - (Li - Lb) * exp(- rB * aLw(:,1)); % true trunk length

  LR = L; Lt = LR; %% prefill contribution of reproduction to length
  n = length(LR);
  for i = 1:n
    LR(i) = quad('fnbertLRW', 0, aRw(i,1)); % total trunk length
    Lt(i) = L(i) + LR(i); % total trunk length
  end

  W = delM1 * L.^3 + delM2 * LR.^3; % weight