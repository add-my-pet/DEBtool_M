%% order1
% first order effect on survival

%%
function f = order1 (p, t, c)
% Bas Kooijman

  %% syntax
  % f = <../order1.m *order1*> (p, t, c)

  %% Description
  % standard effects on survival:
  %
  % * first order toxico kinetics
  % * hazard rate linear in the internal conc
  % * unpack parameters for easy reference
  %
  % Input:
  %
  % * p: 4-vector with parameters h, c0, b, k
  % * t: (nt,1) matrix with exposure times
  % * c: (nc,1) matrix with concentrations of toxic compound
  % 
  % Output:
  %
  % * f: (nt,nc) matrix with survival probability
  
  h  = p(1); % blank mortality prob rate
  c0 = p(2); % NEC
  b  = p(3); % killing rate
  k  = p(4); % elimination rate

  t0 = -log(max(1e-8,1-c0./max(1e-8,c')))/k; % no-effect-time
  c1 = ones(1,max(size(c)));
  t1 = ones(max(size(t)),1);
  f = (b/k)*max(0,t1*exp(-k*t0) - exp(-k*t)*c1).*(t1*c') - ...
      b*(t1*(max(0,c-c0)')).*max(0,t*c1 - t1*t0);
  f = min(1,exp(f)).* (exp(-h*t)*c1);