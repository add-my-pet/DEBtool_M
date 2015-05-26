function f = grpop(p, t, c)
  %  created 2002/02/05 by Bas Kooijman
  %
  %% Description
  %  growth effects on population growth (of micro-organisms)
  %   toxico kinetics is instantaneous
  %   growth costs linear in (internal) concentration
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

  %% Code
  %  unpack parameters for easy reference
  c0 = p(1);  % mM, No-Effect-Concentration (external, may be zero)
  cC = p(2);  % mM, tolerance concentration
  N0 = p(3);  % %, initial population size
  r  = p(4);  % 1/h, specific population growth rate

  rc = r./(1+max(0,(c'-c0)/cC)); % (1,nc)-vector with pop growth rates
  f = N0*exp(t*rc); % (nt,nc)-matrix with population size
