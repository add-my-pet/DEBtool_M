function [L Li] = bert_pub(p, aL, aLi)
  %% called from fig_7_29
  %% unpack parameters
  Lb = p(1); Lij = p(2); Lia = p(3);
  ap = p(4); rBj = p(5); rBa = p(6);

  Lp = Lij - (Lij - Lb) * exp(-ap * rBj);
  L = (aL(:,1) < ap) .* (Lij - (Lij - Lb) * exp(- rBj * aL(:,1))) + ...
      (aL(:,1) >= ap) .* (Lia - (Lia - Lp) * exp(- rBa * (aL(:,1) - ap)));
  
  Li = Lia;
