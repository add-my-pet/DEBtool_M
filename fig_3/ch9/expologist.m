function [X N] = expologist (p, tX, tN)
  %% assumptions K = 0 (small saturation const); kM = 0 (no maintenance)

  %% unpack p
  N0 = p(1); % initial nutrient
  X0 = p(2); % initial biomass
  jXm = p(3);% max spec uptake rate
  g = p(4);  % investment ratio
  kE = p(5); % reserve turnover rate

  rm = kE/ (1 + g); % max spec growth rate
  t0 = log(1 + N0 * rm/ (X0 * jXm))/rm; % time at which nutrient is finished
  a = exp(rm * t0); Xt0 = X0 * a; % biomass at t0 
  
  [nN k] = size(tN); N = zeros(nN,1); [nX k] = size(tX); X = zeros(nX,1);
  for i = 1:nX % biomass data
    t = tX(i,1);
    if t < t0 % still nutrient available
      X(i) = X0 * exp(t * rm);
    else % no nutrient in environment
      X(i) = Xt0 * (1 + g)/ (exp(- kE * (t - t0)) + g);
    end
  end

  for i = 1:nN % nutrient data
    t = tN(i,1);
    if t < t0 % still nutrient available
      N(i) = N0 * (a - exp(rm * t))/ (a - 1);
    else % no nutrient in environment
      N(i) = 0;
    end
  end