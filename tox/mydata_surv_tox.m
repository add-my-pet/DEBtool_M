%% Demo script
% 1st order survival for guppies as function of time for different dieldrin
% concentrations

% dieldrin concentrations
c = [0 .32 5.6 10 18 32 56 100]';
% exposure times
t = [0 1 2 3 4 5 6 7]';
% surviving guppies
N = [20*ones(1,8); 20*ones(1,6),19,18; ...
     20 20 19 19 19 18 18 18; 20 20 17 15 14 12 9 8; ...
     20 18 15 9 4 4 3 2; 20 18 9 2 1 0 0 0; ...
     20 17 6 1 0 0 0 0; 20 5, zeros(1,6)]';

% starting values of parameters: 
par = [1e-8 2.77 .03 .72;0 1 1 1]';
par_txt = {'blank mortality prob rate'; 'NEC'; 'killing rate'; 'elimination rate'};

p = nmsurv2('order1',par,t,c,N);
p = scsurv2('order1',p,t,c,N);
[cov,cor,sd,dev] = psurv2('order1',p,t,c,N);

printpar(par_txt, p, sd)

shregr2_options('all_in_one',0);
shregr2_options('Range', 1, [0 8.5]);
shregr2_options('Range', 2, [0 100]);
shsurv2('order1',p,t,c,N);
