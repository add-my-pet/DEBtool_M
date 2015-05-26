function N = survb (p,tN)
  %% assumption tN(:,1) are integers

  %% unpack parameters
  N0 = p(1); % %, initial number of individuals
  N1 = p(2); % %, number that suffer from random death
  hi = p(3)/ 365; % 1/t, random death rate
  hM = p(4)/ 365^2; % 1/a^3, maintenance death ha kM/6
  hR = p(5)/ 365^3; % 1/a^2, reproduction death ha e0/ kapR g l^3
  %% h's are given in years to avoid small numbers
  
  global tR
  
  [nt k] = size(tN); na = 1 + round(tN(nt, 1)); a = (1:na)'; R = a;
  for i = 1:na
    R(i) = tR(1+sum(a(i)<tR(:,1)),2);
  end
  S = exp(- hM * a .^ 3 - hR * cumsum(cumsum(cumsum(R))));
  tN(:,1)
  S = S(1 + tN(:,1));
  N = S .* (N0 - N1 + N1 * exp(- hi * tN(:,1)));
