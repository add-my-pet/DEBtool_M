function f = fomort_c0(p, t, c)
  %  created 2005/11/03 by Bas Kooijman
  %
  %% Description
  %  standard effects on survival: first-order-mortality
  %   first order toxico kinetics
  %   hazard rate linear in the internal conc; log_normally distributed NEC
  %
  %% Input
  %  p: (5,1) matrix with parameters values in p(:,1) (see below)
  %  t: (nt,1) matrix with exposure times
  %  c: (nc,1) matrix with concentrations of toxic compound
  %
  %% Output
  %  f: (nt,nc) matrix with survival probabilities

  %% unpack parameters for easy reference
  h = p(1);  % 1/h, blank mortality prob rate (always >0)
  c0 = p(2); % mM, No-Effect-Concentration (external, may be zero)
  b = p(3);  % 1/(h*mM), killing rate
  k = p(4);  % 1/h, elimination rate
  sc = p(5); % -, scatter parameter of log_normal distribution

  %% NEC values
  nC = 5000; fac = exp(5 * sc); C0 = linspace(c0 / fac, c0 * fac, nC);
  dC = C0(2) - C0(1); % step in NEC
  C1 = ones(1, nC);
  
  %% pdf of NEC
  fC0 = exp(- (log(C0/ c0)) .^2 ./ (2 * sc^2)) ./ (sqrt(2 * pi) * sc * C0);
  
  %% initiate output
  nt = length(t); nc = length(c); f = zeros(nt,nc);
  for i = 1:nt   % scan times
    T = t(i);    % current time
    for j = 1:nc % scan concentrations
      C = c(j);  % current concentration
      t0 = -log (max(1e-8, 1 - C0/ max(1e-8, C)))/ k; % no-effect-times
      F = (b/ k) * max(0, exp(-k * t0) - C1 * exp(-k * T)) * C - ...
          b * ((max(0, C1 * C - C0))) .* max(0, C1 * T - t0);
      F = min(1, exp(F)) * exp(-h * T);
      f(i,j) = sum(F .* fC0) * dC;
    end
  end
