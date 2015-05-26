% created ar 2002/02/05 by Bas Kooijman
% illustrates use of calculation of accumulation/elimination curves

% accumulation phase
tc1 = [0 1 2 3 4 5; 0 3 4 4.5 4.75 4.9]'; % exposure times, internal conc's
% elimination phase 
tc2 = [0 1 2 3 4 5; 5 3 2 1 0.5 0.25]'; % exposure times, internal conc's
par = [.1 5 1; 1 1 0]'; % initial estimates for elim rate BCF,
% given external concentration of 1 mM

p = nmregr('acceli', par, tc1, tc2);
shregr_options('default');
shregr_options('xlabel', 1, 'time, d');
shregr_options('xlabel', 2, 'time, d');
shregr_options('ylabel', 1, 'internal conc., mmol/g');
shregr_options('ylabel', 2, 'internal conc., mmol/g');
shregr('acceli', p, tc1, tc2);
[cov, cor, sd] = pregr('acceli', par, tc1, tc2);
[p, sd]