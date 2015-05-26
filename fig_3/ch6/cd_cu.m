%% fig:cd_cu
%% bib:BaasHout2007
%% out:cd_cu_02,cd_cu_08,cd_cu_20

%% set par values 
h0 = 0.0161; % 1/h, blank mortality prob rate (always >0)
CA0 = 3.6049; % mM, No-Effect-Concentration for A (external, may be zero)
CB0 = 1.1342; % mM, No-Effect-Concentration for B (external, may be zero)
bA = .2939;   % 1/(h*mM), killing rate for A
bB = .0244;   % 1/(h*mM), killing rate for B
kA = 5.0;   % 1/h, elimination rate for A
kB = 1.7;   % 1/h, elimination rate for B
dAB = 0.0199;  % 1/(h*mM^2), interaction rate for A and B

par = [h0 1; CA0 1; CB0 1; bA 1; bB 1; kA 0; kB 0 ; dAB 1];

t = [0: 21]'; % set time points
c1 = [0; 0.4; 0.8; 1.6; 3.2; 6.4]; % set conc Cd
c2 = [0; 0.2; 0.4; 0.8; 1.6; 3.2]; % set conc Cu

N= [...
30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30;
30 30 30 30 27  5 29 30 30 30 29  7 29 29 28 30 22  6 29 30 30 28 23  4 29 30 25 26 16  1 30 27 20 21 16  0;
29 30 30 30 25  3 29 30 30 30 28  6 29 29 28 29 21  6 29 30 30 28 21  3 28 28 24 26 14  1 24 26 20 15 11  0;
29 30 30 29 24  2 29 30 30 30 28  4 27 28 28 29 20  5 28 30 30 28 18  2 28 27 23 24  4  0 24 22 17 10  8  0;
28 30 30 29 24  2 29 30 30 30 25  4 27 25 28 27 19  2 27 29 28 27 16  1 28 24 23 22  4  0 21 21 14  5  4  0;
28 30 29 29 23  2 29 30 30 30 23  3 26 25 28 27 16  2 26 28 27 27 14  1 27 23 21 19  2  0 21 20 11  4  3  0;
28 29 29 29 23  2 28 29 29 30 22  3 24 25 28 24 13  1 25 28 27 26 14  1 25 22 21 18  2  0 21 16 10  4  1  0;
28 29 29 28 22  2 28 29 29 30 21  3 24 23 27 24 13  0 24 28 27 25 12  1 23 22 20 15  0  0 18 14  9  4  0  0;
28 29 29 27 22  2 28 29 29 29 20  3 23 22 27 24  9  0 23 28 27 24 12  1 23 21 19 13  0  0 17 14  6  4  0  0;
26 29 29 27 22  1 28 29 29 29 20  3 23 22 27 24  9  0 23 28 27 24 11  1 22 19 17 13  0  0 17 12  6  4  0  0;
26 29 29 27 21  1 28 29 29 29 19  1 20 22 26 24  8  0 23 28 26 23 10  0 21 18 17 13  0  0 16 10  6  4  0  0;
26 28 29 26 20  1 28 29 29 27 18  1 20 21 26 23  8  0 23 28 25 23 10  0 20 18 16 12  0  0 16  9  6  3  0  0;
26 27 28 26 20  1 27 29 29 27 18  1 19 21 26 23  8  0 23 26 25 22 10  0 19 18 16 10  0  0 15  9  6  3  0  0;
26 27 26 26 20  1 26 29 27 27 16  1 19 21 26 23  8  0 23 22 24 22  8  0 17 17 15 10  0  0 13  7  6  3  0  0;
26 27 25 26 20  1 26 27 27 27 16  1 18 21 26 23  7  0 22 22 22 22  8  0 15 17 15  9  0  0 13  7  6  3  0  0;
26 27 25 26 20  1 26 26 25 26 16  1 18 20 25 23  6  0 20 19 22 22  6  0 13 16 10  9  0  0 10  5  6  3  0  0;
26 27 25 26 20  1 26 25 25 26 16  1 18 20 25 23  6  0 20 19 22 22  6  0 13 16 10  9  0  0  9  5  5  2  0  0;
25 27 25 26 20  1 26 25 25 26 16  1 18 20 25 23  5  0 20 19 22 22  6  0 13 16  8  9  0  0  9  4  5  2  0  0;
25 27 25 26 20  1 26 25 25 26 16  1 18 20 24 21  5  0 19 19 22 22  5  0 13 15  8  8  0  0  8  4  5  2  0  0;
25 27 25 26 18  0 26 25 24 26 15  1 18 20 23 21  4  0 18 19 22 21  5  0 12 12  8  7  0  0  8  4  5  2  0  0;
25 27 25 25 17  0 25 25 24 25 15  1 18 20 21 20  3  0 18 18 21 21  4  0 10 12  8  7  0  0  8  4  4  2  0  0;
25 27 25 25 17  0 25 25 24 25 15  0 18 19 20 19  3  0 18 18 21 21  4  0 10 12  8  7  0  0  8  4  4  2  0  0];

%% allow for interaction
p = nmsurv3('fomort2',par,t,c1,c2,N);% back-estimate pars using nead-melder
p = scsurv3('fomort2',par,t,c1,c2,N); % back-estimate pars with scoring method

[cor cov sd dev] = psurv3('fomort2',p,t,c1,c2,N);
par_txt = {'h0'; 'CA0'; 'CB0'; 'bA'; 'bB'; 'kA'; 'kB'; 'dAB'};
printpar(par_txt,p,sd);

%% save('par','p','sd');

%% exclude interaction
p0 = p; p0(8,:) = [0 0]; % fix dAB = 0
%% p0 = nmsurv3('fomort2',p0,t,c1,c2,N);
p0 = scsurv3('fomort2',p0,t,c1,c2,N);

%% test if interaction rate dAB differs significantly from zero
dev0 = dev3('fomort2',p0,t,c1,c2,N); % get deviance for dAB = 0

d = max(0, dev0 - dev); % under H0: dAB = 0 this must be Chi^2 distr with 1 df
%% We always must have d>0, but numerical inaccuraries might cumulate
prob = surv_chi(1,d); % survivor prob of  Chi^2 distr with 1 df
fprintf(['reject hypothesis dAB = 0 if ',num2str(prob),' < 0.05 \n']);



