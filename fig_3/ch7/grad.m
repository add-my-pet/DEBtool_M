function X = grad(p, l)
  %% l: vector of scaled length from membrane (l0) to mantle border (l1)

  %% unpack parameters
  K  = p(1); % saturation coefficient
  K1 = p(2); % saturation coefficient JXm/(4 pi D l0)
  X1 = p(3); % conc in mixed environment
  
  l0 = l(1); % position of membrane
  nl = length(l); l1 = l(nl); % position of outer edge of mantle


  K1 = K1 * (1 - l0/ l1);
  Xc = X1 - K - K1;
  X0 = Xc/ 2 + sqrt(Xc .^2 + 4 * X1 * K)/ 2;

  X = X1 - (X1 - X0) * (1 - l1 ./ l)/ (1 - l1/ l0);
