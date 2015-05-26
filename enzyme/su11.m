function [J_C, theta] = su11 (X_A, X_B, n_A, n_B)
  %% created 2000/10/17 by Bas Kooijman
  %% calculates pruduct flux from substrate concentrations X_A and X_B
  %%   in the transformation 1A + 1B -> 1C for a Synthesizing Unit
  
  global b_A b_B k_C J_Cm;

  nX_A = max(size(X_A));
  nX_B = max(size(X_B));
  J_C = zeros(nX_A,nX_B);
  for k = 1:nX_A
    for l = 1:nX_B     
      x_A = X_A(k)*b_A/k_C; 
      x_B = X_B(l)*b_B/k_C;
      sx = x_A + x_B;
      theta = 1./[sx; sx*x_B/x_A; sx*x_A/x_B; 1];
      theta = theta./sum(theta);
      J_C(k,l) = J_Cm*theta(4);
    end
  end
 
     