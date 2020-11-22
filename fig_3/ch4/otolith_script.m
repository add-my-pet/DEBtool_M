%% fig:otolith
%% out:f2o_te,f2o_tl,f2o_tlo,f2o_tf,f2o_tc,f2o_loo

%% this script demonstrates the use of f2o and o2f
%% we first obtain (otolith-length,opacity( data from functional response trajectory
%%   then we reconstruct functional response trajectory from (otolith-length,opacity) data
%%   and test the result graphically
%% shrinking is not allowed, on the assumption that the reproduction buffer is large enough
%% we assume k_J = k_M for simplicity's sake (implying stage transitions at fixed length)
%% we use volumetric length for body and otolith
%% if d/dt f changes slowly,  we have f about equal to e

%% 2006/03/27 Set anchovy parameters
  Lb = .1; % 1, d.cm^2, scaled maturity at birth
  Lp = 1.6; % 2, d.cm^2, scaled maturity at puberty
  v = .031748 * 16.5838; % 3, cm/d, energy conductance * M shape correction factor
  vOD = 1.1861e-005; % 4, mum/d, otolith speed for dissipation
  vOG = .00011049; % 5, mum/d, otolith speed for growth
  kM = .015; % 6, 1/d, somatic maintenance rate coeff
  g = 6; % 7, -, energy investment ratio
  kap = 0.65; % 8, was 0.65;% -, Veer
  kapR = 0.95; % 9, -, Fraction of reproduction energy fixed in eggs; ref = ;
  delS = 20;% 10, -, shape of the otosac
par = [Lb; Lp; v; vOD; vOG; kM; g; kap; kapR; delS];

t = linspace(0,3*365,200)'; % time points for simulation 

TA = 9800; % K, Arrhenius temperature ; ref = after Regner 1996;
T1 = 286; % K, Reference temperature ;
T = 286 + 1.85 * sin(2 * pi * (t + 207)/ 365); % K, temp at time t
cor_T = exp(TA/ T1 - TA ./ T); % temp correction factors

p5 = 1.0e+002 * ...
   [3.650000000000000 0.000338436258255;
   0.000139797026871 -0.000061529908266;
  -0.000140529304759 -0.000037548182856;
   0.000005704656069  0.000066063518408;
   0.000047981953130  0.000016729882406;
  -0.000005258679892 -0.000022614364105];

X = fnfourier(mod(t, 365), p5);
K = .045; % chlo_a/d.m^2, saturation constant
f = X ./ (K + X); % scaled functional response
tcf = [t, cor_T, f]; % pack environmental forcing

%% from scaled functional response f to opacity o
LOb = .01; eb = .85; % LO and e at birth
[LOO, teLLOO] = f2o(tcf, eb, LOb, par); % get otolith, state vars

%% from opacity o to scaled functional response f
tc = tcf(:,[1 2]); % remove unknown f
%% tcfeLLOO = o2f_init(LOO, tc, par, teLLOO(end,3)); % get initial estimate
tcfeLLOO = o2f(LOO, tc, par); % get best estimate (less robust)
tcfeLLOO_1 = o2f(LOO, [], par); % again with constant temperature

%% start plotting
%% gset term postscript color solid 'Times-Roman' 30
%% gset nokey

subplot(2,3,1)
% gset output 'tc.ps'
plot(tcf(:,1), tcf(:,2), 'g', tcfeLLOO(:,1), tcfeLLOO(:,2), 'r', ...
     tcfeLLOO_1(:,1), tcfeLLOO_1(:,2), 'b')
xlabel('time')
ylabel('c_T')

subplot(2,3,2)
% gset output 'tf.ps'
plot(tcf(:,1), tcf(:,3), 'g', tcfeLLOO(:,1), tcfeLLOO(:,3), 'r', ...
     tcfeLLOO_1(:,1), tcfeLLOO_1(:,3), 'b')
xlabel('time')
ylabel('f')

subplot(2,3,3)
% gset output 'te.ps'
plot(teLLOO(:,1), teLLOO(:,2), 'g', tcfeLLOO(:,1), tcfeLLOO(:,4), 'r', ...
     tcfeLLOO_1(:,1), tcfeLLOO_1(:,4), 'b')
xlabel('time')
ylabel('e')

subplot(2,3,4)
% gset output 'tl.ps'
plot(teLLOO(:,1), teLLOO(:,3), 'g', tcfeLLOO(:,1), tcfeLLOO(:,5), 'r', ...
     tcfeLLOO_1(:,1), tcfeLLOO_1(:,5), 'b')
xlabel('time')
ylabel('L')

subplot(2,3,5)
% gset output 'tlo.ps'
plot(teLLOO(:,1), teLLOO(:,4), 'g', tcfeLLOO(:,1), tcfeLLOO(:,6), 'r', ...
     tcfeLLOO_1(:,1), tcfeLLOO_1(:,6), 'b')
xlabel('time')
ylabel('L_O')

subplot(2,3,6)
% gset output 'loo.ps'
plot(LOO(:,1), LOO(:,2), 'g', tcfeLLOO(:,6), tcfeLLOO(:,7), 'r', ...
     tcfeLLOO_1(:,6), tcfeLLOO_1(:,7), 'b')
xlabel('L_O')
ylabel('O')
