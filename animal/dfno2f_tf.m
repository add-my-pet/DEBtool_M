function deLLO = dfno2f_tf(t, eLLO)
%  called by fno2f_tf 
%  f is constant since birth

global tc g v vOD vOG Lp Lm kap kapR delS
global f  % from fno2cf_tf

%  unpack vars
E = eLLO(1); L = eLLO(2); LO = eLLO(3);

cor_T = spline1(t, tc);
vT = v * cor_T;  % energy conductance

SC = cor_T * L ^ 2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
SG = kap * SC - SM; % p_G/ {p_Am}
SD = (SM + (1 - (L > Lp) * kapR) * (1 - kap) * SG)/ kap; % p_D/ {p_Am}

dE = vT * (f - E)/ L; % 1/d, change in scaled res density e = m_E/ m_Em
  
dL = (kap * SC - SM) * v / (3 * L^2 * g * kap);

vSG = vOG * max(0,SG);
svS = vOD * SD + vSG;
dLO = svS * (1 - delS * LO^3/ L^3)/ 3/ LO^2; % change in vol otolith length

deLLO = [dE; dL; dLO];
