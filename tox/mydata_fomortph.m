% this script-file illustrates the use of fomortph
%   for the analysis of toxic effects on the survival of individuals
%   where the compound affects the pH
% created 2002/01/11 by Bas Kooijman

% exposure times in days
t = [0 1 2 3 4 5 6 7]';
% compound concentrations in mug/l, and pH values
c = [0 .32 5.6 10 18 32 56 100; 7.5 7.5 7.4 7.2 6.9 6.6 6.3 6.0]';
% surviving fish
N = [20*ones(1,8); 20*ones(1,6),19,18; ...
     20 20 19 19 19 18 18 18; 20 20 17 15 14 12 9 8; ...
     20 18 15 9 4 4 3 2; 20 18 9 2 1 0 0 0; ...
     20 17 6 1 0 0 0 0; 20 5, zeros(1,6)]';
% parameter values: first guesses
h = 0.008; % 1/d, hazard rate in the blank
c0 = 2.77; % mug/l, no-effect concentration of molecular form
c0i= 1.00; % mug/l, no-effect concentration of ionic form
b  = 0.3; % 1/(d*mug/l), killing rate of molecular form
bi = 0.1; % 1/(d*mug/l), killing rate of inonic form
k = 0.72; % 1/d, elimination rate
pK = 9; % M, ionization constant
% collect parameter values in a (7,2) matrix
p = [h, c0, b, k, c0i, bi, pK; 1 1 1 1 1 1 0]';
% indicate that pK should not be estimated

% parameter estimation
 p = nmsurv2('fomortph', p, t, c, N); % use NM-method for first estimate 
 p = nmsurv2('fomortph', p, t, c, N); % continue use of NM-method 
 p = scsurv2('fomortph', p, t, c, N); % refine estimate with SC-method
 [cov, cor, sd, dev] = psurv2('fomortph', p, t, c, N); % get statistics
 [p(:,1), sd] % present ml-estimates and asymptotic standard deviations

% data and model presentation
shregr2_options('plotnr',1); % don't use %2, because we don't fit a surface
shregr2_options('xlabel', 'exposuretime, d');
shregr2_options('ylabel', 'compound, mug/l');
shregr2_options('zlabel', 'fraction of surv fish');

shsurv2('fomortph', p, t, c, N);
