%% bincoeff
% calculates the bionomial coefficient n over k

%%
function nk = bincoeff(n,k)
  % created by Bas Kooijman at 2008/02/28
  
  %% Syntax
  % nk = <../bincoeff.m *bincoeff*> (n,k)
  
  %% Description
  % Calculates the bionomial coefficient n over k
  %
  % Input:
  %
  % * n: scalar or m-vector
  % * k: scalar or m-vector
  %
  % Output:
  %
  % * nk: scalar or m-vector
  
  %% Example of use
  % bincoeff(6,4)
  
  nk = exp(gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1));