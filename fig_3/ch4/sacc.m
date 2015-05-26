function [fnHW, fnOW, fnNW, fGLU, fbio, fETH, fGLY, fPYR, ...
	  fco2, fglu, feth, fhm] = ...
      sacc (p, nHW, nOW, nNW, GLU, bio, ETH, GLY, PYR, ...
	    co2, glu, eth, hm)

  %% unpack parameters
  nHE = p(1);  nOE = p(2);  nNE = p(3);  % composition reserve
  nHV = p(4);  nOV = p(5);  nNV = p(6);  % composition structure
  Xr  = p(7);    K = p(8);               % glu conc in feed, sat coef, 
  kE  = p(9);   kM = p(10);              % res turnover, maint rate
  yVE = p(11); yXE = p(12);   g = p(13); % yields, en invest ratio
  zeA = p(14); zeD = p(15); zeG = p(16); % ethanol prod couplers
  zgA = p(17); zgD = p(18); zgG = p(19); % glycerol prod couplers
  zpA = p(20); zpD = p(21); zpG = p(22); % pyruvate prod couplers
  
  %% other compound pars, see {122} but now for V1 morphs, rather than iso's
  jXAm = yXE * kE/ (g * yVE); % max specific substrate uptake rate
  mEm = 1/ (yVE * g); % max reserve capacity
  wV = 12 + nHV + 16 * nOV + 14 * nNV; % mol weight structure(C-mol)
  wE = 12 + nHE + 16 * nOE + 14 * nNE; % mol weight reserve  (C-mol)
  wX = 12 + 2 + 16;                    % mol weight glucose  (C-mol)
  we = 12 + 3 + 16/2;                  % mol weight ethanol  (C-mol)
  wg = 12 + 8/3 + 16;                  % mol weight glycerol (C-mol)
  wp = 12 + 4/3 + 16;                  % mol weight pyruvate (C-mol)
  %% Xr and K in g/l; jXAm, yVE, yXE in C-moles
  %% product conc in g/l

  %% relationships between f and r and mE; yEV = 1/yVE
  %% (3.39): r = kE (f - ld)/(f + g); {411}: ld = kM g/kE;
  %%         r = (kE f - kM g)/(f + g);

  %% biomass composition (2.8) at {34}
  r = nHW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnHW = (nHV + mE * nHE) ./ (1 + mE);
  r = nOW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnOW = (nOV + mE * nOE) ./ (1 + mE);
  r = nNW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnNW = (nNV + mE * nNE) ./ (1 + mE);

  %% glucose concentration
  r = GLU(:,1); f = g * (kM  + r) ./ (kE - r); 
  fGLU = K * f ./ (1 - f);
  
  %% Eq (9.11) {315}: X1 = conc structure: 0 = r (Xr - X) - f jXAm X1
  %% multiply jXAm by wX for gram
  %% multiply X1 by (wV + mE * wE) for total biomass in gram
  r = bio(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fbio = r .* (wV + mE * wE) .* (Xr ./ f - K ./ (1 - f))/ (jXAm * wX);

  %% product concentrations: spec prod rate * biom/ throughput rate
  r = ETH(:,1); f = g * (kM  + r) ./ (kE - r);
  je = zeD * kM * g + zeA * kE * f + zeG * g * r; % Eq (4.33) {148}
  fETH = we * je .* (Xr ./ f - K ./ (1 - f))/ (jXAm * wX); %% g/l
  r = GLY(:,1); f = g * (kM  + r) ./ (kE - r);  
  jg = zgD * kM * g + zgA * kE * f + zgG * g * r; % Eq (4.33) {148}
  fGLY = wg * jg .* (Xr ./ f - K ./ (1 - f))/ (jXAm * wX); %% g/l
  r = PYR(:,1); f = g * (kM  + r) ./ (kE - r); 
  jp = zpD * kM * g + zpA * kE * f + zpG * g * r; % Eq (4.33) {148}
  fPYR = 1000 * wp * jp .* (Xr ./ f - K ./ (1 - f))/ (jXAm * wX); %% mg/l

  
  %% chemical indices
  nM = [1 0 0 0; 0 2 0 3; 2 1 2 0; 0 0 0 1]; % minerals (C,H,O,N)
  %% organics (X, V, E, ETH, GLY, PYR)
  nO = [1 1 1 1 1 1; 2 nHV nHE 3 8/3 4/3; 1 nOV nOE .5 1 1; 0 nNV nNE 0 0 0]; 
  
  %% specific CO2 production: (4.3)
  r = co2(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  jXA = -f * jXAm;          % specific substrate consumption
  jV = r;                   % specific structure production rate
  jE = r .* mE;             % specific reserve production rate
  je = zeD * kM * g + zeA * kE * f + zeG * g * r; % Eq (4.33) {148}
  jg = zgD * kM * g + zgA * kE * f + zgG * g * r; % Eq (4.33) {148}
  jp = zpD * kM * g + zpA * kE * f + zpG * g * r; % Eq (4.33) {148}
  jM = - [jXA, jV, jE, je, jg, jp] * nO'/nM'; % specific mineral fluxes  
  fco2 = 1000 * jM(:,1) ./ (wV + mE * wE); % CO2 prod (mM/h) per biomass (g)

  %% specific glucose consumption: (4.3)
  r = glu(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  jXA = f * jXAm;          % specific substrate consumption in real moles
  fglu =  (1000/6) * jXA ./ (wV + mE * wE); % glucose cons (mM/h) per biomass (g)

  %% specific ethanol production: (4.3)
  r = eth(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  %% production: Eq (4.33) {148} (in real moles, not C-moles)
  je = zeD * kM * g + zeA * kE * f + zeG * g * r; % specific ethanol flux
  feth = (1000/2) * je ./ (wV + mE * wE); % ethanol prod (mM/h) per biomass (g)

  %% max specific growth rate
  fm = Xr/ (Xr + K); % max scaled func response
  fhm = (kE * fm - kM * g)/ (fm + g); % max throughput rate
