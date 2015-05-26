% script to illustrate cum_reprod

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
pars_cum_reprod = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];

t = 10*(1:50)'; Lf = [.1 .5];
[N, L, UE0, Lb, Lp, tb, tp, info] = cum_reprod(t, f, pars_cum_reprod, Lf);

subplot(2,3,1)
plot(t, N, 'r')
xlabel('time, d')
ylabel('cum reprod, #')

subplot(2,3,4)
plot(t, L, 'g', tp, Lp, 'or')
xlabel('time, d')
ylabel('struc length, cm')

% now with acceleration

%E_Hj = 20 * z^3;
U_Hj = E_Hj/ p_Am;
pars_cum_reprod_j = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp];
[N, L, UE0, Lb, Lj, Lp, tb, tj, tp, info] = cum_reprod_j(t, f, pars_cum_reprod_j, Lf);

subplot(2,3,2)
plot(t, N, 'r')
xlabel('time, d')
ylabel('cum reprod acc, #')

subplot(2,3,5)
plot(t, L, 'g', tp, Lp, 'or')
xlabel('time, d')
ylabel('struc length acc, cm')

% now with delayed acceleration

%E_Hs = 2 * z^3;
U_Hs = E_Hs/ p_Am;
pars_cum_reprod_s = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hs; U_Hj; U_Hp];
[N, L, UE0, Lb, Ls, Lj, Lp, tb, ts, tj, tp, info] = cum_reprod_s(t, f, pars_cum_reprod_s, Lf);

subplot(2,3,3)
plot(t, N, 'r')
xlabel('time, d')
ylabel('cum reprod d acc, #')

subplot(2,3,6)
plot(t, L, 'g', tp, Lp, 'or')
xlabel('time, d')
ylabel('struc length d acc, cm')

