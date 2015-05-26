% created: 2001/08/28 by Bas Kooijman; modified 2006/05/28
%% sample data for regr routines

% we need 'cat' from DEBtool/lib/misc for nmregr and garegr
% edit path if required

% example of function definition; here a hyperbola
% set initial parameter estimates
%  (do this first to make this file a script file)
hpars = [3.5 2.8]';

%% show a plot of the function:
% shregr('hyp', hpars,[0 3]')

data = [0.1 1 2 3 4; 0.1 1 1.8 2 2.4]';

%% define a function of 1 variable: see 'hyp'

%% estimate the parameter values:
%   nrregr_options('max_step_size',.1);
hpars = [3.5 1; 2.8 1];
% pars = nrregr('hyp', hpars, data) %% using Newton-Raphson
%  or alternatively:
%   pars = nmregr('hyp', hpars, data) %% using Nelder-Mead
%  or alternatively:
% pars = nmvcregr('hyp', pars, data) %% using Nelder-Mead with sd propto mean

%% using genetic algorithm (not advisable in this simple case)
garegr_options('max_step_number',500);
% adjust parameter settings for application in garegr
hpars = [3.5 1 1e-6 10; 2.8 1 1e-6 5];
% the initial values 3.5 & 2.8 are not used
% column 2 indicates iteration in both parameters
% only the ranges (1e-6,10) & (1e-6,5)
% pars = garegr('hyp', hpars, data) %% using genetic algorithm
% now run nrregr on the result op garegr for 'fine-tuning'
% pars = nrregr('hyp', pars, data) %% using genetic algorithm

%% show goodness of fit:
% shregr('hyp', pars, data)

%% get weighted sum of squared deviations:
%   ssq('hyp', pars, data)

%% obtain parameter statistics:
%   [cov, cor, sd, ss] = pregr('hyp', pars, data)

%% Another example using the same data matrix:
% define another function of 1 variable: see 'bert'

% fix parameter number 2 
%  bpars = [0 3 .5; 1 0 1]';

% p = nrregr('bert', bpars, data)
% shregr('bert', p, data)
% [cov, cor, sd, ss] = pregr('bert', p, data)

%% Another example with two data sets;
%  The example is silly because the data sets have no parameters
%  in common, so there is no reason to combine the functions in a single definition

% set initial parameter values, and fix parameter number 3
hbpars = [1 3 0 3 .5; 1 1 0 1 1]';

% obtain parameter estimates:
p = nrregr('hypbert', hbpars, data, data)
% show regression of each data set:
shregr_options('default'); shregr('hypbert', p, data, data)
% show regression results in one graph:
shregr_options('all_in_one', 1); shregr('hypbert', p, data, data) 
