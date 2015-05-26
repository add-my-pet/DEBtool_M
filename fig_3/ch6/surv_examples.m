%% fig:surv_examples;
%% bib:Data from Thea Adema
%% out: ddgupl,ddgupr,dcangl,dcangr,kcrod30l,kcrod30r

%% number of survivors as function of concentration and exposure time


%% Poecilia reticilata in dieldrin 
%% ddgupl.eps ddgupr.eps
c_dd = [0 3.2 5.6 10 18 32 56 100]'; % mug/l
t_dd = [0 1 2 3 4 5 6 7]'; % d
n_dd = [20 20 20 20 20 20 20 20;
        20 20 20 20 18 18 17  5;
        20 20 19 17 15  9  6  0;
        20 20 19 15  9  2  1  0;
        20 20 19 14  4  1  0  0;
        20 20 18 12  4  0  0  0;
        20 19 18  9  3  0  0  0;
        20 18 18  8  2  0  0  0];

%% Chaetogammarus marinus in 3,4-dichloroaniline 
%% dcangl.eps dcangr.eps
c_da = [0 1.8 3.2 5.6 10 18]'; % mg/l
t_da = [0 2 4 7 9 11 14]'; % d
n_da = [50 50 50 50 50 50;
	49 50 50 50  7  0;
	48 50 34 10  0  0;
	47 38  8  0  0  0;
	47 29  3  0  0  0;
	47 24  0  0  0  0;
	46 22  0  0  0  0];

%% Daphnia magna in potassium dichromate
%% kcrod30l.eps kcrod30r.eps
c_pd = [0 0.1 0.18 0.32 0.56 1]'; %  mg/l
t_pd = [0 2 5 7 9 12 14 16 19 21]'; % d
n_pd = [50 50 50 50 50 50;
	50 50 50 50 50 48;
	50 50 50 50 48 36;
	50 50 50 50 48 35;
	49 50 50 50 48 31;
	49 50 50 50 40 15;
	49 50 50 48 32  9;
	49 50 50 47 30  3;
	49 50 50 47 23  0;
	49 50 50 45 16  0];

par_txt = {'blank mort rate';'NEC';'killing rate';'elim rate'};

%% parameter estimation
nmregr_options('report',0); scsurv_options('report',0);
p_dd = [1e-8 0; 4.49 1; 0.038 1; .712 1]; 
p_dd = nmsurv2('fomort', p_dd, t_dd, c_dd, n_dd); 
p_dd = scsurv2('fomort', p_dd, t_dd, c_dd, n_dd); 
[cov, cor, sd, dev] = psurv2('fomort', p_dd, t_dd, c_dd, n_dd); 
%% present ml-estimates and asymptotic standard deviations
fprintf('P. reticulata in dieldrin \n');
printpar(par_txt, p_dd, sd)

p_da = [1e-8 0; 1.41 1; 0.4 1; .335 1]; 
p_da = nmsurv2('fomort', p_da, t_da, c_da, n_da); 
p_da = scsurv2('fomort', p_da, t_da, c_da, n_da); 
[cov, cor, sd, dev] = psurv2('fomort', p_da, t_da, c_da, n_da); 
%% present ml-estimates and asymptotic standard deviations
fprintf('C. marinus in 3,4-dichloroaniline \n');
printpar(par_txt, p_da, sd) 

p_pd = [1e-8 0; 0.26 1; 0.4 1; .125 1]; 
p_pd = nmsurv2('fomort', p_pd, t_pd, c_pd, n_pd); 
p_pd = scsurv2('fomort', p_pd, t_pd, c_pd, n_pd); 
[cov, cor, sd, dev] = psurv2('fomort', p_pd, t_pd, c_pd, n_pd); 
%% present ml-estimates and asymptotic standard deviations
fprintf('D. magna in potassium dichromate \n');
printpar(par_txt, p_pd, sd) 
nmregr_options('report',1); scsurv_options('report',0);

% gset term postscript color solid 'Times-Roman' 35

% gset output 'ddgup.ps'
shregr2_options('default');
shregr2_options('plotnr',1);
shregr2('fomort',p_dd, t_dd, c_dd, n_dd/20);
title ('P. reticulata in dieldrin')
fprintf('hit a key to proceed \n');
pause;

% gset output 'dcang.ps'
shregr2_options('default');
shregr2_options('plotnr',1);
shregr2('fomort',p_da, t_da, c_da, n_da/50);
title('C. marinus in 3,4-dichloroaniline')
fprintf('hit a key to proceed \n');
pause;

% gset output 'kcrod30.ps'
shregr2_options('default');
shregr2_options('plotnr',1);
shregr2('fomort',p_pd, t_pd, c_pd, n_pd/50);
title('D. magna in potassium dichromate')
