function res = fnsgr_iso(f, rho, rho0, rhoB, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG, tm)
% integrate the characteristic equation
% subfunction of sgr_iso

res = quad('dsgr_iso', tp + 1e-8, tm, [], [], f, max(0, rho), rho0, rhoB, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG) - 1;

