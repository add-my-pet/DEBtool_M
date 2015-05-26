function fn = fno2f(Df, x)
% Df: scalar with d/dt f(t)
% x: dummy for application of nmregr
% called by o2f for growth conditions
% f changes linearly from f_old to f_obs at rate df

global tc g vOD vOG Lp Lm kap kapR
global t_old E_old L_old LO_old O
global t_obs E_obs L_obs LO_obs O_obs% from o2cf
global df cor_T % to o2cf

df = Df; % copy to allow transfer as global to dfno2f_tel
[LO, teL] = ode23s('dfno2f_tel',[LO_old; LO_obs], [t_old; E_old; L_old]);
t_obs = teL(end,1); E_obs = teL(end,2); L_obs = teL(end,3);

cor_T = spline1(t_obs, tc);

E = E_obs; L = L_obs;
SC = cor_T * L ^ 2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = max(0, kap * SC - SM); % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}
vSG = vOG * SG;
svS = vOD * SD + vSG;
O = vSG ./ svS; % opacity

fn = 1000 * (O_obs - O); % multiply by 1000 for accuracy