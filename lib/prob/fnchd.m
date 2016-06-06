%% fnchd
% Obtains expected value of Fisher's non-central hypergeometric distribution

%%
function [E F G] = fnchd (m0, m1, n, b)
  %  created by Bas Kooijman @ 2008/02/23
  
  %% Syntax
  % [E F G] = <../fnchd.m *fnchd*> (m0, m1, n, b)

  %% Description
  % Obtains the expected value of Fisher's non-central hypergeometric distribution, 
  %   its appoximation, and the correponding mean of the binomial distribution for small smaples sizes. 
  %
  % Input:
  %
  % * m0: number of objects of type 0
  % * m1: number of objects of type 1
  % * n: number of objects in the sample
  % * b: odds ratio for objects of type 0, relative to that of type 1
  %
  % Output:
  %
  % * E: mean of Fisher's non-central hypergeometric distribution
  % * F: an approximation of the mean based on the modus
  % * G: the mean of the corresponding binomial distr for large m0 and m1
  
  %% Example of use
  % fnchd(12, 5, 3, 1.8)
  
  if m0 + m1 < n % sample size cannot exceed the number of objects
    E = []; F = [], G = [];
    return
  end
  
  y = max(0,n - m1):min(n,m0); % support
  E = bincoeff(m0, y) .* bincoeff(m1, n - y) .* b .^ y;
  E = sum(E .* y)/ sum(E);
  
  B = n - m1 - (m0 + n) * b;
  F = - 2 * m0 * n * b / (B - sqrt(B * B - 4 * (b - 1) * m0 * n * b));
  
  G = n * m0 * b/ (m0 * b + m1);