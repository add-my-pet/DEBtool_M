function S = fnget_t50_s(t)
% modified 2010/02/25
% called by get_tm_s for life span at short growth periods
% integrate ageing surv prob over scaled age
% t: age * hW 
% S: ageing survival prob

global tG

hGt = tG * t; % age * hG
S = exp((1 + hGt + hGt.^2/2  - exp(hGt)) * 6/ tG^3) - .5; 