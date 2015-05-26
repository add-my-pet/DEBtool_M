%% fnget_sM
% subfunction in get_lj, get_lj_foetus

function f = fnget_sM(sM, f, lb, g, k, lT, vHb, vHj)
  rho_j = (f/ lb - 1 - lT/ lb)/ (1 + f/ g); % scaled exponential growth rate between b and j
  sM3kr = sM^(-3 * k/ rho_j);
  
  % f = 0 if vH(tau_j) = vHj for varying sM
  f = vHj - f * lb^3 * (1/ lb - rho_j/ g) * (sM^3 - sM3kr)/ (k + rho_j) - vHb * sM3kr;
end
