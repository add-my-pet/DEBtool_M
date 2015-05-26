function f = fomortph (p, t, cpH)
  %  ceated 2002/02/05 by Bas Kooijman
  %
  %% Description
  %  standard effects on survival: first-order-mortality, pH-effects
  %   first order toxico kinetics
  %   hazard rate linear in the internal conc
  %
  %% Input
  %  p: (4,k) matrix with parameters values in p(:,1) (see below)
  %  t: (tn,1) matrix with exposure times
  %  cpH: (cn,2) matrix with concentrations of toxic compound and pH values
  %
  %% Output
  %  f: (nt,nc) matrix with survival probabilities
  %
  %% Example of use
  %  mydata_fomortph
  
  %% unpack parameters for easy reference
  h  = p(1); % 1/h, blank mortality prob rate (always >0)
  c0 = p(2); % mM, No-Effect-Concentration of molecular form
  b  = p(3); % 1/(h*mM), killing rate of molecular form
  k  = p(4); % 1/h, elimination rate
  c0i= p(5); % mM, No-Effect-Concentration of ionic form
  bi = p(6); % 1/(h*mM), killing rate of ionic form
  pK = p(7); % M, pK value of the compound
  c  = cpH(:,1)'; % concentrations (row-matrix)
  pH = cpH(:,2)'; % pH values (row-matrix)
  a = 10.^(pH-pK); % row-matrix for the calculation of b and c0
  b = (b + bi * a) ./ (1 + a); % pH-corrected killing rates
  c0 = (1 + a) ./ (1/c0 + a./c0i); % pH-corrected NEC values  

  c1 = ones(1, max(size(c))); % row-matrix of ones
  t1 = ones(max(size(t)), 1); % column-matrix of ones
  k = c1 * k; % row-matrix with elimination rates

  t0 = -log(max(1e-8, 1 - c0./max(1e-8, c)))./ k; % no-effect-time (row matrix)
  %% ln survival probability due to compound
  f  = (t1 * (c .* b./ k)) .* max(0, exp(-t1 * (t0 .* k)) - exp(-t * k)) - ...
       (t1 * (b .* max(0, c - c0))) .* max(0, t*c1 - t1*t0);
  f  = min(1, exp(f)).* (exp(-h * t) * c1); % survival probability