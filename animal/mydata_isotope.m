%% Example of running isotope 2008/03/12
%  choice [M_OD] = [M_OG] = 1 is made and (M_OD + M_OG)^(1/3) = L_O
%    for graph resentation only
%  allocation to otolith is ignored in mineral fluxes and yOE_A = 0
%  only 13C is followed

%  chemical labels:
%    chemical elements: C, H, O, N
%    minerals: carbon dioxide C, water H, dioxygen O, ammonia N
%    organics: food X, structure V, reserve V, faces P, otoltih O
%  minor notation problem: O stands for dioxygen and otolith in code
  
%  2006/03/27 Set anchovy parameters
%   Lb = .1; % 1, d.cm^2, scaled maturity at birth
%   Lp = 1.6; % 2, d.cm^2, scaled maturity at puberty
%   vOD = 1.1861e-005; % 4, mum/d, otolith speed for dissipation
%   vOG = .00011049; % 5, mum/d, otolith speed for growth
%   kM = .015; % 6, 1/d, somatic maintenance rate coeff
%   g = 6; % 7, -, energy investment ratio

%% parameters, rates are at temp T_ref = 286 K
JEAm = 5.5;  % 1: mmol/d/mm^2, {J_EAm}, spec max assim rate
b = 50;    % 2: dm^3/d/mm^2, {b}, spec searching rate
yEX = 0.8; % 3: mol/mol, yield of reserve on food
yVE = 0.9; % 4: mol/mol, yield of structure on reserve
v = 0.53;  % 5: mm/d, energy conductance
JEM = 0.008;% 6: mmol/mm^3, [\dot{J}_EM], vol-spec som maint cost
JET = 0;   % 7: mmol/mm^2, {\dot{J}_ET}, surface area-spec maint cost
kJ = 0.001;% 8: 1/d, mat maint rate coeff
kap = 0.65;% 9:  -, allocation fraction to soma
kapR = 0.95; % 10: -, allocation fraction to reprod, 1 - kapR = repod overhead
MHb = 1e-5 ; % 11: mmol, maturity at birth
MHp = 500;   % 12: mmol, maturity at puberty 
MV = 0.041;  % 13: mmol/mm^3, [M_V], vol-spec structural mass
yPX = 0.3;   % 14: mol/mol, yield of faces on food
yVE_D = 1.1; % 15: mol/mol, yield of structure on reserve in som maint
kapD = 0.25; % 16: -, fraction of reserve for structure turnover in dissip 
TA = 9800;   % 17: K, Arrh temp; ref = after Regner 1996;
yOE_D = 1e-6; % 18: mol/mol, yield of otolith on reserve in dissipation
yOE_G = 5e-6; % 19: mol/mol, yield of otolith on reserve in growth
delS = 20;    % 20: -, shape of the otosac

% pack parameters
par = [JEAm; b; yEX; yVE; v; JEM;  JET;  kJ;  kap;  kapR; ...
       MHb; MHp; MV; yPX; yVE_D; kapD; TA; yOE_D; yOE_G; delS];

%% chemical indices for minerals, organics
%  cols: CO2, H2O, O2, N-waste, food, structure, reserve, faeces
nMO = [1 0 0 0 1   1   1   1   ; ... % C
       0 2 0 3 1.8 1.8 1.8 1.8 ; ... % H
       2 1 2 0 0.5 0.5 0.5 0.5 ; ... % O
       0 0 0 1 0.2 0.2 0.2 0.2];     % N

%% reshuffle parameters
%  aA: (5,8)-matrix with reshuffle coefficients for assimilation
%    rows prod E P C H N; cols: substr (X,O) for elements *;
%    sum over rows (= products) must be equal to one
aA = [];

%% aD: (4,12)-matrix with reshuffle coefficients for dissipation
%    rows prod V C H N; cols: substr (E,V,O) for elements *
%    sum over rows (= products) must be equal to one
aD = [];

%% aG: (4,8)-matrix with reshuffle coefficients for growth 
%    rows prod V C H N; cols: substr (E,O) for elements *
%    sum over rows (= products) must be equal to one
aG = [];

%% odds: (4,4)-matrix with odds ratios
%    not more than 1 element per column can differ from 1
%    rows: elements *
%    cols: X in assim A_a, E,V in dissi D_a, E in growth G_a
%       X E V   E
odds = [1.05 1.05 1.05 1.3;  % C select for 13C in anabolic flux
	1   1   1   1;    % H
	1   1   1   1;    % O
	1   1   1   1];   % N

nt = 200; t = linspace(0, 3 * 365, nt)'; % time points for simulation 


%% environmental forcing
T_ref = 286; % K, Reference temperature ;
T = 286 + 1.85 * sin(2 * pi * (t + 207)/ 365); % K, temp at time t
%% T = (286 + 1.85) * ones(nt,1);

p5 = 1.0e+002 * ...
   [3.650000000000000 0.000338436258255;
   0.000139797026871 -0.000061529908266;
  -0.000140529304759 -0.000037548182856;
   0.000005704656069  0.000066063518408;
   0.000047981953130  0.000016729882406;
  -0.000005258679892 -0.000022614364105];

X = fnfourier(mod(t, 365), p5);
%%X = 1 * ones(nt,1);

delCX = 1e-3 * ones(nt,1); % C-isotope in food
delHX = 1e-3 * ones(nt,1); % H-isotope in food
delOX = 1e-3 * ones(nt,1); % O-isotope in food
delNX = 1e-3 * ones(nt,1); % N-isotope in food
delOO = 1e-3 * ones(nt,1); % O-isotope in dioxygen

%% pack forcing variables
tTXd = [t, T, X, delCX, delHX, delOX, delNX, delOO];


%% initial values of the 13 states at time t = 0
mEm = JEAm/ v/ MV; % max res density mol/mol
JXAm = JEAm/ yEX; % max spec food uptake rate
K = JXAm/ b; % half saturation coefficient
f = X(1)/ (K + X(1)); M_V0 = .1;
Md = [f * mEm * M_V0, M_V0, 1e-4 ... % M_E(0), M_V(0), M_H(0) in mol
      1e-5 1e-5 ...            % M_OD(0), M_OG(0) in mol (otolith)
      1e-3 1e-3 1e-3 1e-3 ...  % del_CE(0), del_HE(0), del_OE(0), del_NE(0)
      1e-3 1e-3 1e-3 1e-3]';   % del_CV(0), del_HV(0), del_OV(0), del_NV(0)

%% run isotope
[tMd, aA, aD, aG] = isotope(tTXd, Md, par, nMO, aA, aD, aG, odds);
%  tMd: (n,14)-matrix with cols
%       1 time, 2 res M_E, 3 struc M_V, 4 mat M_H,
%       5 otolith M_OD, 6 otol M_OG
%       7 del_CE,  8 del_HE,  9 del_OE, 10 del_NE,
%      11 del_CV, 12 del_HV, 13 del_OV, 14 del_NV

tOd = otolith([tMd, tTXd(:,2)], par, nMO, aA, aD, aG, odds); 
%  tOd = (nt,12)-matrix with cols
%     time, otolith length, otolith color, 9 del_CO's

%% plotting
clf

  %% subplot(3,4,1); clf
  figure(1)
  plot(t, tMd(:,2) ./ tMd(:,3)/ mEm, 'r', t, X ./ (K + X), 'g');
  xlabel('time, d'); ylabel('res dens e, f');

  %% subplot(3,4,2); clf
  figure(2)
  L = (tMd(:,3)/ MV) .^(1/3);
  plot(t, L, 'r');
  xlabel('time, d'); ylabel('length, mm');

  %% subplot(3,4,3); clf
  figure(3)
  plot(t, tMd(:,4), 'r');
  xlabel('time, d'); ylabel('maturity, mol'); 

  %% subplot(3,4,4); clf
  figure(4)
  plot(t, tOd(:,2), 'r');
  xlabel('time, d'); ylabel('otoloth length'); 
  
  %% subplot(3,4,5); clf
  figure(5)
  plot(t, T, 'r')
  xlabel('time, d'); ylabel('temp, K'); 

  %% subplot(3,4,6); clf
  figure(6)
  plot(tMd(:,1), tMd(:,7), 'r');
  xlabel('time, d'); ylabel('del_CE'); 

  %% subplot(3,4,7); clf
  figure(7)
  plot(tMd(:,1), tMd(:,11), 'r');
  xlabel('time, d'); ylabel('del_CV'); 

  %% subplot(3,4,8); clf
  figure(8)
  %% xlabel('time, d'); ylabel('del_N'); 
  %% plot(tMd(:,1), tMd(:,9), 'r');
  plot(tOd(:,2), tOd(:,3), 'r');
  xlabel('O-length'); ylabel('O-color'); 

  %% subplot(3,4,9); clf
  figure(9)
  plot(tOd(:,2), L, 'r');
  xlabel('O-length'); ylabel('body length, mm');

  %% subplot(3,4,10); clf
  figure(10)
  plot(tOd(:,2), tOd(:,4), 'r', ...
       tOd(:,2), tOd(:,5), 'g', ...
       tOd(:,2), tOd(:,6), 'b');
  xlabel('O-length'); ylabel('del_CO 1-3'); 

  %% subplot(3,4,11); clf
  figure(11)
  plot(tOd(:,2), tOd(:,7), 'r', ...
       tOd(:,2), tOd(:,8), 'g', ...
       tOd(:,2), tOd(:,9), 'b');
  xlabel('O-length'); ylabel('del_CO 4-6'); 

  %% subplot(3,4,12); clf
  figure(12)
  plot(tOd(:,2), tOd(:,10), 'r', ...
       tOd(:,2), tOd(:,11), 'g', ...
       tOd(:,2), tOd(:,12), 'b');
  xlabel('O-length'); ylabel('del_CO 7-9'); 
  





