%% gammaML
% Calculates ML estimates for the parameters of the gamma distribution

function [par_ML, info] = gammaML(t)
  % created 2023/02/22 by Bas Kooijman
  
  %% Syntax
  % [par_ML, info] = <../gammaML.m *gammaML*> (t)

  %% Description
  % Calculates ML estimates for scale parameter theta and shape parameter alpha for the gamma distribution:
  %    pdf(t)=theta^(-alpha)/gamma(alpha)*t^(alpha-1)*exp(-t/theta); 
  %
  % Input:
  %
  % * t: vector with trials from a gamma distribution
  %
  % Output:
  %
  % * par_ML: 2-vector with ML estimates for the scale parameter teta and shape parameter alpha
  % * info: boolean for success (1) or failure (0)
  
  %% Remarks
  % generate random trials from a gamma distribution with gammarnd;
  % dim(theta) = dim(t) and dim(alpha) = 0; 
  % algorithm from https://tminka.github.io/papers/minka-gamma.pdf
  
  %% Example of use
  % gammaML(gammarnd(2,4,100,1))

  t = t(:); m = mean(t); v = mean(t.^2) - m^2; 
  mlog = mean(log(t)); ml = log(m);
  alpha = 0.5/(ml-mlog); d = 10; i = 0; % initiate ML estimate

  while abs(d)>1e-8  && i < 10
    d = 1/(1/alpha + (mlog-ml+log(alpha)-psi(0,alpha))/(alpha^2*(1/alpha-psi(1,alpha)))) - alpha;
    alpha = alpha + d; i = i+1;
  end
  par_ML= [m/alpha; alpha];
  
  if i==20 
    fprintf('Warning from gammaML: no convergence in 10 steps\n');
    info = 0;
  else
    info = 1;
  end

  %par_ML = [v/m; m^2/v]; % moment estimators

end