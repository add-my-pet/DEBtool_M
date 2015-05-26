function int = fnEL2_iso(t, f, lb, tb, rho, rhoB, hWG3, hW, hG)
% t: a * kM
% int: l(t)^2 * exp(- rho*t) * S(t)
% called by ssd_iso

if hWG3 > 100
    S = exp(- (hW * t).^3 - rho * t);
else
  hGt = hG * t;
  S = exp(6 * hWG3 * (1 - exp(hGt) + hGt + hGt .^ 2/2) - rho * t);
end
l = f - (f - lb) * exp( - rhoB * (t - tb));
int = S .* l.^2;