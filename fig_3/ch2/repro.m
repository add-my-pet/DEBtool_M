function R = repro(p, LRw)
  R = p(1) * LRw(:,1).^2 + p(2) * LRw(:,1).^3 - p(3);
