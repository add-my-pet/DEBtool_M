function dnEP = ddiffuF(t, nEP) % solitary feeding
  global k kE kP DE DP JF dL LR

  n = length(nEP)/ 2; dnEP = zeros(2 * n,1);
  %% enzymes
  dnEP(1) = 2 * JF/ dL - 2 * JF/ LR + 2 * DE * (nEP(2) - nEP(1))/ dL^2 ...
      - kE * nEP(1);
  for i = 2 : (n - 1)
    L = LR + dL * (i - 1);
    dnEP(i) = DE * (nEP(i+1) + nEP(i-1) - 2 * nEP(i))/ dL^2 - kE * nEP(i) ...
       + DE * (nEP(i+1) - nEP(i-1))/ (L * dL);
  end
  L = LR + dL * (n - 1);
  dnEP(n) = 2 * DE * (nEP(n-1) - nEP(n))/ dL^2 - kE * nEP(n) ...
          + 2 * DE * nEP(n)/ (L * dL);

  %% metabolites
  dnEP(n+1) = - 2 * k * nEP(n+1) + 2 * DP * (nEP(n+2) - nEP(n+1))/ dL^2 ...
    + kP * nEP(1);
  for i = (n + 2) : (2 * n - 1)
    L = LR + dL * (i - n - 1);
    dnEP(i) = DP * (nEP(i+1) + nEP(i-1) - 2 * nEP(i))/ dL^2 ...
	+ kP * nEP(i-n) + DP * (nEP(i+1) - nEP(i-1))/ (L * dL);
  end
  L = LR + dL * (n - 1);
  dnEP(2 * n) = 2 * DP * (nEP(2*n-1) - nEP(2*n))/ dL^2 + kP * nEP(n) ...
              + 0*2 * DP * nEP(2*n)/ (L * dL);
