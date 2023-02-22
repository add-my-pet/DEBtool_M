function dL = betaML_dL(ab, mlx, mlx1)
  % subroutine for betaML
  psiab = psi(ab(1)+ab(2));
  dL = [mlx + psiab - psi(ab(1)); mlx1 + psiab - psi(ab(2))];
end