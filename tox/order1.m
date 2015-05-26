function f = order1 (p, t, c)
  %  standard effects on survival:
  %   first order toxico kinetics
  %   hazard rate linear in the internal conc
  %  unpack parameters for easy reference
  h = p(1); % blank mortality prob rate
  c0 = p(2); % NEC
  b = p(3); % killing rate
  k = p(4); % elimination rate

  t0 = -log(max(1e-8,1-c0./max(1e-8,c')))/k; % no-effect-time
  c1 = ones(1,max(size(c)));
  t1 = ones(max(size(t)),1);
  f = (b/k)*max(0,t1*e.^(-k*t0) - e.^(-k*t)*c1).*(t1*c') - ...
      b*(t1*(max(0,c-c0)')).*max(0,t*c1 - t1*t0);
  f = min(1,e.^f).* (e.^(-h*t)*c1);