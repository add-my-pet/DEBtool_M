%% gammaStat
% mean and variance of the gamma distribution

function [mean, var] = gammaStat(theta,alpha)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % [mean, var] = <../gammaStat.m *gammaStat*> (theta,alpha)

  %% Description
  % Calculates mean and variance of  the gamma distribution:
  %    pdf(t)=theta^(-alpha)/gamma(alpha)*t^(alpha-1)*exp(-t/theta); 
  %
  % Input:
  %
  % * theta: scalar with scale parameter; dim(theta)=dim(t)
  % * alpha: scalar with shape parameter; dim(alpha)=0
  %
  % Output:
  %
  % * mean: scalar with mean
  % * var: scalar with variance
  
  %% Remarks
  % generate random trials from a gamma distribution with gammrnd and ML estimates with gammaML;
  
  %% Example of use
  % gammaStat(2,3)

  mean = theta * alpha;
  var = theta^2 * alpha;

end