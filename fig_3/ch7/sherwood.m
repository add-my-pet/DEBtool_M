function sh = sherwood(K1, x, l)
  nx = length(x); nl = length(l); sh = zeros(nx,nl);

  for i = 1:nx
    for j = 1:nl
      Kl = K1 * (1 - 1/(1 + l(j)));

      xc = x(i) - 1 - Kl;
      x0 = xc/ 2 + sqrt(xc .^2 + 4 * x(i))/ 2;
      f1 = x0 ./ (x0 + 1);

      xc = x(i) - 1 - K1;
      x0 = xc/ 2 + sqrt(xc .^2 + 4 * x(i))/ 2;
      f0 = x0 ./ (x0 + 1);

      sh(i,j) = f1/ f0;
    end
  end
  