% maturity_

  kap = 0.8; 
  kapR = 0.95; 
  g = 0.1; 
  kJ = 0.002; 
  kM = 0.1;  
  LT =  0.2; 
  v = 0.02; 
  UHb = 0.2; 
  UHs = 0.200001; 
  UHj = 1.200002; 
  UHp = 20;
  
  L = [.2; .4; 0.6; .8];
  f = 1;

  par_mat   = [kap; kapR; g; kJ; kM; LT; v; UHb; UHp];
  par_mat_j = [kap; kapR; g; kJ; kM; LT; v; UHb; UHj; UHp];
  par_mat_s = [kap; kapR; g; kJ; kM; LT; v; UHb; UHs; UHj; UHp];
  
  [UH, a, info]     = maturity(L, f, par_mat);
  [UH_j, a_j, info] = maturity_j(L, f, par_mat_j);
  [UH_m, info]      = maturity_metam(L, f, par_mat_j);
  [UH_s, a_s, info] = maturity_s(L, f, par_mat_s);
  
  [UH, UH_j, UH_m, UH_s]
  [a, a_j, a_s]