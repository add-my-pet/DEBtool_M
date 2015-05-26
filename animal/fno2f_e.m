function fn = fno2f_e(E, x)
% called by o2f for first data point only: LO = LO_b; L = L_b
% f is irrevelant here because food intake starts just after this point
% x: dummy for application of nmregr

global L_obs O_obs % from o2f
global t tc g vOD vOG Lp Lm kap kapR

L = L_obs; 

cor_T = spline1(t,tc); 

SC = cor_T * L^2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = max(0, kap * SC - SM); % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}
vSG = vOG * SG;
svS = vOD * SD + vSG;
O = vSG ./ svS; % opacity

fn = 1000 * (O - O_obs); % multiply by 1000 to increase accuracy