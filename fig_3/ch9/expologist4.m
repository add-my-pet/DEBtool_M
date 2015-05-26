function [X1 X2 X3 X4] = expologist4 (p, tX1, tX2, tX3, tX4)
  %% assumptions K = 0 (small saturation const); kM = 0 (no maintenance)

  %% unpack p
  N1 = p(1); % 1 initial his
  N2 = p(2); % 2 initial his
  N3 = p(3); % 3 initial his
  N4 = p(4); % 4 initial his
  Nb = p(5); % background his  
  X0 = p(6); % initial biomass
  jXm = p(7);% max spec uptake rate
  g = p(8);  % investment ratio
  kE = p(9); % reserve turnover rate

  rm = kE/ (1 + g); % max spec growth rate
  %% times at which his is finished
  t01 = log(1 + (Nb + N1) * rm/ (X0 * jXm))/rm; 
  t02 = log(1 + (Nb + N2) * rm/ (X0 * jXm))/rm;
  t03 = log(1 + (Nb + N3) * rm/ (X0 * jXm))/rm;
  t04 = log(1 + (Nb + N4) * rm/ (X0 * jXm))/rm;
  a1 = exp(rm * t01); Xt01 = X0 * a1; % biomass at t1 
  a2 = exp(rm * t02); Xt02 = X0 * a2; % biomass at t2 
  a3 = exp(rm * t03); Xt03 = X0 * a3; % biomass at t3 
  a4 = exp(rm * t04); Xt04 = X0 * a4; % biomass at t4 
  
  [nX1 k] = size(tX1); X1 = zeros(nX1,1);
  [nX2 k] = size(tX2); X2 = zeros(nX2,1);
  [nX3 k] = size(tX3); X3 = zeros(nX3,1);
  [nX4 k] = size(tX4); X4 = zeros(nX4,1);

  for i = 1:nX1 % biomass data
    t = tX1(i,1);
    if t < t01 % still his available
      X1(i) = X0 * exp(t * rm);
    else % no his in environment
      X1(i) = Xt01 * (1 + g)/ (exp(- kE * (t - t01)) + g);
    end
  end

  for i = 1:nX2 % biomass data
    t = tX2(i,1);
    if t < t02 % still his available
      X2(i) = X0 * exp(t * rm);
    else % no his in environment
      X2(i) = Xt02 * (1 + g)/ (exp(- kE * (t - t02)) + g);
    end
  end

  for i = 1:nX3 % biomass data
    t = tX3(i,1);
    if t < t03 % still his available
      X3(i) = X0 * exp(t * rm);
    else % no his in environment
      X3(i) = Xt03 * (1 + g)/ (exp(- kE * (t - t03)) + g);
    end
  end

  for i = 1:nX4 % biomass data
    t = tX4(i,1);
    if t < t04 % still his available
      X4(i) = X0 * exp(t * rm);
    else % no his in environment
      X4(i) = Xt04 * (1 + g)/ (exp(- kE * (t - t04)) + g);
    end
  end