function deLLO = df2o_ello(t,eLLO,v,g,Lb,Lp,Lm,kap,kapR,vOD,vOG,delS)

global tc tf

%  unpack vars
E = eLLO(1); % scaled reserve density
L = eLLO(2); % body length
LO = eLLO(3); % ololith length

cor_T = spline1(t,tc); % temp correction factor
f = spline1(t,tf); % scaled functional response
vT = v * cor_T; % energy conductance

SC = cor_T * L ^ 2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = max(0, kap * SC - SM); % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}

dE = vT * ((L > Lb) * f - E)/ L; % 1/d, change in scaled res density e = m_E/ m_Em
  
dL = max(0, kap * SC - SM) * v / (3 * L^2 * g * kap);

vSG = vOG * SG;
svS = vOD * SD + vSG;
dLO = svS * (1 - delS * LO^3/ L^3)/ 3/ LO^2; % change in vol otolith length

deLLO = [dE; dL; dLO];
