function [f1, f2] = hypbert (p, xyw1, xyw2)
  % hyperbolic functional response and von Bert curve
  % p:(1) max for hyperbola (2) saturation coefficient
  %   (3) init value for von Bert (3) max for von Bert (4) growth rate
  
  f1 = p(1) * xyw1(:,1)./ (p(2) + xyw1(:,1));
  f2 = p(4) - (p(4) - p(3)) * exp(- p(5) * xyw2(:,1));