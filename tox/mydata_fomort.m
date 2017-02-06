%% DEMO: this script-file illustrates the use of fomort
%   for the analysis of toxic effects on the survival of individuals
% created 2002/02/05 by Bas Kooijman

% exposure times in days
t = [0 1 2 3 4 5 6 7]';

% dieldrin concentrations in mug/l
c = [0 .32 5.6 10 18 32 56 100]';

% surviving guppies, data from IMW-TNO
N = [20*ones(1,8); 20*ones(1,6),19,18; ...
     20 20 19 19 19 18 18 18; 20 20 17 15 14 12 9 8; ...
     20 18 15 9 4 4 3 2; 20 18 9 2 1 0 0 0; ...
     20 17 6 1 0 0 0 0; 20 5, zeros(1,6)]';
 
% parameter values: first guesses
h  = 0.008;% 1/d, hazard rate in the blank
c0 = 2.77; % mug/l, no-effect concentration
b  = 0.3;  % 1/(d*mug/l), killing rate
k  = 0.72; % 1/d, elimination rate
par_txt = {'h, 1/d '; 'c0, mug/l '; 'b 1/(d*mug/l)'; 'k, 1/d'};

%% collect parameter values in a (4,1) matrix
par = [h, c0, b, k]'; % indicate all parameters to be estimated
% par = [1e-8, c0, b, k; 0 1 1 1]'; % keep nat. mort. rate fixed at zero

%% parameter estimation
p = nmsurv2('fomort', par, t, c, N); % use NM-method for first estimate
p = scsurv2('fomort', p, t, c, N); % refine estimate with SC-method

[cov, cor, sd, dev] = psurv2('fomort', p, t, c, N); % get statistics

% present ml-estimates and asymptotic standard deviations
printpar(par_txt, p, sd, 'parameters and sd')

%% data and model presentation
shregr2_options('all_in_one', 1);
shregr2_options('default');
shregr2_options('xlabel', 'exposuretime, d');
shregr2_options('ylabel', ' dieldrin, mug/l');
shregr2_options('zlabel', 'fraction of surv guppies');

shsurv2('fomort', p, t, c, N);

figure()
% get profile likelihood for the NEC (parameter 2)
p = [p, [1 2 1 1]'];
proflik = plsurv2('fomort', p, t, c, N, [0 10]);
plot(proflik(:,1), proflik(:,2), 'r', 'linewidth',2)
xlabel('NEC, mug/l')
ylabel('profile likelihood')
