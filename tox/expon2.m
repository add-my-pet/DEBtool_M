function [f1, f2] = expon2(p, tn1, tn2)
  % example of function definition for nmsurv
  % p: (1,2) exponential decay
  
  f1 = exp(1).^(-p(1) * tn1(:,1));
  f2 = exp(1).^(-p(2) * tn2(:,1));
