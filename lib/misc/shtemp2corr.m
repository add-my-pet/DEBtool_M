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
  

  global t_1 tpars;
  t_1 = T_1; tpars = Tpars;

  T_A = Tpars(1); % Arrhenius temperature
  T_L = Tpars(2); % Lower temp boundary
  T_H = Tpars(3); % Upper temp boundary
  %T_AL = Tpars(4); % Arrh. temp for lower boundary
  %T_AH = Tpars(5); % Arrh. temp for upper boundary

  hold on;
  title ('temperature dependence of rates');
  xlabel('10^4/temp, K'); ylabel('log_{10} corr factor');
  
  T_LL = fzero('findt', T_L);
  T_HH = fzero('findt', T_H + 10);
  iT_L = linspace(1/T_LL, 1/T_L, 20);
  TC_L = tempcorr (1./iT_L, T_1, Tpars);
  iT   = linspace(1/T_L, 1/T_H, 60);
  TC   = tempcorr (1./iT, T_1, Tpars);
  iT_H = linspace(1/T_H, 1/T_HH, 20);
  TC_H = tempcorr (1./iT_H, T_1, Tpars);

  % semilogy(10^4*iT_H, TC_H, 'r', 10^4*iT, TC, 'g', 10^4*iT_L, TC_L, 'b');
  % does not work;
  plot(10^4*iT_H, log10(TC_H), 'r', ...
       10^4*iT, log10(TC), 'g', 10^4*iT_L, log10(TC_L), 'b');
  
  
  TC_L = exp(T_A/T_1 - T_A/T_L); TC_H = exp(T_A/T_1 - T_A/T_H);
  % semilogy([10^4/T_L, 10^4/T_L], [0.01, TC_L], 'b', ...
	%   [10^4/T_L, 10^4/T_H], [TC_L, TC_H], 'g', ...
	%   [10^4/T_H, 10^4/T_H], [0.01, TC_H], 'r');
  plot([10^4/T_L, 10^4/T_L], log10([0.01, TC_L]), 'b', ...
	   [10^4/T_L, 10^4/T_H], log10([TC_L, TC_H]), 'g', ...
	   [10^4/T_H, 10^4/T_H], log10([0.01, TC_H]), 'r');

