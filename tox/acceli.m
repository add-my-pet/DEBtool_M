%% acceli
% 

%%
function [f1, f2]= acceli(p,tc1,tc2)
  %  created at 2002/01/20 by Bas Kooijman
  
  %% Syntax
  % [f1, f2]= <../acceli *acceli*>(p,tc1,tc2)
  
  %% Description
  % calculates internal concentrations given a constant external one
  %    on the basis of first order kinetics
  %    initial condition for first data set: internal conc. is 0
  %    initial condition for second set: internal conc. equals that at the
  %      highest time of the first data set
  %    external concentration in second data set is zero
  %
  % Input
  %
  % * p: (3,1) vector with parameters
  %    (1) ke: elimination rate
  %    (2) BCF: bioconcentration factor
  %    (3) c: external concentration
  % * tc1: (nt1,2) matrix with times, internal concentrations
  % * tc2: (nt2,2) matrix with times, internal concentrations
  %
  % Output
  %
  % * f1: (nt1,1) matrice with internal concentrations
  % * f2: (nt2,1)- matrice with internal concentrations


  % unpack parameters
  ke = p(1); BCF = p(2); c = p(3);

  f1 = BCF*c*(1-exp(-tc1(:,1)*ke));
  f2 = max(f1)*exp(-tc2(:,1)*ke);