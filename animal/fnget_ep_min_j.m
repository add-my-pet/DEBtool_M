function F = fnget_ep_min_j(par, g)
  f = max(1e-4,par(1)); p = par(2:7);
  [l_j, l_p, l_b] = get_lj(p, f);
  F = f * (f - p(3))^2 * (l_j/ l_b)^3 - p(2) * p(6);
  if isempty(F) % no solution from get_lj
    F = 1/f;
  end
  F = F*F;
end
