function S = fomort2r (p, t, c1, c2)
  %  created: 2006/03/07 by Bas Kooijman
  %
  %% Decription
  %  standard effects on survival: first-order-mortality
  %   first order toxico kinetics by two compounds
  %   hazard rate linear in the internal conc
  %
  %% Input
  %  p: (8,1) matrix with parameters values
  %  t: (nt,1) matrix with exposure times
  %  c1: (nA,1) matrix with concentrations of toxic compound type 1
  %  c2: (nB,1) matrix with concentrations of toxic compound type 2
  %
  %% Output
  %  S: (nt,nA*nB) matrix with survival probabilities

  global h0 CA0 CB0 bA bB kA kB dAB % model parameters
  global cA cB % external forcing variables

  %% unpack parameters for transfer to 'haz_fm2'
  h0 = p(1);  % 1/h, blank mortality prob rate (always >0)
  CA0 = p(2); % mM, No-Effect-Concentration for A (external, may be zero)
  CB0 = p(3); % mM, No-Effect-Concentration for B (external, may be zero)
  bA = p(4);  % 1/(h*mM), killing rate for A
  bB = p(5);  % 1/(h*mM), killing rate for B
  kA = p(6);  % 1/h, elimination rate for A
  kB = p(7);  % 1/h, elimination rate for B
  dAB = p(8); % 1/(h*mM^2), interaction rate for A and B

  nt = length(t); % number of time points
  nA = length(c1); % number of values for conc A
  nB = length(c2); % number of values for conc B

  S = zeros(nt, nA*nB); % initiate output
  for j = 1:nB
    cB = c2(j);
    for i = 1:nA
      cA = c1(i);
      S(:,i + (j - 1) * nA) = haz2surv('haz_fm2', t);
    end
  end 
