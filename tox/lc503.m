%% lc503
% calculates parameters given 3 lc50 values

%%
function [cbk, val, info] = lc503 (tlc50, p)
  %  created 2002/03/11 by Bas Kooijman/ Tjalling Jager
  
  %% Syntax
  % [cbk, info] = <../lc503.m *lc503*> (tlc50, p)
  
  %% Description
  % Calculates parameter values, given 3 lc50's
  %
  % Input
  %
  % * tlc50: (3,2)-matrix with exposure times, lc50's
  % * p: 3-vector with initial estimates for NEC, killing rate, elim rate
  %
  % Output
  %
  % * cbk: 3-vector with final values for NEC, killing rate and elimination rate
  % * info: scalar with indicator for failure (0) or success (1) of numerical procedure
  %
  %% Example of use
  % for an appropriate (3,2) matrix tc: 
  % [p, info] = lc503(tc, [1, 1, .1]). 
  % The effect is very similar to p = nmregr("lc50", [1, 1, .1]', tc), but lc503 is much faster and exact. 
  
  
  t = tlc50(:,1); c = tlc50(:,2);
  [cbk, val, info] = fsolve('fncbk',p(:), t, c);  
  
