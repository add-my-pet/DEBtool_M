%% diso_221
% ode's for iso_221

%%
function dvar = diso_221(t, var, tXT, p)

  %% Syntax
  % dvar =  <../diso_221.m *diso_221*> (t, var, tXT, p)
  
  %% Description
  % ode's for iso_221
  %
  % Input:
  %
  % * t: scalar time since birth
  % * var: 13-vector with states:
  %     cM_X1, cM_X2, M_E1, M_E2, M_H, max_M_H, M_V, max_M_V, cM_ER1, cM_ER2, q, h, S
  % * tXT: (n,3)-matrix with time, X1, X2, T
  % p: structure with par values
  %
  % Output:
  %
  % * dvar: 13-vector with d/dt var
                                      
% unpack variables
%cM_X1 = var( 1); cM_X2   = var( 2); % mol, cumulative ingested food
 M_E1  = var( 3); M_E2    = var( 4); % mol, reserve
 E_H   = var( 5); max_E_H = var( 6); % J, maturity, max maturity
 M_V   = var( 7); max_M_V = var( 8); % mol, structure, max structure
%cM_E1R= var( 9); cM_E2R  = var(10); % mol, cumulative reprod
 q     = var(11); h       = var(12); % 1/d, 1/d^2 acceleration, harzard
 S     = var(13);                    % -, survival probability
 
% repair numerical problems: M_Ei must be real and positive
if ~isreal(M_E1) || M_E1 < 0
    M_E1 = 1e-10;
end
if ~isreal(M_E2) || M_E2 < 0
    M_E2 = 1e-10;
end

% get environmental variables at age t (linear interpolation)
X1 = spline1(t, tXT(:,[1 2])); % mol/cd^2, food density of type 1
X2 = spline1(t, tXT(:,[1 3])); % mol/cd^2, food density of type 1 
T  = spline1(t, tXT(:,[1 4])); % K, temperature 

if E_H < p.E_Hb % no assimilation before birth or surface-linked maintenance
  X1 = 0; X2 = 0;
  J_E1T = 0;
end

% help quantities
L = (M_V/ p.MV)^(1/3);               % cm, structural length
k_E = p.v/ L;                        % 1/d,  reserve turnover rate
mu_EV = p.mu_E1/ p.mu_V;             % -, ratio of chemical potential
m_E1 = M_E1/ M_V; m_E2 = M_E2/ M_V;% mol/mol, reserve density
% somatic maintenance
j_E2M = p.j_E1M * p.mu_E1/ p.mu_E2;      % mol/d.mol
J_E2T = p.J_E1T * p.mu_E2/ p.mu_E1;      % mol/d.cm^2
j_E1S = p.j_E1M + p.J_E1T/ p.MV/ L;      % mol/d.mol total spec somatic maint
j_E2S = j_E2M + J_E2T/ p.MV/ L;      % mol/d.mol
J_E1S = j_E1S * p.MV;                % mol/d.cm^3 total spec somatic maint
J_E2S = j_E2S * p.MV;                % mol/d.cm^3 total spec somatic maint

% correct rates for temperature
TC = tempcorr(T, 293, p.T_A); % -, temperature correction factor, T_ref = 293 K
FT_X1m  = TC * p.F_X1m; FT_X2m = TC * p.F_X2m;  % dm^2/d.cm^2, {F_Xim} spec searching rates
JT_X1Am = TC * p.J_X1Am; JT_X2Am = TC * p.J_X2Am; % mol/d.cm^2, {J_EiAm^Xi} max specfific assim rate for food X1
jT_E1S = TC * j_E1S; jT_E2S = TC * j_E2S;   % mol/d.mol, specific som maint costs
vT = TC * p.v;                                 % cm/d, 1/d, energy conductance, reserve turnover rate
kT_J = TC * p.k_J; k1T_J = TC * p.k1_J; % 1/d mat maint rate coeff, spec rejuvenation rate
kT_E = TC * k_E;                                 % 1/d, reserve turnover rate
JT_E1S = TC * J_E1S; JT_E2S = TC * J_E2S; % mol/d, somatic maint rate

% feeding
JT_E1Am_X1 = p.y_E1X1 * JT_X1Am; JT_E1Am_X2 = p.y_E1X2 * JT_X2Am; % mol/d.cm^2, max spec assim rate for reserve 1 
JT_E2Am_X1 = p.y_E2X1 * JT_X1Am; JT_E2Am_X2 = p.y_E2X2 * JT_X2Am; % mol/d.cm^2, max spec assim rate for reserve 2
m_E1m = (JT_E1Am_X1 + JT_E1Am_X2)/ vT/ p.MV;                      % mol/mol, max reserve 1 density
m_E2m = (JT_E2Am_X1 + JT_E2Am_X2)/ vT/ p.MV;                      % mol/mol, max reserve 2 density
s1 = max(0, 1 - m_E1/ m_E1m); s2 = max(0, 1 - m_E2/ m_E2m);       % -, stress factors for reserve 1, 2
rho_X1X2 = s1 * max(0, p.M_X1/ p.M_X2 * p.y_E1X1/ p.y_E1X2 - 1) + s2 * max(0, p.M_X1/ p.M_X2 * p.y_E2X1/ p.y_E2X2 - 1);
rho_X2X1 = s1 * max(0, p.M_X2/ p.M_X1 * p.y_E1X2/ p.y_E1X1 - 1) + s2 * max(0, p.M_X2/ p.M_X1 * p.y_E2X2/ p.y_E2X1 - 1);
hT_X1Am = JT_X1Am/ p.M_X1; hT_X2Am = JT_X2Am/ p.M_X2;             % #/d.cm^2, max spec feeding rates
alphaT_X1 = hT_X1Am + FT_X1m * X1 + FT_X2m * rho_X2X1 * X2; 
alphaT_X2 = hT_X2Am + FT_X2m * X2 + FT_X1m * rho_X1X2 * X1;
betaT_X1 = FT_X1m * X1 * (1 - rho_X1X2);  betaT_X2 = FT_X2m * X2 * (1 - rho_X2X1);
f1 = (alphaT_X2 * FT_X1m * X1 - betaT_X1 * FT_X2m * X2)/ (alphaT_X1 * alphaT_X2 - betaT_X1 * betaT_X2);
f2 = (alphaT_X1 * FT_X2m * X2 - betaT_X2 * FT_X1m * X1)/ (alphaT_X1 * alphaT_X2 - betaT_X1 * betaT_X2);
dcM_X1 = f1 * JT_X1Am * L^2; dcM_X2 = f2 * JT_X2Am * L^2; % mol/d, feeding rates

% assimilation
JT_E1A = f1 * p.y_E1X1 * JT_X1Am + f2 * p.y_E1X2 * JT_X2Am; % mol/d.cm^2, {J_E1A}, specific assimilation flux
JT_E2A = f1 * p.y_E2X1 * JT_X1Am + f2 * p.y_E2X2 * JT_X2Am; % mol/d.cm^2, {J_E2A}, specific assimilation flux
jT_E1A = JT_E1A/ p.MV/ L; jT_E2A = JT_E2A/ p.MV/ L;         % mol/d.mol, {J_EA}/ L.[M_V], specific assim flux
JT_E1Am = JT_E1Am_X1 + JT_E1Am_X2;                          % mol/d.cm^2, total max spec assim rate for reserve 1
JT_E2Am = JT_E2Am_X1 + JT_E2Am_X2;                          % mol/d.cm^2, total max spec assim rate for reserve 2

% reserve dynamics
[rT, jT_E1_S, jT_E2_S, jT_E1C, jT_E2C, info] = ...         % 1/d, specific growth rate, ....
    sgr_iso_21(m_E1, m_E2, jT_E1S, jT_E2S, p.y_VE1, p.y_VE2, mu_EV, kT_E, p.kap, p.rho1); % use continuation
if info == 0 % try to repair in case of lack of convergence by starting from r_0 = 1e-4
  [rT, jT_E1_S, jT_E2_S, jT_E1C, jT_E2C, info] = ...       % 1/d, specific growth rate, ....
    sgr_iso_21(m_E1, m_E2, jT_E1S, jT_E2S, p.y_VE1, p.y_VE2, p.mu_EV, kT_E, p.kap, p.rho1, 1e-4);
  if info == 1
    fprintf('diso_221 message: successful repair of lack of convergence with NR\n');
  else % info == 0
    fprintf('diso_221 warning: sgr_iso_21 does not convergence\n');
    fprintf(['t = ',num2str(t),'; r = ',num2str(r), '\n']);
  end
end

jT_V_S = max(0, -rT);                                % mol/d.mol, specific shrinking rate
jT_E1P = p.kap * jT_E1C - jT_E1_S - (rT + jT_V_S)/ p.y_VE1; % mol/d.mol, rejected flux
jT_E2P = p.kap * jT_E2C - jT_E2_S - (rT + jT_V_S)/ p.y_VE2; % mol/d.mol
dm_E1 = jT_E1A - jT_E1C + p.kap_E1 * jT_E1P - rT * m_E1; % mol/d.mol, change in reserve density
dm_E2 = jT_E2A - jT_E2C + p.kap_E2 * jT_E2P - rT * m_E2; % mol/d.mol
dM_E1 = M_V * (dm_E1 + rT * m_E1);                  % mol/d, change in reserve
dM_E2 = M_V * (dm_E2 + rT * m_E2);                  % mol/d
JT_E1C = M_V * jT_E1C; JT_E2C = M_V * jT_E2C;       % mol/d, mobilisation rates
pT_C = p.mu_E1 * JT_E1C + p.mu_E2 * JT_E2C;         % J/d, total mobilisation power

% growth
dM_V = rT * M_V;                                    % mol/d, growth rate (of structure)
dmax_M_V = max(0, dM_V);                            % mol/d, max value of structure

% maturation
dE_H = (1 - p.kap) * pT_C - kT_J * E_H;              % J/d, maturation if juvenile
if E_H >= p.E_Hp && dE_H >= 0 % adult 
  dE_H = 0;                                          % J/d, no maturation if adult
elseif dE_H < 0
  dE_H = - k1T_J * (E_H - (1 - p.kap) * pT_C/ kT_J); % J/d, rejuvenation
end
dmax_E_H = max(0, dE_H);                             % J/d, max value of maturity

% reproduction in adults
JT_E1R = JT_E1C * (1 - p.kap - kT_J * E_H/ pT_C);    % mol/d, allocation to reprod from res 1
JT_E2R = JT_E2C * (1 - p.kap - kT_J * E_H/ pT_C);    % mol/d, allocation to reprod from res 2
dcM_E1R = p.kap_R1 * JT_E1R * (E_H >= p.E_Hp);       % mol/d, accumulation in reprod buffer
dcM_E2R = p.kap_R2 * JT_E2R * (E_H >= p.E_Hp);       % mol/d, accumulation in reprod buffer

% survival due to aging, shrinking, rejuvenation
kT_C = (jT_E1C - jT_E1P)/ m_E1 + (jT_E2C - jT_E2P)/ m_E2; % 1/d, summed [p_C]/[E_m]
L_m = p.kap * min(JT_E1Am/ JT_E1S, JT_E2Am/ JT_E2S);      % cm, max structural length
dq = (q * (L/ L_m)^3 * p.s_G + p.h_a) * kT_C - rT * q;    % 1/d^3, change in acceleration
dh = q - rT * h;                                     % 1/d^2, change in hazard by ageing
h_S = 1e2 * (M_V < p.del_V * max_M_V);               % 1/d, hazard by shrinking
h_R = p.h_H * (1 - E_H/ max_E_H);                    % 1/d, hazard by rejuvenation 
dS = - S * (h + h_S + h_R);                          % 1/d, change in survival probability

% pack output
dvar = [dcM_X1; dcM_X2; dM_E1; dM_E2; dE_H; dmax_E_H; dM_V; dmax_M_V; dcM_E1R; dcM_E2R; dq; dh; dS];

