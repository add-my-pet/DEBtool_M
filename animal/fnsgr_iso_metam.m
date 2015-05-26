function res = fnsgr_iso_metam(f, rho, rho0, rhoB, sM, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG, tm)
  % called by sgr_iso_metam
  
  tm = max([5 * tp; roots3([hW^3 0 rho log(1e-12)], 1)]);
  res = quad('dsgr_iso_metam', tp, tm, [], [], f, rho, rho0, rhoB, sM, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG) - 1;
end