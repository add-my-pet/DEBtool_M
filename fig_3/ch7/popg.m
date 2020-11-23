%% fig:popg
%% bib:SchuLipe64,Senn89
%% out:SchuLipe64,Senn89

%% spec growth rate as function of substrate concentration in E. coli

%% wild strain, bib:SchuLipe64
cr_w = [5.1  0.059;
	8.3  0.091;
	13.3 0.124;
	20.3 0.177;
	30.4 0.241;
	37   0.302;
	43.1 0.358;
	58   0.425;
	74.5 0.485;
	96.5 0.546;
	112  0.61 ;
	161  0.662;
	195  0.725;
	266  0.792;
	386  0.852];

cr_W = [ 6  0.06;
	13  0.12;
	33  0.24;
	40  0.31;
	64  0.43;
	102 0.53;
	122 0.6 ;
	153 0.66;
	170 0.69;
	221 0.71;
	210 0.73];
%% interchange colums, because the concentration is measured
%%  while the growth rate is imposed
rc_w = [cr_W(:,[2 1]); cr_w(:,[2 1])];

%% glucose-adapted strain bib:Senn89
cr_a = [0.016  0.2 ;
	0.0167 0.21;
	0.032  0.3 ;
	0.0372 0.3 ;
	0.0456 0.4 ;
	0.0549 0.4 ;
	0.0526 0.49;
	0.1072 0.5 ;
	0.1942 0.56;
	0.1813 0.59;
	0.1446 0.6 ;
	0.2063 0.6 ;
	0.2295 0.65;
	0.2752 0.65;
	0.3339 0.68;
	0.436  0.69;
	0.4354 0.7 ;
	0.5728 0.71;
	0.4956 0.74;
	0.6482 0.75;
	0.8435 0.76;
	0.8642 0.76;
	0.9341 0.8 ;
	1.234  0.84];
% interchange colums, because the concentration is measured
%  while the growth rate is imposed
rc_a = cr_a(:,[2 1]);

%% estimate parameters
nmregr_options('default')
par_txt = {'sat constant K'; 'res turnover k_E'; 'scaled length l_d'; ...
	   'investment ratio g'; 'max throughput rate'; 'time in sample'};

p_w = [562 1; 1.2 1; .001 0; .2 0; .9 0; 0 0];
p_w = nmregr('conc_v1', p_w, rc_w);
[cov cor sd] = pregr('conc_v1', p_w, rc_w);
printpar(par_txt, p_w, sd)

r   = linspace(0,.85,100)';
X_w = conc_v1 (p_w(:,1), r);

p_a = [.9 1; 1.2 1; .001 0; .2 0; .9 0; 0 0];
p_a = nmregr('conc_v1', p_a, rc_a);
[cov cor sd] = pregr('conc_v1', p_a, rc_a);
printpar(par_txt, p_a, sd);

p_a1 = [45 1; 5.2 1; .001 0; .2 0; .9 0; 4.6 1];
p_a1 = nmregr('conc_v1', p_a1, rc_a);
[cov cor sd] = pregr('conc_v1', p_a1, rc_a);
printpar(par_txt, p_a1, sd);

X_a  = conc_v1 (p_a(:,1), r);
X_a1 = conc_v1 (p_a1(:,1), r);

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,2,1)
%% gset output 'SchuLipe64.ps'
plot(cr_w(:,1), cr_w(:,2), '.g', cr_W(:,1), cr_W(:,2), '.g', X_w, r, 'r')
title('E. coli, wild type')
xlabel('glucose. mg/l')
ylabel('spec pop growth rate, 1/h')

subplot(1,2,2)
%% gset output 'Senn89.ps'
plot(X_a, r, 'r', X_a1, r, 'b',cr_a(:,1), cr_a(:,2), '.g')
legend('time in sample =  0', 'time in sample > 0')
title('E. coli, glucose limited')
xlabel('glucose. mg/l')
ylabel('spec pop growth rate, 1/h')