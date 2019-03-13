%% shtemp2corr
% Plots correction factor as a function of temperature.

%%
function shtemp2corr (T_1, Tpars)
  %  created at 2002/04/10 by Bas Kooijman
  
  %% Syntax
  % <../shtemp2corr.m *shtemp2corr*> (T_1, Tpars)
  
  %% Description
  % Plots correction factor logarithmically as a function of inverse absolute temperature.
  % The green section shows the temperature range for "standard" physiological adaptation; 
  % the red section corresponds with the high-temperature inactivation, the blue section with low-temperature inactivation.
  %
  % The temperature range that is plotted corresponds with correction factors larger than 0.01.
  %
  % All rate parameters are multiplied with this temperature correction factor. 
  % If the actual temperature equals the reference temperature, this factor is one, irrespective of the values of the temperature parameters.

  %% Example of use
  % clear all; pars_animal; shtemp2corr
  
  T_A = Tpars(1); % Arrhenius temperature
  T_L = Tpars(2); % Lower temp boundary
  T_H = Tpars(3); % Upper temp boundary
  T_AL = Tpars(4); % Arrh. temp for lower boundary
  T_AH = Tpars(5); % Arrh. temp for upper boundary

  hold on;
  title ('temperature dependence of rates');
  xlabel('10^4/temp, K'); ylabel('log_{10} corr factor');
  
  % 5-parameter case
  T_LL = fzero(@findt, T_L, [], T_1, Tpars);
  T_HH = fzero(@findt, T_H + 10, [], T_1, Tpars);
  iT_L = linspace(1/T_LL, 1/T_L, 20);
  TC_L = tempcorr(1./iT_L, T_1, Tpars);
  iT   = linspace(1/T_L, 1/T_H, 60);
  TC   = tempcorr (1./iT, T_1, Tpars);
  iT_H = linspace(1/T_H, 1/T_HH, 20);
  TC_H = tempcorr (1./iT_H, T_1, Tpars);

  plot(10^4*iT_H, log10(TC_H), 'r', ...
       10^4*iT, log10(TC), 'g', ...
       10^4*iT_L, log10(TC_L), 'b');
  
  % 3-parameter case low temp
  Tpars = [T_A; T_L; T_AL];
  TC_L = tempcorr (1./iT_L, T_1, Tpars);
  iT   = linspace(1/T_L, 1/T_HH, 100);
  TC   = tempcorr (1./iT, T_1, Tpars);
  plot(10^4*iT, log10(TC), 'g', ...
       10^4*iT_L, log10(TC_L), 'b');
   
  % 1-parameter case
  iT   = linspace(1/T_LL, 1/T_HH, 120);
  TC   = tempcorr (1./iT, T_1, T_A);
  plot(10^4*iT, log10(TC), 'g');

  % 3-parameter case high temp
  iT   = linspace(1/T_LL, 1/T_H, 100); 
  TC = exp(T_A/ T_1 - T_A .* iT) .* ...
	     (1 + exp(T_AH/ T_H - T_AH  / T_1)) ./ ...
	     (1 + exp(T_AH/ T_H - T_AH .* iT  ));
  TC_H = exp(T_A/ T_1 - T_A .* iT_H) .* ...
	     (1 + exp(T_AH/ T_H - T_AH  / T_1)) ./ ...
	     (1 + exp(T_AH/ T_H - T_AH .* iT_H));
  plot(10^4.*iT, log10(TC), 'g', ...
       10^4.*iT_H, log10(TC_H), 'r');

end

function f = findt (T, T_1, Tpars)
  % function to find temp for which tempcorr is 0.01
  f = log(tempcorr(T, T_1, Tpars)) - log(0.01);
end
