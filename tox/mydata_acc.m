% created ar 2002/02/05 by Bas Kooijman
% illustrates use of calculation of accumulation curves

tc = [0 1 2 3 4 5; 0 3 4 4.5 4.75 4.9]'; % exposure times, internal conc's
par = [.1 5 1; 1 1 0]'; % initial estimates for elim rate BCF,
% given external concentration of 1 mM


p = nmregr('acc', par, tc); % obtain parameter estimates

shregr_options('default'); % set plot options
shregr_options('xlabel', 'time, d');
shregr_options('ylabel', 'internal conc., mmol/g');
shregr('acc', p, tc); % show fit

[cov cor sd] = pregr('acc', p, tc); % calculate standard deviations


[p(:,1), sd] %% show parameters and standard deviations



% see mydata_acceli for the case where accumulation and elimination
%   data are available
