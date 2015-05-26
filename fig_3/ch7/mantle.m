function f = mantle(p, x)
  K = p(1); K1 = p(2); % saturation coefficients

  X = x * (K + K1);
  Xc = X - K - K1;
  X0 = Xc/ 2 + sqrt(Xc .^2 + 4 * X * K)/ 2;
  f = X0 ./ (X0 + K);
