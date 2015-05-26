function r = growth(p, mrwm)
  %% mrwm: (:,1) cell quota 1
  %%       (:,2) specific growth rates
  %%       (:,3) weight coefficients
  %%       (:,4) cell quata 2
  %% r: specific growth rate
  
  %% unpack parameters
  kP = p(1);  kB = p(2); kMP = p(3); kMB = p(4);  yPV = p(5); yBV = p(6); 
  %% compound parameters
  jPM = yPV * kMP; jBM = yBV * kMB;

  
  kB = kP; % equal turnover rates, but fix kB!!
  
  nr = length(mrwm(:,1)); r = zeros(nr,1);
  for i = 1:nr
    mP = mrwm(i,1) - yPV; mB = mrwm(i,4) - yBV;
    r(i) = find_r([mP mB], [kP kB], [jPM jBM], [yPV yBV]);
  end