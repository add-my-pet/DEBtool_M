%% wblML
% Calculates ML estimates for the parameters of the Weibull distribution

function [par_ML, info] = wblML(t)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % [par_ML, info] = <../wblML.m *wblML*> (t)

  %% Description
  % Calculates ML estimates for scale parameter lambda and shape parameter k for the Weibull distribution:
  %    pdf(t)=k/lambda*(t/lambda)^(k-1)*exp(-(t/lambda)^k); 
  %    df(t)=1-exp(-(t/lambda)^k). 
  %
  % Input:
  %
  % * t: vector with trials from a Weibull distribution
  %
  % Output:
  %
  % * par_ML: 2-vector with ML estimates for the scale and shape parameter
  % * info: boolean for success (1) or failure (0)
  
  %% Remarks
  % generate random trials from a Weibull distribution with wblrnd;
  % dim(lambda) = dim(t) and dim(k) = 0.
  
  %% Example of use
  % wblML(wblrnd(2,4,100,1))

  par_ML = zeros(1,2); t = t(:); % initiate ML estimates
  wbl = @(shape, t) sum(t.^shape .* log(t))/ sum(t.^shape) - 1/shape - mean(log(t)); % ML fn for shape par

  [par_ML(2), ~, info] = fzero(@(shape) wbl(shape,t), 3);
  par_ML(1) = mean(t.^par_ML(2))^(1/par_ML(2));

end