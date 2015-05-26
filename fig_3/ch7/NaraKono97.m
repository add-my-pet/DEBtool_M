%% fig:NaraKono97
%% bib:NaraKono97
%% out:NaraKono97a,NaraKono97b,NaraKono97c,NaraKono97d

%% Narang, A. and Konopka, A. and Ramkrishna, D. 1997
%% New patterns of mixed substrate growth in batch cultures of
%% Escherichia coli K12. Biotechnol. Bioeng. 55: 747--757

tF1 =[ ... % fructose
0	2.017391;
1	1.965217;
2	1.913043;
3	1.704348;
4	1.443478;
5	1.147826;
6       0.643478;
7	0.034783];
tP1 =[ ... % pyruvate
0	2.121739;
1	2.034783;
2	1.913043;
3	1.634783;
4	1.304348;
5	0.939130;
6	0.052174];
tB1 =[ ... % E coli K12
0	0.034783;
1	0.052174;
2	0.104348;
3	0.139130;
4	0.226087;
5	0.382609;
6	0.643478;
7	0.921739;
8	1.043478;
9	1.060870];
tG2 = [ ... % Glucose
0       1.077778;
0.5	1.111111;
1 	1.066667;
1.5	1.022222;
2	1.000000;
2.5	0.877778;
3.	0.822222;
3.5	0.622222;
4	0.433333;
4.5	0.133333];
tF2 = [ ... % fuctose
0	0.7666667;
0.5	0.7888889;
1	0.7666667;
1.5	0.8000000;
2	0.8000000;
2.5	0.8000000;
3	0.7777778;
3.5	0.7666667;
4	0.7222222;
4.5	0.7111111;
5	0.6666666]; tF2 = [tF2, 10*ones(11,1)];
tB2 = [ ... % E. coli K12
0	0.0222222;
0.5	0.0222222;
1	0.0333333;
1.5	0.0555555;
2	0.0666666;
2.5	0.1000000;
3	0.1444444;
3.5	0.2111111;
4	0.3000000;
4.5	0.4222222;
5	0.4888889;
5.5	0.5000000;
6	0.5333333;
6.5	0.5777778]; tB2 = [tB2, 100*ones(14,1)];
t1 = linspace(0,9,500)'; % set time
t2 = linspace(0,7,500)'; % set time

%% initial parameter estimates
F = 2.0; P = 2.1; B  = .037; kF = .96;  mE = 0.288;  % init 1
F2 = 0.81;   G = 1.11; B2 = .013; kF2 = .99; mE2 = 1.3; % init 2

KF  = .0887; KP  = .0122;    KG = .0127; % sat coeff
yEF = .577;  yEP = .015;     yEG = .446;  yEV = 1.2; % yields
jFm = 1.138; jPm = 40.15;    jGm = 2.59; % max spec uptake
kE = 4.256;   kM = 0; % turnover, maint rate
w  = 0.941; w2 = 12.15; % preference
h = .0; h2 = .0; % background express

%% pack parameters (initial estimates + fix-indicators)
par = [F 1; P 1; B 1; kF 0; mE 0;
       F2 1; G 1; B2 1; kF2 0; mE2 0;
       KF 1; KP 1; KG 1;
       yEF 1; yEP 1; yEG 1; yEV 0;
       jFm 1; jPm 1; jGm 1; kE 1; kM 0;
       w 1; w2 1; h 0; h2 0];


nmregr_options('max_step_number', 1000); % set estimation options
p = par; % copy input to output in case of supression of estimation
%% p = nmregr('state2', par, tF1, tP1, tB1, tF2, tG2, tB2); % estimate
[EF1 EP1 EB1 EF2 EG2 EB2] = state2(p(:,1), t1,t1,t1,t2,t2,t2); % expectations
tEF1 = [t1,EF1]; tEP1 = [t1,EP1]; tEB1 = [t1,EB1]; % compose plot output
tEF2 = [t2,EF2]; tEG2 = [t2,EG2]; tEB2 = [t2,EB2];

global tkA1 tkA2 tmE1 tmE2

[par(:,1),p] % show estimates

%% gset term postscript color solid 'Times-Roman' 30

subplot(2,2,1)
% gset output 'NaraKono97a.ps'
plot(tF1(:,1), tF1(:,2), '.r', tP1(:,1), tP1(:,2), '.b', tB1(:,1), tB1(:,2), '.g', ...
     tEF1(:,1), tEF1(:,2), 'r',tEP1(:,1), tEP1(:,2), 'b', tEB1(:,1), tEB1(:,2), 'g')
xlabel('time, h')
ylabel('mMol')

subplot(2,2,2)
% gset output 'NaraKono97b.ps'
plot(tF2(:,1), tF2(:,2), '.r', tG2(:,1), tG2(:,2), '.m', tB2(:,1), tB2(:,2), '.g', ...
    tEF2(:,1), tEF2(:,2), 'r', tEG2(:,1), tEG2(:,2), 'm', tEB2(:,1), tEB2(:,2), 'g')
xlabel('time, h')
ylabel('mMol')

subplot(2,2,3);
% gset output 'NaraKono97c.ps'
plot(tkA1(:,1), tkA1(:,2), 'r', tkA2(:,1), tkA2(:,2), 'b')
xlabel('time, h')
ylabel('kappa')

subplot(2,2,4)
% gset output 'NaraKono97d.ps'
plot(tmE1(:,1), tmE1(:,2), 'r', tmE2(:,1), tmE2(:,2), 'b')
xlabel('time, h')
ylabel('res density')
