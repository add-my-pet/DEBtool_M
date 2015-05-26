function X = conc_v1 (p, h)
  %% con of substrate at given throughput rate for V1-morphs
  %%  after period t in batch culture (i.e. sample)
  global X0 K k t

  %% unpack parameters
  K = p(1); kE = p(2); kM = p(3); g = p(4); hm = p(5); t = p(6);

  f = g * (kM + h(:,1)) ./ (kE - h(:,1)); % Eq (3.38) {108} 
  X = K * f ./ (1 - f); nX = length(X);
  if t ~= 0
    fm = g * (kM + hm) ./ (kE - hm); Xr = K * fm ./ (1 - fm);
    for i = 1:nX
      X0 = X(i); k = (Xr - X0) * h(i,1)/ f(i); 
      [tt Xt] = ode23('fnconc_v1', [0;t], X0); X(i) = Xt(end);
    end
  end  
