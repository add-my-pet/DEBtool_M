%% mydata_reprod_rate
% script to illustrate reprod_rate

z = 1;           % -, zoom factor
F_m = 6.5;       % l/d.cm^2, {F_m} max spec searching rate
kap_X = 0.8;     % -, digestion efficiency of food to reserve
kap_X_P = 0.1;   % -, faecation efficiency of food to faeces
% kap_X_P does not affect state varables, only mineral and faeces fluxes
v = 0.02;        % cm/d, energy conductance
kap = 0.8;       % -, alloaction fraction to soma = growth + somatic maintenance
kap_R = 0.95;    % -, reproduction efficiency
p_M = 18;        % J/d.cm^3, [p_M] vol-specific somatic maintenance
p_T =  0;        % J/d.cm^2, {p_T} surface-specific som maintenance
k_J = 0.002;     % 1/d, maturity maint rate coefficient
E_G = 2800;      % J/cm^3, [E_G], spec cost for structure

% life stage parameters: b = birth; i = metamorphosis; p = puberty
% E_H is the cumulated energy from reserve invested in maturation
E_Hb = 275e-3 * z^3; % J, E_H^b, maturity at birth
E_Hs = E_Hb + 1e-5;  % J, E_H^s, maturity at start acceleration
E_Hj = E_Hb + 2e-5;  % J, E_H^j, maturity at end acceleration
E_Hp = 50 * z^3;     % J, E_H^p, maturity at puberty

f = 1;               % -, scaled functional response 

p_Am = z * p_M/ kap; E_m = p_Am/ v; g = E_G/ kap/ E_m; k_M = p_M/ E_G; L_T = 0; 
U_Hb = E_Hb/ p_Am; U_Hp = E_Hp/ p_Am;
pars_reprod_rate = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];

L = (.001:.05:1)'; Lf = [.15 .5]; 
[R, UE0, Lb, Lp, info] = reprod_rate(L, f, pars_reprod_rate, Lf);

subplot(1,3,1)
plot(L, R, 'r', Lp, 0, 'or')
xlabel('length, cm')
ylabel('reprod rate, #/d')

% now with acceleration

E_Hj = 20 * z^3;
U_Hj = E_Hj/ p_Am;
pars_reprod_rate_j = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp];
[R, UE0, Lb, Lj, Lp, info] = reprod_rate_j(L, f, pars_reprod_rate_j, Lf);

subplot(1,3,2)
plot(L, R, 'r', Lp, 0, 'or')
xlabel('length, cm')
ylabel('reprod rate acc, #/d')

% now with delayed acceleration

E_Hs = 2 * z^3;
U_Hs = E_Hs/ p_Am;
pars_reprod_rate_s = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hs; U_Hj; U_Hp];
[R, UE0, Lb, Ls, Lj, Lp, info] = reprod_rate_s(L, f, pars_reprod_rate_s, Lf);

subplot(1,3,3)
plot(L, R, 'r', Lp, 0, 'or')
xlabel('length, cm')
ylabel('reprod rate d acc, #/d')
