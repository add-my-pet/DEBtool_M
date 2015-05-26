function [Xb, X] = gradb(p, lb, l)
  %% lb: vector of length from membrane (l0) to barrier (l2)
  %% l: vector of length from barrier (l2) to mantle border (l1)
  %%    length of position barrier l0 < l2 < l1

  %% unpack parameters
  K  = p(1); % saturation coefficient
  K1 = p(2); % saturation coefficient JXm/(4 pi D l0)
  X1 = p(3); % conc in mixed environment
  LD = p(4); % D/P: ratio diffisivity and permeability of barrier

  l0 = lb(1); % position of membrane
  l2 = l(1);  % position of barrier
  nl = length(l); l1 = l(nl); % position of outer edge of mantle

  %% from barrier to edge mantle
  K1 = K1 * (1 - l2/ l1);
  Xc = X1 - K - K1;
  X0 = Xc/ 2 + sqrt(Xc .^2 + 4 * X1 * K)/ 2; % conc at barrier outside

  %% conc in mantle outside barrier
  X = X1 - (X1 - X0) * (1 - l1 ./ l)/ (1 - l1/ l2); 

  %% from membrane to barrier
  X1 = X0 * (1 - LD/ l2); % conc at barrier inside
  K1 = K1 * (1 - l0/ l1 + LD * l0/ l2^2)/ (1 - l2/ l1);
  Xc = X1 - K - K1;
  X0 = Xc/ 2 + sqrt(Xc .^2 + 4 * X1 * K)/ 2; % conc at membrane

  %% conc in mantle inside barrier
  Xb = X1 - (X1 - X0) * (1 - l2 ./ lb)/ (1 - l2/ l0);
