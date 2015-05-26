function f = adpop(p, t, c)
  %  created 2002/02/05 by Bas Kooijman
  %
  %% Description
  %  adaptation effects on population growth (of micro-organisms)
  %   toxico kinetics is instantaneous
  %   hazard rate linear in (internal) concentration
  %     during initial time increment only
  %
  %% Input
  %  p: (4,k) matrix with parameters values in p(:,1) (see below)
  %  t: (nt,1) matrix with exposure times
  %  c: (nc,1) matrix with concentrations of toxic compound
  %
  %% Output
  %  f: (nt,nc) matrix with population size
  %
  %% Example of use 
  %  see mydata_pop

  %% unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cC = p(2);  % mM, tolerance concentration
  N0 = p(3);  % %, initial population size
  r  = p(4);  % 1/h, specific population growth rate

  t1 = 1 + 0 * t; % (nt,1)-vector with ones
  c1 = 1 + 0 * c'; %(1,nc)-vector with ones
  s = max(0, (c'-c0)/cC); % (1,nc)-vector with stress values
  f = N0*(exp(r*t*c1 - t1*s) + 1 - exp(-t1*s));
      %% (nt,nc)-matrix with population size