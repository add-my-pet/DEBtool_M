function F = fnget_ep_min_j(par, g)
  f = par(1); p = par(2:7);
  [l_j, l_p, l_b] = get_lj(p, f);
  F = (l_p - (f - p(3)) * l_j/ l_b)^2
end
