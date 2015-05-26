function [X N] = monod (p, tX, tN)
  %% assumptions: kM = 0 (no maintenance), reserve turnover rate kE = infty

  global T X0 Xi K Y jXm
  
  %% unpack p
  N0  = p(1); % initial nutrient
  X0  = p(2); % initial biomass
  jXm = p(3); % max spec uptake rate
  Y   = p(4); % yield of biomass on nutrient
  K   = p(5); % half-saturation constant

  Xi = X0 + Y * N0; % asymptotic biomass

  [nX k] = size(tX); [nN k] = size(tN); X = zeros(nX,1); N = zeros(nN,1);

  x0 = X0; % guess for first biomass
  for i = 1:nX % scan biomass values
    T = tX(i,1); % set time
    X(i) = fsolve('fnmonod', x0); x0 = X(i); % continuation
  end

  x0 = X0; % guess for first biomass
  for i = 1:nN % scan nutrient values
    T = tN(i,1); % set time
    x = fsolve('fnmonod', x0); x0 = x;  % continuation
    N(i) = N0 - (x - X0)/Y;
  end
