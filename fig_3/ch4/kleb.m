function [fnHW, fnOW, fnNW, fYWX, fO2, fCO2, frm] = ...
      kleb (p, dnHW, dnOW, dnNW, dYWX, dO2, dCO2, drm)

  %% unpack parameters
  nHE = p(1); nOE = p(2); nNE = p(3);
  nHV = p(4); nOV = p(5); nNV = p(6);
  kE = p(7);  kM = p(8);
  yVE = p(9); yXE = p(10); g = p(11);
  %% other compound pars, see {122} but now for V1 morphs, rather than iso's
  jXAm = yXE * kE/ (g * yVE); % max specific substrate uptake rate
  mEm = 1/ (yVE * g); % max reserve capacity

  %% relationships between f and r and mE; yEV = 1/yVE
  %% (3.39): r = kE (f - ld)/(f + g); {411}: ld = kM g/kE;
  %%         r = (kE f - kM g)/(f + g);

  %% biomass composition (2.8) at {34}
  r = dnHW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnHW = (nHV + mE * nHE) ./ (1 + mE);
  r = dnOW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnOW = (nOV + mE * nOE) ./ (1 + mE);
  r = dnNW(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fnNW = (nNV + mE * nNE) ./ (1 + mE);

  %% specific substrate uptake rate from allocation to maintenance + growth 
  %% yield of biomass on substrate: ratio of biomass prod and substr consump
  %%   YWX = r (1+mE)/ ((kM + r + yVE mE) yXE/ yVE)
  r = dYWX(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  fYWX = r .* (1 + mE) ./ (f * jXAm);

  %% chemical indices
  nM = [1 0 0 0; 0 2 0 3; 2 1 2 0; 0 0 0 1]; % minerals (C,H,O,N)
  nO = [1 1 1; (8/3) nHV nHE; 1 nOV nOE; 0 nNV nNE]; % organics (X,V,E)
  
  %% specific O2 consumption: (4.3)
  r = dO2(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm; 
  jX = -f * jXAm;           % specific substrate consumption
  jV = r;                   % specific structure production rate
  jE = r .* mE;             % specific reserve production rate
  jM = - [jX, jV, jE] * nO'/nM'; % specific mineral fluxes
  fO2 = - jM(:,3) ./ (1 + mE);% ratio of O2 consumption and biomass

  %% specific CO2 production: (4.3)
  r = dCO2(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  jX = -f * jXAm;           % specific substrate consumption
  jV = r;                   % specific structure production rate
  jE = r .* mE;             % specific reserve production rate
  jM = - [jX, jV, jE] * nO'/nM'; % specific mineral fluxes  
  fCO2 =  jM(:,1) ./ (1 + mE); % ratio of CO2 prod and biomass

  %% max specific growth rate
  frm = (kE - kM * g)/ (1 + g);
