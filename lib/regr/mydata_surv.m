% created: 2001/09/11 by Bas Kooijman; modified 2006/05/25
% sample data for surv routines

% set initial parameter estimates
%  (do this first to make this file a script file)
par = [10; 0.3];

% define a function of 1 variable: see 'expon'

data = [0 1 2 3 4; 10 7 5 3 2]';

% show a plot of the function:
  shsurv('expon', par, data)

%% estimate the parameter values:
par_sc = scsurv('expon', par, data) %% using scores
%  or alternatively:
par_nm = nmsurv('expon', par, data) %% using Nelder-Mead
nmregr_options('max_fun_evals', 1e5);
nmregr_options('max_step_number', 1e5);
%  or alternatively: adapt initial par for genetic algorithm
par = [1 1 1e-6 20; 1 1 1e-6 5]; % value (not used), iteration (yes), range: (0,10)
par_ga = gasurv('expon', par, data) %% using a genetic algorithm

%% show goodness of fit:
%   shsurv('expon', par, data)

%% get deviance:
%   dev('expon', par, data)

%% obtain parameter statistics:
%   [cov, cor, sd, d] = psurv('expon', par, data)

%% define a function of 1 variable: see 'expon2'

%% estimate the parameter values:
%   par = scsurv('expon2', [.2 .5]', data, data) %% using scores
