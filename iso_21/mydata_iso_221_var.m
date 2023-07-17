%% mydata_iso_221_var
% created 2011/05/04 by Bas Kooijman, modified 2012/01/30, 2023/07/16
% isomorph with 1 structure
% 2 reserves: protein (1) and non-protein (2)
%  somatic maintenance and growth overhead preferably paid from non-protein
% 2 types of food
%  preference depends on stress of non-filled reserve

%% set parameters at T_ref = 293 K
p.M_X1      = 1e-3;   p.M_X2      = 1e-3;  % mol, size of food particle of type i
p.F_X1m     = 10;     p.F_X2m     = 10;    % dm^2/d.cm^2, {F_Xim} spec searching rates
p.y_P1X1    = 0.15;   p.y_P2X2    = 0.15;  % mol/mol, yield of feaces i on food i
p.y_E1X1    = 0.55;   p.y_E2X1    = 0.25;  % mol/mol, yield of reserve Ei on food X1 (protein, non-protein)
p.y_E1X2    = 0.25;   p.y_E2X2    = 0.55;  % mol/mol, yield of reserve Ei on food X2 (protein, non-protein)
p.J_X1Am    = 1.0e-3; p.J_X2Am    = 1.0e-3;% mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
p.v         = 0.02;   p.kap       = 0.8;   % cm/d, energy conductance, 
                                           % -, allocation fraction to soma
p.mu_E1     = 4e5;    p.mu_E2     = 4e5;   % J/mol, chemical potential of reserve i
p.mu_V      = 5e5;    p.MV        = 4e-2;  % J/mol, chemical potenial of structure;  mol/cm^3, [M_V] density of structure                                       
p.j_E1M     = 0.09;   p.j_E2M     = j_E1M * mu_E1/ mu_E2; % mol/d.mol, specific som maint costs                                     
p.k_J       = 0.002;  p.k1_J      = 0.002; % 1/d, mat maint rate coeff, spec rejuvenation rate                                    
p.del_V     = 0.8;                         % -, threshold for death by  shrinking
p.kap_E1    = 1;      p.kap_E2    = 1;     % -, fraction of rejected mobilised flux that is returned to reserve
% since j_E1P = 0, kap_E1 is not relevant
p.kap_R1    = 0.95;   p.kap_R2    = 0.95;  % -, reproduction efficiency for reserve i
p.E_Hb      = 1e1;    p.E_Hp      = 2e4;   % J, maturity thresholds at birth, puberty
p.T_A       = 8000;   p.h_H       = 1e-5;  % K, Arrhenius temperature
                                           % 1/d, hazerd due to rejuvenation
p.h_a       = 2e-8;   p.s_G       = 1e-4;  % 1/d^2, aging acceleration
                                           % -, Gompertz stress coefficient
% set chemical indices
%    X1   X2    V   E1   E2   P1   P2  organics
n_O = [...
      1    1    1    1    1    1    1   ; % C
      1.8  1.8  1.8  1.61 2.0  1.8  1.8 ; % H
      0.5  0.5  0.5  0.33 0.6  0.5  0.6 ; % O
      0.2  0.2  0.2  0.28 0.0  0.2  0.0]; % N
  
%     C    H    O    N                 minerals
n_M = [...
      1    0    0    0; % C
      0    2    0    3; % H
      2    1    2    0; % O
      0    0    0    1];% N

%% set environmental variables
t = linspace(0,8e3,5e2)'; tXT = [t, t, t, t]; % d, time points
tXT(:,2) = 4000;     tXT(:,3) = 4000;         % mol/dm^2, food densities (don't need to be constant)
tXT(:,4) = 293;                               % K, temperature (does not need to be constant)

%% get state at birth
m_E1 = (p.y_E1X1 * p.J_X1Am + p.y_E1X2 * p.J_X2Am)/ p.v/ p.MV; 
m_E2 = (p.y_E2X1 * p.J_X1Am + p.y_E2X2 * p.J_X2Am)/ p.v/ p.MV;
[L_b, a_b, M_E10, M_E20, info] = iso_21_var_e(m_E1, m_E2, p);
%return

%% run iso_221
[var, flux]  = iso_221_var(tXT, var_b, p, n_O, n_M); % from birth to t = tXT(end,1)

if 0
% continue with a period with only food type 2
t2 = linspace(8e3,10e3,1e2)'; tXT2 = [t2, t2, t2, t2]; % d, set time points
tXT2(:,2) = 4000; tXT2(:,3) = 0; tXT2(:,4) = 293;      % set food, temp
var_0 = var(end,:)';                                   % copy last state to initial state
[var2, flux2]  = iso_221_var(tXT2, var_0, p, n_O, n_M, 0); % run iso_221_var
% catenate results for plotting
t = [t; t2]; var = [var; var2]; flux = [flux; flux2];
end

%% plot results
% unpack var: (n,13)-matrix with variables
%  cM_X1, cM_X2, M_E1, M_E2, M_V, M_H, cM_ER1, cM_ER2, q, h, S
%    cum food eaten, reserves, (max)structure, (max)maturity , cum allocation to reprod, accel, hazard, surv
 cM_X1 = var(:, 1); cM_X2   = var(:, 2); % mol, cumulative ingested food
 M_E1  = var(:, 3); M_E2    = var(:, 4); % mol, reserve
 E_H   = var(:, 5); max_E_H = var(:, 6); % J, maturity, max maturity
 M_V   = var(:, 7); max_M_V = var(:, 8); % mol, structure, max structure
 cM_E1R= var(:, 9); cM_E2R  = var(:,10); % mol, cumulative reprod
 q     = var(:,11); h       = var(:,12); % 1/d^2, 1/d, aging acceleration, hazard
 S     = var(:,13);                      % -, survival probability

% unpack flux: (n,20)-matrix with fluxes (most of it still needs to be coded)
%  f1, f2, J_X1A, J_X2A, J_E1A, J_E2A, J_EC1, J_EC2, J_EM1, J_EM2, J_VG, ...
%  J_E1J, J_E2J, J_E1R, J_E2R, R, ...
%  J_C, J_H, J_O, J_N
%    func responses, food eaten, assim, mobilisation, som. maint, growth, ...
%    mat. maint, maturation, reprod rate, ...
%    CO2, H20, O2, NH3
 f1 = flux(:,1);   f2 = flux(:,2);           % -, scaled functional response
 s1 = flux(:,3);   s2 = flux(:,4);           % -, stress coefficients
 rho_X1X2 = flux(:,5); rho_X2X1 = flux(:,6); % -, competition coefficients

close all % figures

figure
subplot(2,4,1)
plot(t, cM_X1, 'b', t, cM_X2, 'r')
xlabel('time since birth, d')
ylabel('cum food eaten, mol')
legend('X_1','X_2',2)

subplot(2,4,2)
plot(t, f1, 'b', t, f2, 'r')
xlabel('time since birth, d')
ylabel('scaled func resp, -')

subplot(2,4,3)
plot(t, M_E1, 'b', t, M_E2, 'r')
xlabel('time since birth, d')
ylabel('reserve, mol')
legend('protein','non-protein',4)

subplot(2,4,4)
plot(t, M_E1 ./ M_V, 'b', t, M_E2 ./ M_V, 'r')
xlabel('time since birth, d')
ylabel('reserve density, mol/mol')

subplot(2,4,5)
plot(t, M_V, 'g')
xlabel('time since birth, d')
ylabel('structure, mol')

subplot(2,4,6)
plot(t, (M_V/ MV).^(1/3), 'g')
xlabel('time since birth, d')
ylabel('length, cm')

subplot(2,4,7)
plot(t, E_H, 'g')
xlabel('time since birth, d')
ylabel('maturity, J')

subplot(2,4,8)
plot(t, cM_E1R, 'b', t, cM_E2R, 'r')
xlabel('time since birth, d')
ylabel('cum reprod, mol')

figure
subplot(1,3,1)
plot(t, s1, 'b', t, s2, 'r')
xlabel('time since birth, d')
ylabel('stress coefficients, -')
legend('protein','non-protein',4)

subplot(1,3,2)
plot(t, rho_X1X2, 'b', t, rho_X2X1, 'r')
xlabel('time since birth, d')
ylabel('competition coefficients, -')
legend('\rho_{X_1X_2}','\rho_{X_2X_1}',2)

subplot(1,3,3)
plot(t, S, 'g')
xlabel('time since birth, d')
ylabel('survival prob, -')
