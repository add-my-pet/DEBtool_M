function nk = bincoeff(n,k)
  %  created by Bas Kooijman at 2008/02/28
  %
  %% Description
  %  calculates the bionomial coefficient n over k
  %
  %% Input
  %  n: scalar or m-vector
  %  k: scalar or m-vector
  %
  %% Output
  %  nk: scalar or m-vector

  nk = exp(gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1));