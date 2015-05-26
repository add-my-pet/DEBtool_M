function V_new = correct_v (V,F)
  %% V: (N,1)-vector with observed egg volumes
  %% F: (N,1)-vector with scaled functional responses
  %% V_new: (N,1)-vector with corrected egg volumes

  V_new = V; n = length(V);
  v = V - min(V);
  for i = 1:n
    w = exp( - 500 * (F(i) - F) .^ 2 - 75 * v .^ (1/3));
    V_new(i) = sum(w .* V)/ sum (w);
  end  
