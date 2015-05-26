function dx = dstate(t, x) % specification of dynamic system of B-model
  global KA KB yEA yEB yEV kE kM jAm jBm w h

  %% unpack state variables
  SA = x(1); SB = x(2); X = x(3); kA = x(4); kB = 1 - kA;
  mE = x(5); % reserve density

  fA = SA/ (SA + KA); fB = SB/ (SB + KB); % scaled functional responses
  jA = kA * jAm * fA; jB = kB * jBm * fB; % uptake rates
  r = (kE * mE - kM)/ (mE + yEV); % specific growth rate

  dSA = - jA * X; dSB = - jB * X; % change in substrate conc
  dX = r * X; % change in biomass
  dkA = (r + h) * kA * (fA/ (kA * fA + w * kB * fB) - 1); % change in kappa
  dmE = yEA * jA + yEB * jB - mE * kE; % change in reserve density
  
  dx = [dSA; dSB; dX; dkA; dmE]; % pack derivetives
