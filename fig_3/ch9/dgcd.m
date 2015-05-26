function dx = dgcd(t,x)
  global D xr jcoli jdisco Kcoli Kdisco kEcoli kEdisco gcoli gdisco ...
      kMcoli kMdisco;

  %% unpack state variables
  glu = x(1); coli = x(2); disco = x(3); ecoli = x(4); edisco = x(5);

  rcoli = (kEcoli * ecoli - kMcoli * gcoli)/ (ecoli + gcoli);
  rdisco = (kEdisco * edisco - kMdisco * gdisco)/ (edisco + gdisco);
  fcoli = glu/ (Kcoli + glu);
  fdisco = coli/ (Kdisco + coli);
  dglu = D * (xr - glu) - jcoli * fcoli * coli;
  dcoli = (rcoli - D) * coli - jdisco * fdisco * disco;
  ddisco = (rdisco - D) * disco;
  decoli = kEcoli * (fcoli - ecoli);
  dedisco = kEdisco * (fdisco - edisco);

  dx = [dglu; dcoli; ddisco; decoli; dedisco];