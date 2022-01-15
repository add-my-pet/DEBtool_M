%% lt503 
% calculates parameter values, given 3 lt50's 

%%
function [cbk, err] = lt503 (clt50, p)
  %  created 2014/01/10 by Bas Kooijman
  
  %% Syntax
  % [cbk, err] = <../lt503.m *lt503*>(clt50, p)
  
  %% Description
  %  calculates parameter values, given 3 lt50's
  %
  % Input
  %
  % * clt50: (3,2)-matrix with concentrations, lt50's
  % * p: 3-vector with initial estimates for NEC, killing rate, elim rate
  %
  % Output
  %
  % * cbk: 3-vector with final values for NEC, killing rate and elimination rate
  % * err: scalar with indicator for failure (0) or success (1) of numerical procedure
  
  %% Example of use
  % for an appropriate (3,2) matrix tc: 
  % [p, err] = <../lt503.m *lt503*>(tc, [1, 1, .1]). 
  
  
  %opt = optimset('display', 'off', 'TolFun', 1e-16);
  c = clt50(:,1); t = clt50(:,2);
  [cbk, fl, err] = fsolve('fncbk', p, c, t);
  cbk = reshape(cbk, 3, 1);
  
  % subfunction
  
  function f = fncbk(cbk, c, t)
    % unpack cbk
  C0 = cbk(1); Bk = cbk(2); Ke = cbk(3);
  
  t0 = - log(max(1e-12,1 - C0./ c))/ Ke;
  f = log(2) + c .* (exp(-Ke * t0) - exp(-Ke * t)) * Bk/ Ke - ...
      Bk * (c - C0) .* (t - t0);
