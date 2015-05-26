function Y = yield(n)
  %% Y = yield(n)
  %% created at 2007/06/24 by Bas Kooijman
  %% n: 4,4-matrix with chemical indices for X, S, E, V
  %%    energy -, carbon substrate, reserve, structure in cols, CHON in rows
  %% Y: 8,5-matrix with yield coefficients
  %%    rows: C,H,O,N,X,S,E,V; columns: Ac, Aa, M, Gc, Ga
  %% calls yield_cat and yield_ana

  Y = [yield_cat(n(:,1)), yield_ana(n(:,2:3)), yield_cat(n(:,3)),\
       yield_cat(n(:,3)), yield_ana(n(:,3:4))];
  Y = [Y; -1 0 0 0 0; 0 -1 0 0 0; 0 1 -1 -1 -1; 0 0 0 0 1];
  %% n = [[1 0 0 0; 0 2 0 3; 2 1 2 0; 0 0 0 1], n];
  %% n * Y % must be 4,5-matrix of zeros
