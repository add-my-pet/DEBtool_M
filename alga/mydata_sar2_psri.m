%% mydata_sar2_psri
% demo for sar2_psri on the assumption that we have CH2O and NO3 reserves
% the specification of reserves affects CO2 and O2 dynamics in the growth process
% maintenance is only for CH2O reserve

n_V = [1; 1.8; 0.5; 0.2]; % -, chemical indices of structure

% growth controls
j_HM     = .02;   % 8 mol/d.mol, maint for carbohydrates; zero maint for NO3
y_VH     = 1.2;   % 9 mol/mol, yield of CH2O on structure
m_E = [.2;.3];    % mol/mol, CH2O and NO3 reserve densities
k_E = [.8; .8];   % 1/d, CH2O and NO3 reserve turnover rates
j_EM = [j_HM; 1e-6]; % mol/d.mol, spec maintenance costs for CH2O and NO3 reserves if paid from reserve
y_EV = [1/y_VH; 1/n_V(4)]; % mol/mol yields of reserves on structure
j_VM = 1.2 * j_EM; % mol/d.mol, spec maintenance costs for structure if piad from structure
a = 0.01;         % -, preference for structure as substrate for maintenance
[r, jEM, jVM, jER, info_sgr] = sgr2 (m_E, k_E, j_EM, y_EV, j_VM, a); % get sgr

% assimilation parameters
b_C      = .1;    % 1 dm^3/d.mol V, affinity for CO2
b_O      = .1;    % 2 dm^3/d.mol V, affinity for O2
k_H      = 1;     % 3 1/d, max net spec carbon fixation
k_C      = 1;     % 4 1/d, max net spec photo respiration
k_C_env  = .2;    % 5 1/d, rate of CO2 exchange with environment
k_O_env  = .2;    % 6 1/d, rate of O2 exchange with environment
k_L      = 1e3;     % 7 1/d, inhibition-repair rate
M_V      = .04;   %10 mol/cm^3, [M_V] vol-spec mass of structure
p_sar = [b_C; b_O; k_H; k_C; k_C_env; k_O_env; k_L; j_HM; 1/y_VH; M_V];

% environment conditions
X_C = 1e2;  % mol/dm^3, CO2 conc in environment
X_O = .1e2; % mol/dm^3, O2 conc in environment

jLjH = zeros(0, 3); j_H = [];
for j_L = 0.1:.1:10
  [j_HCO j_L_ info_sar] = sar2_psri(j_L, X_C, X_O, r, p_sar, n_V, j_H);
  j_H = j_HCO(1);
  jLjH = [jLjH; [j_L j_H j_L_]];
end

subplot(1,2,1)
plot(jLjH(:,1), jLjH(:,2),'b')
xlabel('light flux')
ylabel('CH_2O flux')

subplot(1,2,2)
plot(jLjH(:,1), jLjH(:,3),'r')
xlabel('light flux')
ylabel('rejected photon flux')

