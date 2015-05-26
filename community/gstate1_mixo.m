function X = gstate1_mixo (X_t)
  %% created: 2001/09/07 by Bas Kooijman, modified 2009/01/05
  %% gets steady states from initial estimates for 1-reserve mixotrophs
  %% calls findstate1_mixo
  opt = optimset('display','off');

  global Ctot Ntot n_NV n_NE;
  
  X_t = state1_mixo(Ctot, Ntot);
  X = zeros(6,1);
  [X([3 4 5 6]), val, inf] = fsolve('findstate1_mixo', X_t([3 4 5 6]), opt);
  DV = X(3); DE = X(4); V = X(5); E = X(6); 
  
  X(1) = Ctot - DV - DE - V - E;
  X(2) = Ntot - n_NV*DV - n_NE*DE - n_NV*V - n_NE*E;
