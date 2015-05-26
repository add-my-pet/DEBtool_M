function dL = starve(p, t)
  %% t: vector with time points
  %% unpack parameters
  %% assumption: L changes little
  L0 = p(1); g = p(2); kM = p(3); v = p(4); f = 0;
  %% g is actually g/e(0) 
  Lm = v/ (kM * g);  % max length time e(0)
  et = exp( - t(:,1) * v/ L0); % et is e(t)/e(0)
  delM = 0.333; % shape correction
  dL = (et - L0/ Lm) * v ./ (3 * (et + g) * delM);
