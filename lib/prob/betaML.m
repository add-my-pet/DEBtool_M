%% betaML
% Calculates ML estimates for the parameters of the beta distribution

function [par_ML, info] = betaML(x)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % [par_ML, info] = <../betaML.m *betaML*> (x)

  %% Description
  % Calculates ML estimates for parameters alpha and beta for the beta distribution:
  %    pdf(x)=x^(alpha-1)(1-x)^(beta-1)/ B(alpha, beta); 
  %    df(x)=I_x(alpha, beta). 
  %
  % Input:
  %
  % * x: vector with trials from a beta distribution
  %
  % Output:
  %
  % * par_ML: 2-vector with ML estimates for the parameters alpha and beta
  % * info: boolean for success (1) or failure (0)
  
  %% Remarks
  % generate random trials from a beta distribution with betarnd;
  % dim(alpha) = 0 and dim(beta) = 0.
  
  %% Example of use
  % betaML(betarnd(.2,.4,100,1))
  
  x = x(:);
  if max(x) >= 1 || min(x) <= 0
    fprintf('warning from betaML: argument values are outside interval (0,1)\n');
    par_ML = []; info = 0; return
  end

  % initiate ML estimates with moment estimators
  m = mean(x); v = mean(x.^2)-m^2; mlog  = mean(log(x)); mlog1  = mean(log(1-x)); 
  alpha = m * (m * (1 - m)/ v - 1);
  beta = (1 - m) * (m * (1 - m)/ v - 1); 
  
  % obtain ML estimates
  [par_ML, ~, info] = fsolve('betaML_dL', [alpha; beta], [], mlog, mlog1);

end
