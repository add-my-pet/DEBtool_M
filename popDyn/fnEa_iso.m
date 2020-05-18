function int = fnEa_iso(t, rho, hWG3, hW, hG)
% t: a/kM
% int: t * exp(- rho*t) * S(t)
% called by ssd_iso


if hWG3 > 100
  int = t .* exp(- (hW * t).^3 - rho * t);
else
  hGt = hG * t;
  int = t .* exp(6 * hWG3 * (1 - exp(hGt) + hGt + hGt .^ 2/2) - rho * t);
end
