function dteL = dfno2f_tel(LO, teL)
%  called by o2f
%  f changes linearly from f_old to f_obs

global tc g v vOD vOG Lp Lm kap kapR delS
global df t_old f_old % from fno2cf

%  unpack vars
t = teL(1); E = teL(2);  L = teL(3);

cor_T = spline1(t, tc);
vT = v * cor_T;  % energy conductance
f = max(0, f_old + df * (t - t_old));

SC = cor_T * L^2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = max(0, kap * SC - SM); % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}

dE = vT * (f - E)/ L; % 1/d, change in scaled res density e = m_E/ m_Em
  
dL = max(0, kap * SC - SM) * v/ (3 * L^2 * g * kap);

vSG = vOG * SG;
svS = vOD * SD + vSG;
dLO = svS * (1 - delS * LO^3/ L^3)/ 3/ LO^2; % change in vol otolith length

dteL = [1/ dLO; dE/ dLO; dL/ dLO];
