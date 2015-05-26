function J_C = su (X_A, X_B, n_A, n_B)
  %% created 2000/10/17 by Bas Kooijman; modified 2009/09/29
  %% calculates pruduct flux from substrate concentrations X_A and X_B
  %%   in the transformation n_A A + n_B B -> 1 C for a Synthesizing Unit
  
  global b_A b_B k_C J_Cm

  if exist('n_A','var') == 0
    n_A = 1;
  end
  if exist('n_B','var') == 0
    n_B = 1;
  end
  
nX_A = max(size(X_A));
nX_B = max(size(X_B));
J_C = zeros(nX_A,nX_B);
for k=1:nX_A
   for l=1:nX_B   
     x_A = X_A(k)*b_A/k_C; 
     x_B = X_B(l)*b_B/k_C;
     sx = x_A + x_B;
     A = 0;
     for i = 0:(n_A - 1)
       for j= 0:(n_B - 1)
         A = A + nchoosek(i+j, j)*x_A^i*x_B^j/ sx^(1+i+j);
       end
     end
  
     J_C (k,l) = J_Cm/(1 + n_A/x_A + n_B/x_B - A);
  end
end


       
     