function [X, t] = batch (fn, X_A0, X_B0, n_A, n_B)
  %% created 2000/10/17 by Bas Kooijman; modified 2009/09/29
  %% calculates substrate/product profiles in a batch reactor
  %% X(:,1)= X_A, X(:,2)= X_B, X(:,3)=X_C
  %% X_C0 = 0;

  global fname par

  if exist('n_A','var')==0
    n_A = 1;
  end
  if exist('n_B','var')==0
    n_B = 1;
  end
  fname = fn; par = [n_A; n_B];
  
  [t, X] = ode23('fnbatch', [0;100], [X_A0; X_B0; 0]);

  
