function [f1 f2 f3 f4] = linear4(p, x1, x2, x3 ,x4)
  %% for linear relationships with equal slopes
  f1 = p(1) + p(5) * x1(:,1);
  f2 = p(2) + p(5) * x2(:,1);
  f3 = p(3) + p(5) * x3(:,1);
  f4 = p(4) + p(5) * x4(:,1);

