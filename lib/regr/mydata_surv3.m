% created: 2006/08/14 by Bas Kooijman
% sample data for surv3 routines

%% set par values for binary mixture toxicants
h0 = .016;    % 1/h, blank mortality prob rate (always >0)
CA0 = 3.10;   % mM, No-Effect-Concentration for A (external, may be zero)
CB0 = 1.13;   % mM, No-Effect-Concentration for B (external, may be zero)
bA = 0.29;    % 1/(h*mM), killing rate for A
bB = 0.024;   % 1/(h*mM), killing rate for B
kA = 5.0;     % 1/h, elimination rate for A
kB = 1.7;     % 1/h, elimination rate for B
dAB = 0.00;   % 1/(h*mM^2), interaction rate for A and B

p1 = [  h0;  CA0; CB0;   bA;   bB;   kA;  kB;   dAB]; % collect par values
p2 = [   1;    1;   1;    1;    1;    1;    1;    1]; % iteration indicator
p3 = [.001; .001;.001; .001; .001; .001; .001;   -1]; % lower boundary
p4 = [   1;   15;   5;   10;   10;   10;   10;    1]; % upper boundary

par = [p1,p2,p3,p4]; % compose parameter input matrix
% values in first column are ignored in ga-algorothm

t = [0:21]'; % set time points
c1 = [0;0.4;0.8;1.6;3.2;6.4;12.8]; % set conc first toxicant
c2 = [0;0.2;0.4;0.8;1.6;3.2];      % set conc second toxicant

% H = haz_fomort2(par,t,c1,c2);
S = fomort2(p1,t,c1,c2); % get survival probabilities

Z = surv_count(20,S);% get Monte Carlo data using 20 ind per conc-combination

%% set genetic algorithm parameters
gasurv_options('max_step_number',300);
gasurv_options('popSize',500);
% ga-algorithm: slow but robust
p_ga = gasurv3('fomort2',par,t,c1,c2,Z)  % par estimate using genetic algorithm
% nm-algorithm: faster but less robust (and more local)
p_nm = nmsurv3('fomort2',p_ga,t,c1,c2,Z) % par estimate using nead-melder
% scoring method: very fast but also very senbsitive for initial conditions
p_sc = scsurv3('fomort2',p_nm,t,c1,c2,Z) % par estimate using scoring method

[p_ga(:,1), p_nm(:,1), p_sc(:,1)] % compare results
