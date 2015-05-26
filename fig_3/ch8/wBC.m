function logBC = wBC(p, logw)
  %% unpack parameters
  b = p(1); c = p(2); d = p(3);
  %% W = a L^3 + b L^4; BC = 10^c (1 + d L)
  %% without loss of generality: a = 1
  nw = length(logw); logBC = zeros(nw,1);
  for i = 1:nw
    f = 1; W = 10^logw(i,1);
    L = W^(1/3);
    while f^2 > 1e-10 % find L
      f = L^3 + b * L^4 - W; % norm
      df = 3 * L^2 + 4 * b * L^3; % d/dL norm
      L = L - f/df; % Newton-Raphson step in L
    end
    logBC(i) = c + log10(1 + d * L);
  end