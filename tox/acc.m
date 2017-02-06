%% acc
% calculates internal concentrations given a constant external one

%%
function f = acc(p,tc)
  %  created at 2002/02/05 by Bas Kooijman
  
  %% Syntax
  % f = <../acc.m *acc*>(p,tc) 
  
  %% Description
  % calculates internal concentrations given a constant external one,
  % on the basis of first order kinetics.
  % Initial condition: internal conc. is 0
  %
  % Input
  %
  % * p: (3,1)-vector with parameters:
  %    (1) ke: elimination rate
  %    (2) BCF: bioconcentration factor
  %    (3) c: external concentration
  % * tc: (nt,2) matrix with times, internal concentrations
  %
  % Output
  %
  % * f: (nt,1)-matrix with internal concentrations


  % unpack parameters
  ke = p(1); BCF = p(2); c = p(3);

  f = BCF*c*(1-exp(-tc(:,1)*ke));
