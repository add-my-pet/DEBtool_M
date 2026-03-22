%% skewNormMom
% moment estimates for of the skew normal distribution

%%
function [loc, scale, shape] = skewNormMom (x)
  % created 2026/03/20 by Bas Kooijman
  
  %% Syntax
  % [loc, scale, shape] = <../skewNormMom.m *skewNormMom*> (x)

  %% Description
  % Calculates the moment-estimates for the skew normal distribution
  %
  % Input:
  %
  % * (n,1)-vector with random trials from a skew normal distribution 
  %
  % Output
  %
  % * loc: scalar with moment-estimate for location parameter
  % * scale: scalar with moment-estimate for scale parameter
  % * shape: scalar with moment-estimate for shape parameter
  
  %% Remarks
  % see https://en.wikipedia.org/wiki/Skew_normal_distribution; cf surv_norm
  
  %% Example of use
  % vsM = read_allStat({'v','s_M'}); logv = log10(vsM(:,1).*vsM(:,2)); 
  % [loc, scale, shape] = skewNormMom (logv);
  
  mu = mean(x); sd = std(x); X = (x-mu)/sd; skew = min(0.99, mean(X.^3)); sgn = sign(skew); skew23 = abs(skew)^(2/3);
  delta = sgn * sqrt(pi/2*skew23/(skew23 + ((4-pi)/2)^(2/3)));
  scale = sd/ sqrt(1 - 2 * delta^2/ pi);
  loc = mu - scale * delta * sqrt(2/ pi);
  shape = delta/ sqrt(1 - delta^2);
  
