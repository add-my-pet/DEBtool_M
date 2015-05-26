%% fnget_lp
% subfunction of get_lj, get_lj_foetus and get_lp

function f = fnget_lp(lp, a0, a1, a2, a3, lj, li, k, rB, vHj, vHp)
  % find lp such that f = 0
  
  tjrB = (li - lp)/ (li - lj); % exp(- tau_p r_B) for tau = scaled time since metam
  tjk = tjrB^(k/ rB);          % exp(- tau_p k)
  
  % f = 0 if vH(tau_p) = vHp for varying lp
  f = vHp + a0 + a1 * tjrB + a2 * tjrB^2 + a3 * tjrB^3 - (vHj + a0 + a1 + a2 + a3) * tjk;
end
