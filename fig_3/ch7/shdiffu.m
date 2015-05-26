function shdiffu(n,p)
  global k kE kP DE DP JE JF dL LR

  k = p(1); kE = p(2); kP = p(3); DE = p(4); DP = p(5); JE = p(6);
  dL = p(7); LR = p(8); JF = JE * pi * LR^2; 
  LE = sqrt(DE/kE);

  nEP0 = zeros(2 * n, 1); L = LR + dL * (0:(n - 1))';
  nt = 5; t = linspace(0, 500, nt)';
  [t nEPF] = ode23('ddiffuF', t, nEP0);
  [t nEP] = ode23('ddiffuE', t, nEP0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  hold on

  subplot(2,2,1);
  %% gset yrange [0:50]
  for i = 2:nt
    plot(L, nEP(i,1:n)', 'r', L, nEP(i,(n+1):(2*n))', 'g')
  end
  nPi = JE * kP * LE/ (kE * DP);
  nE = exp((LR - L)/ LE) * JE/ (kE * LE);
  nP = (kP/ kE) * (JE * LE - DE * nE)/ DP;
  plot(L, nE,'m', L, nP, 'b')
  xlabel('distance')
  ylabel('conc enzyme/metabolites')
  
  subplot(2,2,2);
  %% gset yrange[*:*];
  plot(t, k * dL * nEP(:, n + 1)/ JE,'g', ...
       [0;t(nt)], [kP/kE; kP/kE],'r', ...
       t, k * dL * nEPF(:, n + 1)/ JE, 'b')
  xlabel('time')
  ylabel('y_{PE}')

  subplot(2,2,3)
  %% gset yrange [0:11]
  for i = 2:nt
    plot(L, nEPF(i,1:n)', 'r', L, nEPF(i,(n+1):(2*n)), 'g')
  end
  nE = (LR^2 ./ (L * (LR + LE))) .* exp((LR - L)/ LE) * JF/ (kE * LE);
  nP = (kP/ kE) * (DE/ DP) * (JF * LE * LR ./ (DE * (LE + LR)) - nE);
  plot(L, nE, 'm', L, nP, 'b') 
  xlabel('distance')
  ylabel('conc enzyme/metabolites')

