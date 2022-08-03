%% add_noise
% returns data with added lognorm noise

%%
function xNoise = add_noise (x, cv, nr)
  % created by Dina Lika 2016/06/29; modified by Goncalo Marques 2016/07/16, Bas Kooijman 2022/07/30
   
  %% Syntax 
  % xNoise = <../add_noise.m *add_noise*> (x, cv, nr)
  
  %% Description
  % Adds lognorm noise to input data with specified cv
  %
  % Input
  %
  % * x: scalar or vector with data
  % * cv: scalar with coefficient of variation
  % * nr: optional scalar with number of samples to average over (default 1)
  %  
  % Output
  %
  % * xNoise: vector or matrix with data + noise
  
  %% Remarks
  % nr serves to mimick an average over several samples
  % Be aware that by increasing nr the real cv of the result decreases

  if ~exist('nr','var')
    nr = 1;
  end
  
  n = length(x); xNoise = zeros(n,1);
  for i=1:n
   xNoise(i) = mean(gen_lognormal(x(i), (cv * x(i))^2, nr));
  end
end

function val = gen_lognormal(m, v, N)
  % Function that returns values from the log-normal distribution
  mu = log(m^2/ sqrt(v + m^2));
  sigma = sqrt(log(v/ m^2 + 1));
  norm0 = randn(N, 1);
  normm = mu + norm0 * sigma;
  val = exp(normm); 
end