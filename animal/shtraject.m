%% shtraject
%
% created by Bas kooijman at 2010/04/01, modified 2011/03/07
%
% Simulation of standard DEB model with stochastic searching
%  using scaling to dimensionless quantities
%  handling and searching intervals only evaluate length at start interval
%  for theory, see comments to DEB3 for 2.9
%
% All variables and parameters are scaled down to dimensionless quantities. 
%  Due to the stochastic nature of the searching process, death by shrinking and rejuvenation can occur, even at constant food density. 
%  The stochastic nature becomes more important for low food density, large food particle size, small maximum body size (zoom factor). 
%  The computation time depends on the parameter values and can be substantial for small food particle sizes. 
%  The routine taject_M first runs traject and then computs and presents also the four mineral fluxes in 4 sub-plots in a second window.
%  The theory is explained the <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf *comments for section 2.9 and 4.3.1*>.
%
% The script results in 2 figures with quantities as  function of scaled time since birth
%  Figure 1 with six sub-plots: 
%
% * the reserve density, 
% * the survival probability and length, 
% * the maturity, the acceleration of aging, 
% * the hazards due to ageing and rejuvenation, 
% * the cumulative number of eaten food particles and of eggs.
%
% The trajectories are shown in red after death by shrinking. 
%  The (default) time period for the simulaton is from birth till two times the expected life span.
%
% Figure 2 with four sub-plots :
%   CO2, H2O, O2 and NH3 fluxes
%
% You can study the effect of parameter values by changing them.
% Outcomment last line of this script if you don't want to have the mineral fluxes.

global vH_max

% control parameters
x = .75; % food density; for x = 1 mean food intake is 0.5 * max
z = 5; % zoom factor: Lm = 1 cm for z = 1
MX = 5e-4 * z^3; % mmol, mass of food particle

% physiological parameters
vHb = .0004; % maturity at birth
vHp = .25;   % maturity at puberty
rhoh = 8 * z/ MX; % spec handling rate, MX in mmol: {h_XAm} L_m^2/ k_M
  % {h_XAm} max spec feeding rate in particles/ time/ surface
g = 3/z;     % energy investment ratio: [E_G]/ (kap [E_m])
kapR1 = .2;  % reproduction efficiency: kap_R (1 - kap)
kapG = .8;   % growth efficiency: mu_V [M_V]/ [E_G]
lT = 0;      % heating length: L_T/ L_m
k = .3;      % maintenance ratio: k_J/ k_M
k1 = .2;     % maturity decay: k_J^prime/ k_M
% extra parameters that are required for mineral fluxes
%  L_m = z L_m^ref with L_m^ref = 1 cm
%  v/ k_M = g z
kap = 0.8;          % -, kappa, allocation fracton to soma
y_EX = 0.8;         % mol/mol, yield of reserve on food
y_VE = 0.8;         % mol/mol, yield of structure on reserve
y_VX = y_VE * y_EX; % mol/mol, yield of structure on food
y_PX = 0.1;         % mol/mol, yield of product (feaces) on food

% chemical indices (relative elemental frequencies, for mineral fluxes only)
% organic compounds
%   columns: food, structure, reserve, faeces
%      X     V     E     P
n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       1.80, 1.80, 1.80, 1.80;  % H/C
       0.50, 0.50, 0.50, 0.50;  % O/C
       0.15, 0.15, 0.15, 0.15]; % N/C
% minerals
%   rows: elements carbon, hydrogen, oxygen, nitrogen
%   columns: carbon dioxide (C), water (H), dioxygen (O), ammonia (N)
%     CO2 H2O O2 NH3
n_M = [1,  0, 0,  0;  % C
       0,  2, 0,  3;  % H
       2,  1, 2,  0;  % O
       0,  0, 0,  1]; % N

% survival parameters
delX = .8; % hard survival condition on shrinking
  % death occurs if l < delX * max l (in the past)
sH = 2;    % soft survival condition on rejuvenation
  % h_H = sH (max vH - vH)
ha = z * 3e-5; % Weibull aging acelleration
sG = .001;  % Gompertz stress coeff

% conditions at birth
t = 0; % time
eb = x/(1 + x); % reserve density
[uE0 lb] = get_ue0 ([g; k; vHb], eb); % initial reserve, length at birth
qb = 0; % acceletation; not correct but ...
hb = 0; % hazard; not correct but ...
Sb = 1; % survival prob; not correct but ...
Nb = 0; % cumulative reproduction
vH_max = vHb; % passed to dtraject to detect rejuvenation
tf = []; % initiate times of feeding
% determine handling or searching at birth
th = 1/(rhoh * lb^2); ts = th/ x; % handling & searching periods at birth
f = rand(1) < ts/ (ts + th); % f = 0 (if searching) or 1 (if handling);
vars = [eb, lb, vHb, qb, hb, Sb, Nb]; % pack initial vars

Vars = [t, f, vars]; % initiate extended vars 
nV = length(Vars);

tmax = 2 * get_tm_s([g; lT; ha; sG], eb); % simulation interval

% actual simulation
while Vars(end,1) < tmax % continue simulation till tmax
  l = Vars(end,4); % current length
  dt = 1/ (rhoh * l^2); % handling interval
  if f == 0
    dt = - dt * log(rand(1))/ x; % searching interval
    tf = [tf; Vars(end,1) + dt]; % append to times of feeding
  end
  t0 = Vars(end,1) + [0;dt]; % new time interval
  vars0 = Vars(end,3:nV)';   % new vars values
  [t_int vars_int] = ode23(@dtraject, t0, vars0, [], ...
      vHb, vHp, g, kapR1, kapG, lT, k, k1, ha, sG, sH, uE0, f);
  t_int(1,:) = []; vars_int(1,:) = []; % remove first time and vars
  Vars = [Vars; t_int, [f * ones(length(t_int),1), vars_int]]; % append to existing trajectory
  f = ~f; % alternate f
end

% unpack vars
t = Vars(:,1);
f = Vars(:,2); e = Vars(:,3); l = Vars(:,4); vH = Vars(:,5); 
q = Vars(:,6); h = Vars(:,7); S = Vars(:,8);  N = Vars(:,9);

% survival by shrinking, rejuvenation
death = find(l < delX * cummax_vec(l),1,'first'); % length > delX * max length
if isempty(death)
  alive = t>-1; % must be booleans
else
  alive = 1:length(l) < death; % once dead is dead forever
end
h_vH = sH * (cummax_vec(vH) - vH); % hazard due to rejuvenation

% plotting
close all

%figure
subplot(2,3,1)
plot(t(alive), e(alive), 'g', t(~alive), e(~alive), 'r')
ylabel('reserve density')
xlabel('time since birth')

%figure
subplot(2,3,2)
hold on
plot(t(alive), l(alive), 'g', t(~alive), l(~alive), 'r')
plot(t(alive), S(alive), '-', 'Color', [0 .75 0])
plot(t(~alive), S(~alive), '-', 'Color', [.75 0 0])
ylabel('length, survival')
xlabel('time since birth')

%figure
subplot(2,3,3)
plot(t(alive), vH(alive), 'g', t(~alive), vH(~alive), 'r')
ylabel('maturity')
xlabel('time since birth')

%figure
subplot(2,3,4)
plot(t(alive), q(alive), 'g', t(~alive), q(~alive), 'r')
ylabel('acceleration')
xlabel('time since birth')

%figure
subplot(2,3,5)
hold on
plot(t(alive), h(alive), 'g', t(~alive), h(~alive), 'r')
plot(t(alive), h_vH(alive), '-', 'Color', [0 .75 0])
plot(t(~alive), h_vH(~alive), '-', 'Color', [.75 0 0])
ylabel('hazard by ageing, rejuv')
xlabel('time since birth')

%figure
subplot(2,3,6)
plot(t(alive), 10 * N(alive), 'g', t(~alive), N(~alive), 'r', ...
     tf, 1:length(tf), 'k')
ylabel('cum feeding, 10 x cum reprod, ')
xlabel('time since birth')

shtraject_M; % continue with plotting mineral fluxes