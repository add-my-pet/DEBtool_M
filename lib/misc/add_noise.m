%% add_noise
% returns data with added lognorm noise

%%
function xNoise = add_noise (x, cv, nr)
   % created by Dina Lika 2016/06/29; 
   % modified by Goncalo Marques 2016/07/16
  %% Syntax 
  % <../add_noise.m *add_noise*>
  
  %% Description
  % Adds lognorm noise to input data
  %
  % Input
  %
  % * x: vector with data
  % * cv: scalar with coefficient of variation
  % * nr: scalar with number of samples to average over
  %  
  % Output
  %
  % * x_noise: vector with data + noise
  
  %% Remarks
  % nr serves to mimick an average over several samples
  % Be aware that by increasing nr the real cv of the result decreases

  xNoise = mean(gen_lognormal(x, (cv * x)^2, nr));
end

function val = gen_lognormal(m, v, N)
  % Function that returns values from the log-normal distribution
  mu = log(m^2/ sqrt(v + m^2));
  sigma = sqrt(log(v/ m^2 + 1));
  val = lognrnd(mu, sigma, N, 1);
end