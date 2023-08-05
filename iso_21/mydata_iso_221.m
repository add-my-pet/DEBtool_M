%% mydata_iso_221
% created 2011/05/04 by Bas Kooijman, modified 2012/01/30, 2023/07/23
% isomorph with 1 structure
% 2 reserves: protein (1) and non-protein (2)
%  maintenance preferably paid from non-protein
%  fixed stochiometric requirements of protein and non-protein for growth
% 2 types of food
%  preference depends on stress of non-filled reserve

%% set parameters at T_ref = 293 K
p.M_X1      = 1e-3;   p.M_X2      = 1e-3;  % mol, size of food particle of type i
p.F_X1m     = 2;      p.F_X2m     = 3;     % dm^2/d.cm^2, {F_Xim} spec searching rates
p.y_P1X1    = 0.15;   p.y_P2X2    = 0.15;  % mol/mol, yield of feaces i on food i
p.y_E1X1    = 0.45;   p.y_E2X1    = 0.35;  % mol/mol, yield of reserve Ei on food X1 (protein, non-protein)
p.y_E1X2    = 0.35;   p.y_E2X2    = 0.45;  % mol/mol, yield of reserve Ei on food X2 (protein, non-protein)
p.J_X1Am    = 2.0e-3; p.J_X2Am    = 2.0e-3;% mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
p.v         = 0.02;   p.kap       = 0.8;   % cm/d, energy conductance, 
                                           % -, allocation fraction to soma
p.mu_E1     = 4e5;    p.mu_E2     = 6e5;   % J/mol, chemical potential of reserve i
p.mu_V      = 5e5;                         % J/mol, chemical potential of structure
p.j_E1M     = 0.09;   p.j_E2M = p.j_E1M*p.mu_E2/p.mu_E1; % mol/d.mol, specific som maint costs 
p.J_E1T     = 0;      p.J_E2T     = 0;     % mol/d.cm^2, {J_EiT}, spec surface-area-linked som maint costs
p.MV        = 4e-3;                        % mol/cm^3, [M_V] density of structure
p.k_J       = 0.002;  p.k1_J      = 0.002; % 1/d, mat maint rate coeff, spec rejuvenation rate                                    
p.rho1      = 0.01;   p.del_V     = 0.8;   % -, preference for reserve 1 to be used for som maint
                                           % -, threshold for death by shrinking
p.y_VE1     = 0.8;    p.y_VE2     = 0.8;   % mol/mol, yield of structure on reserve i 
p.kap_E1    = 0.8;    p.kap_E2    = 0.8;   % -, fraction of rejected mobilixed flux that is returned to reserve
p.kap_R1    = 0.95;   p.kap_R2    = 0.95;  % -, reproduction efficiency for reserve i
p.E_Hb      = 1e1;    p.E_Hp      = 2e4;   % J, maturity thresholds at birth, puberty
p.T_A       = 8000;   p.h_H       = 1e-5;  % K, Arrhenius temperature
                                           % 1/d, hazard due to rejuvenation
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
t = linspace(0,8e3,5e2)'; tX12T = [t, t, t, t]; % d, time points
tX12T(:,2) = 2;     tX12T(:,3) = 3;       % mol/dm^2, food densities (don't need to be constant)
tX12T(:,4) = 293;                               % K, temperature (does not need to be constant)

%% get state at birth
[var_b, a_b, M_E10, M_E20] = iso_21_b(p);
% var_b: cM_X1, cM_X2, M_E1, M_E2, E_H, max_E_H, M_V, max_M_V, cM_ER1, cM_ER2, q, h,  S
m_E1m = var_b(3)/ var_b(7); % mol/mol, max reserve 1 density
m_E2m = var_b(4)/ var_b(7); % mol/mol, max reserve 2 density
M_Vb = var_b(7); L_b = (M_Vb/ p.MV)^(1/3); % mol of structure, struc length at birth
fprintf('At initial: M_E10 = %g mol; M_E20 = %g mol\n', M_E10, M_E20);
fprintf('At birth:\n a_b = %g d; L_b = %g cm; M_Vb = %g mol;\n m_E1 = %g mol/mol; m_E2 = %g mol/mol\n', a_b, L_b, M_Vb, m_E1m, m_E2m);

%% get max size L_m, M_Vm
[L_m, m_E1m, m_E2m, M_Vm, info] = get_Lm_iso_21 (p);
fprintf('max struc length L_m = %g cm; max struc mass M_Vm = %g mol;\n', L_m, M_Vm);
%return

%% run iso_221
[var, flux]  = iso_221(tX12T, var_b, p, n_O, n_M); % from birth to t = tX12T(end,1)

if 1
% continue with a period with only food type 2
t2 = linspace(8e3,10e3,1e2)'; tX12T2 = [t2, t2, t2, t2]; % d, set time points
tX12T2(:,2) = 0; tX12T2(:,3) = 2e4; tX12T2(:,4) = 293;       % set food, temp
var_0 = var(end,:)';                                   % copy last state to initial state
[var2, flux2]  = iso_221(tX12T2, var_0, p, n_O, n_M, 0); % run iso_221
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
legend('X_1','X_2')

subplot(2,4,2)
plot(t, f1, 'b', t, f2, 'r')
xlabel('time since birth, d')
ylabel('scaled func resp, -')

subplot(2,4,3)
plot(t, M_E1, 'b', t, M_E2, 'r')
xlabel('time since birth, d')
ylabel('reserve, mol')
legend('protein','non-protein')

subplot(2,4,4)
plot(t, M_E1 ./ M_V, 'b', t, M_E2 ./ M_V, 'r')
xlabel('time since birth, d')
ylabel('reserve density, mol/mol')

subplot(2,4,5)
plot(t, M_V, 'g')
xlabel('time since birth, d')
ylabel('structure, mol')

subplot(2,4,6)
plot(t, (M_V/ p.MV).^(1/3), 'g')
xlabel('time since birth, d')
ylabel('length, cm')

subplot(2,4,7)
plot(t, E_H, 'g')
xlabel('time since birth, d')
ylabel('maturity, J')

subplot(2,4,8)
plot(t, cM_E1R, 'b', t, cM_E2R, 'r')
xlabel('time since birth, d')
ylabel('cum reprod buffer, mol')

figure
subplot(1,3,1)
plot(t, s1, 'b', t, s2, 'r')
xlabel('time since birth, d')
ylabel('stress coefficients, -')
legend('protein','non-protein')

subplot(1,3,2)
plot(t, rho_X1X2, 'b', t, rho_X2X1, 'r')
xlabel('time since birth, d')
ylabel('competition coefficients, -')
legend('\rho_{X_1X_2}','\rho_{X_2X_1}')

subplot(1,3,3)
plot(t, S, 'g')
xlabel('time since birth, d')
ylabel('survival prob, -')
