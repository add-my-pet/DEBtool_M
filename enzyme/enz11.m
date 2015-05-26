function [J_C, theta] = enz11 (X_A, X_B, n_A, n_B)
  %% created 2000/10/17 by Bas Kooijman
  %% calculates pruduct flux from substrate concentrations X_A and X_B
  %%   in the transformation 1A + 1B -> 1C for a general enzyme
  
  global b_A b_B k_A k_B k_C J_Cm;
  
  K_A = k_A/k_B;
  K_C = k_C/k_B;

  nX_A = max(size(X_A));
  nX_B = max(size(X_B));
  J_C = zeros(nX_A,nX_B);
  for k = 1:nX_A
    for l = 1:nX_B  
      x_A = X_A(k)*b_A/k_A; 
      x_B = X_B(l)*b_B/k_B;
      A = [1, 1, 1, 1; ...
        x_A*K_A, -x_B-K_A, 0, 1; ...
        x_B, 0, -1-x_A*K_A, K_A; ...
        0, x_B, x_A*K_A, -1-K_A-K_C];
      theta = A\[1;0;0;0];
      J_C(k,l) = J_Cm*theta(4);
    end
  end
 
       

  