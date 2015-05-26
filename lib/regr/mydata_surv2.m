% created: 2001/09/13 by Bas Kooijman; modified 2006/05/26
% sample data for surv2 routines

%% set initial parameter estimates
%  (do this first to make this file a script file)
par = [0.3 1]';

%% example of function definition: expony

%% show a plot of the function:
%   shsurv('expony', par, [0 3]', [0 5]')

t = [0 1 2 3 4]';
y = [0.5 1 2]';
surv = [10 10 9 8 8; 10 7 5 4 3; 10 4 1 0 0;]';

%% estimate the parameter values:
par = scsurv2('expony', par, t, y, surv) %% using scores
% or alternatively for a genetic algorithm:
% first adjust parameter values
% value (not used), iteration (yes), range: (1e-6,1) & (1e-6,5)
par = [.3 1 1e-6 1; 1 1 1e-6 5];
gasurv2('expony', par, t, y, surv) %% using a genetic algorithm
% or alternatively:
par = nmsurv2('expony', par, t, y, surv) %% using Nelder-Mead

%% show goodness of fit:
%   shsurv2('expony', par, t, y, surv)

%% get deviance:
%   dev2('expony', par, t, y, surv)

%% obtain parameter statistics:
%   [cov, cor, sd, d] = psurv2('expony', par, t, y, surv)
