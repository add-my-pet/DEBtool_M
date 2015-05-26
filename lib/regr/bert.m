function f = bert(p, xyw)
  % von Bertalanffy growth curve
  % p: (1) init value for von Bert (2) max for von Bert (3) growth rate
  
  f = p(2) - (p(2) - p(1)) * exp(- p(3) * xyw(:,1));