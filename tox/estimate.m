% this script-file illustrates the effect of the estimation criterion on LC50 estimates
% created 2004/04/05 by Bas Kooijman

% exposure times in days
t = [0 1]';

%% concentrations in mug/l
c = [0 .32 5.6 10 18 32 56 100]';

%% surviving individuals
N = [20*ones(1,8);
     20 20 17 8 2 2 0 0];

%% parameter values: first guesses
h = 1e-8; % 1/d, hazard rate in the blank
c0 = 2.77; % mug/l, no-effect concentration
b = 0.3; % 1/(d*mug/l), killing rate
k = 0.72; % 1/d, elimination rate
% collect parameter values in a (4,2) matrix
par = [h, c0, b, k; 0 1 1 1]'; % keep nat. mort. rate fixed

%% link library routines
path(path,'../lib/regr');

%% ML parameter estimation based on the multinomial distribution
p = nmsurv2('fomort', par, t, c, N); % use NM-method for first estimate
[cov, cor, sd, dev] = psurv2('fomort', p, t, c, N); % get statistics
[p, sd] % present ml-estimates and asymptotic standard deviations
l1 = lc50(p([2 3 4],1),t(2)); % get LC50 from parameter values

%% data and model presentation
% shregr2_options('all_in_one', 1);
shregr2_options('default');
shregr2_options('xlabel', 'exposuretime, d');
shregr2_options('ylabel', ' compound, mg/l');
shregr2_options('zlabel', 'fraction of survors');

%% show result graphically
shsurv2('fomort', p, t, c, N);

%  get profile likelihood for the NEC (parameter 2)
%  p = [p, [1 2 1 1]'];
%  proflik = plsurv2('fomort', p, t, c, N, [0 10]);
%  plot(proflik(:,1), proflik(:,2), 'r')


%   estimation based on the weird assumption
%      of a normally distributed scatter with constant variance
N = N./ 20;
p = nmregr2('fomort',par,t,c, N);
[cov, cor, sd, dev] = psurv2('fomort', p, t, c, N); % get statistics
[p, sd] % present ml-estimates and asymptotic standard deviations
l2 = lc50(p([2 3 4],1),t(2)); % get LC50 from parameter values
%  show result graphically
shsurv2('fomort', p, t, c, N);

%  compare LC50 values for ML and least squares estimate
%  notice that the same deterministic model is fitted;
%   only assumptions about stochasticity are different
[l1, l2]
