function dL = do2f_l(LO, L)
%  called by o2f_init
%  f_mean is constant since birth

global g v vOD vOG Lp Lm kap kapR delS
global f_mean cor_T% from fno2cf_tf

E = f_mean; 

%vT = v * cor_T;  % energy conductance

SC = cor_T * L ^ 2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = max(0, kap * SC - SM); % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}
  
dL = (kap * SC - SM) * v / (3 * L^2 * g * kap);

vSG = vOG * SG;
svS = vOD * SD + vSG;
dLO = svS * (1 - delS * LO^3/ L^3)/ 3/ LO^2; % change in vol otolith length

dL = dL/dLO;
