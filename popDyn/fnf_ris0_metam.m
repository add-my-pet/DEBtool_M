function res = fnf_ris0_metam(f,x)
% created at 2011/04/26 by Bas Kooijman

global hW sG
global rhoB lp tp tm hWG3 hG rho0 g lT vHb vHj vHp k kap kapR

f = max (1e-10, min(1-1e-10, real(f)));
hG = sG * g * f^3; % hG/ kM
hWG3 = (hW/ hG)^3; 

[uE0 lb info_ue0] = get_ue0([g k vHb], f);

[tj tp tb lj lp lb li rj rB info_tp] = get_tj([g k lT vHb vHj vHp], f, lb);
if info_ue0 ~= 1 || info_tp ~= 1
    f = 1;
end
rho0 = kapR * (1 - kap)/ uE0;
rhoB = 1/(3 + 3 * f/ g); % rB/ kM

res = quad('dsgr_iso', tp, tm) - 1;
