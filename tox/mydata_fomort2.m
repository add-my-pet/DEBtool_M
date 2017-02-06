%% Demo script: standard effects on survival of a binary mixture


%% set par values 
h0 = .001;  % 1/h, blank mortality prob rate (always >0)
CA0 = 1.5; % mM, No-Effect-Concentration for A (external, may be zero)
CB0 = 3; % mM, No-Effect-Concentration for B (external, may be zero)
bA = .2;  % 1/(h*mM), killing rate for A
bB = .1;  % 1/(h*mM), killing rate for B
kA = 1;  % 1/h, elimination rate for A
kB = 2;  % 1/h, elimination rate for B
dAB = 0.001; % 1/(h*mM^2), interaction rate for A and B
par = [h0; CA0; CB0; bA; bB; kA; kB; dAB];
par_txt = {'h0 , 1/h'; 'CA0, mM'; 'CB0, mM';  'bA, 1/(h*mM)'; 'bB, 1/(h*mM)'; 'kA, 1/h'; 'kB, 1/h'; 'dAB, 1/(h*mM^2)'};

t = [0:7]'; % set time points
c1 = [0;1.1;2.1;3.1]; % set conc A
c2 = [0;2.2;4.2]; % set conc B 

%% H = haz_fomort2(par,t,c1,c2);
S = fomort2(par,t,c1,c2); % get survival probabilities

N = surv_count(100,S); % get Monte Carlo data
p = nmsurv3('fomort2',par,t,c1,c2,N); % back-estimate pars using nead-melder
% the scoring method seems to have a poor convergence; error?
% p = scsurv3('fomort2',p,t,c1,c2,N); % back-estimate pars with scoring method

[cor cov sd dev] = psurv3('fomort2',p,t,c1,c2,N);
printpar(par_txt,p,sd)

%% test if interaction rate dAB differs significantly from zero
p0 = [p, ones(8,1)]; p0(8,:) = [0 0];
p0 = nmsurv3('fomort2',p0,t,c1,c2,N); % pars with dAB = 0
dev0 = dev3('fomort2',p0,t,c1,c2,N); % get deviance for dAB = 0

d = dev0 - dev; % under H0: dAB = 0 this must be Chi^2 distr with 1 df
p = surv_chi(1,d); % survivor prob of  Chi^2 distr with 1 df
fprintf(['reject hypothesis dAB = 0 if ',num2str(p),' < 0.05 \n']);

%% misclassification in 3 related fomort2 models
% fomort2: 1 = cA/CA0 + cB/CB0 fixed at t0
% fomort2r: 1 = cA/CA0 + cB/CB0 not fixed at t0
% fomort2i: 1 = cA/CA0; 1 = cB/CB0 fixed at t0A, t0B
parMCr = nmsurv3('fomort2r',p0,t,c1,c2,N);
devr = dev3 ('fomort2r',parMCr,t,c1,c2,N);
parMCi = nmsurv3('fomort2i',p0,t,c1,c2,N);
devi = dev3('fomort2i',parMCi,t,c1,c2,N);

[dev, devr, devi]
[par(:,1), p0(:,1), parMCr(:,1), parMCi(:,1)]
