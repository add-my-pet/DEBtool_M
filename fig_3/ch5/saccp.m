function [fGLU, fbio, fo2, fco2, fP1, fP2, fP3, fP4, fP5, fhm] = ...
      saccp (p, GLU, bio, o2, co2, P1, P2, P3, P4, P5, hm)

  %% unpack parameters
  nHE  = p(1);  nOE = p(2);  nNE = p(3);  % composition reserve
  nHV  = p(4);  nOV = p(5);  nNV = p(6);  % composition structure
  Xr   = p(7);   K1 = p(8);   K2 = p(9);  % glu conc in feed, sat coef, 
  kE   = p(10);  kM = p(11);  er = p(12); % res turnover, maint rate, error 
  yEV  = p(13); yEX = p(14);  kapA = p(15); % yields: yEX2 = yEX * kapA
  jXAm1 = p(16); jXAm2 = p(17); g = p(18); % max spec uptake, invest ratio
  z1A1 = p(19); z1A2 = p(20); z1D = p(21); z1G = p(22); % ethanol couplers
  z2A1 = p(23); z2A2 = p(24); z2D = p(25); z2G = p(26); % acetaldehyde couplers
  z3A1 = p(27); z3A2 = p(28); z3D = p(29); z3G = p(30); % acetic acid couplers
  z4A1 = p(31); z4A2 = p(32); z4D = p(33); z4G = p(34); % glycerol couplers
  z5A1 = p(35); z5A2 = p(36); z5D = p(37); z5G = p(38); % pyruvic acid couplers
  
  %% other compound pars, see {122} but now for V1 morphs, rather than iso's
  yVE = 1/yEV; mEm = 1/ (yVE * g); % max reserve capacity
  wV = 12 + nHV + 16 * nOV + 14 * nNV; % mol weight structure(C-mol)
  wE = 12 + nHE + 16 * nOE + 14 * nNE; % mol weight reserve  (C-mol)
  %% Biomass in g/l; the rest in (real) moles

  %% glucose concentration
  r = GLU(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; fGLU = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;

  %% biomass density
  %% Eq (9.11) {315}: X1 = conc structure: 0 = r (Xr - X) - f jXAm X1
  %% multiply X1 by (wV + mE * wE) for total biomass in gram
  r = bio(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = - .5 * (sqrt(B .^ 2 - 4 * A .* C) + B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  fbio = r .* (wV + mE * wE) .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);
  
  %% chemical indices
  %% minerals: CO2, H2O, O2, NH3
  nM = [1 0 0 0; 0 2 0 3; 2 1 2 0; 0 0 0 1]; 
  %% glu, V, E, P1 eth, P2 ac-ald, P3 ac-acid, P4 gly, P5 pyr-acid
  nO = [ 6   1   1 2 2 2 3 3;  % C
	12 nHV nHE 6 4 2 8 4;  % H
	 6 nOV nOE 1 1 4 3 3;  % O
	 0 nNV nNE 0 0 0 0 0]; % N
  
  %% specific O2 consumption
  r = o2(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  k = f * (jXAm1 + kapA * jXAm2); A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jX = - f1 * jXAm1 - f2 * jXAm2; % specific substrate consumption
  jV = 1000 * r;         % specific structure production rate (mmol/h.mol)
  jE = 1000 * r .* mE;   % specific reserve production rate   (mmol/h.mol)
  jP1 = z1D * kM * g + z1A1 * kE * f1+ z1A2 * kE * f2 + z1G * g * r;
  jP2 = z2D * kM * g + z2A1 * kE * f1+ z2A2 * kE * f2 + z2G * g * r;
  jP3 = z3D * kM * g + z3A1 * kE * f1+ z3A2 * kE * f2 + z3G * g * r;
  jP4 = z4D * kM * g + z4A1 * kE * f1+ z4A2 * kE * f2 + z4G * g * r;
  jP5 = z5D * kM * g + z5A1 * kE * f1+ z5A2 * kE * f2 + z5G * g * r;
  %% specific mineral fluxes 
  jM = - [jX, jV, jE, jP1, jP2, jP3, jP4, jP5] * nO'/nM'; 
  fo2 = - jM(:,3) ./ (wV + mE * wE); % O2 consumption (mM/h) per biomass (g)
  
  %% specific CO2 production
  r = co2(:,1); f = g * (kM  + r) ./ (kE - r); mE = f * mEm;
  k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jX = - f1 * jXAm1 - f2 * jXAm2; % specific substrate consumption
  jV = 1000 * r;         % specific structure production rate (mmol/h.mol)
  jE = 1000 * r .* mE;   % specific reserve production rate   (mmol/h.mol)
  jP1 = z1D * kM * g + z1A1 * kE * f1+ z1A2 * kE * f2 + z1G * g * r;
  jP2 = z2D * kM * g + z2A1 * kE * f1+ z2A2 * kE * f2 + z2G * g * r;
  jP3 = z3D * kM * g + z3A1 * kE * f1+ z3A2 * kE * f2 + z3G * g * r;
  jP4 = z4D * kM * g + z4A1 * kE * f1+ z4A2 * kE * f2 + z4G * g * r;
  jP5 = z5D * kM * g + z5A1 * kE * f1+ z5A2 * kE * f2 + z5G * g * r;
  %% specific mineral fluxes 
  jM = - [jX, jV, jE, jP1, jP2, jP3, jP4, jP5] * nO'/nM'; 
  fco2 = jM(:,1) ./ (wV + mE * wE); % CO2 prod (mM/h) per biomass (g)


  %% product concentrations: spec prod rate * biom/ throughput rate
  r = P1(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jP1 = z1D * kM * g + z1A1 * kE * f1 + z1A2 * kE * f2 + z1G * g * r; 
  fP1 = jP1 .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);

  r = P2(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jP2 = z2D * kM * g + z2A1 * kE * f1 + z2A2 * kE * f2 + z2G * g * r;
  fP2 = er * jP2 .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);

  r = P3(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jP3 = z3D * kM * g + z3A1 * kE * f1 + z3A2 * kE * f2 + z3G * g * r;
  fP3 = jP3 .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);

  r = P4(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jP4 = z4D * kM * g + z4A1 * kE * f1 + z4A2 * kE * f2 + z4G * g * r;
  fP4 = jP4 .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);
  
  r = P5(:,1); f = g * (kM  + r) ./ (kE - r); k = f * (jXAm1 + kapA * jXAm2);
  A = k - jXAm1 - kapA * jXAm2;
  B = k * (K1 + K2) - jXAm1 * K2 - kapA * jXAm2 * K1;
  C = k * K1 * K2; X = .5 * (- sqrt(B .^ 2 - 4 * A .* C) - B) ./ A;
  f1 = X ./ (X + K1); f2 = X ./ (X + K2);
  jP5 = z5D * kM * g + z5A1 * kE * f1 + z5A2 * kE * f2 + z5G * g * r;
  fP5 = jP5 .* (Xr - X) ./ (jXAm1 * f1 + jXAm2 * f2);
  
  %% max specific growth rate
  f1m = Xr/ (Xr + K1); f2m = Xr/ (Xr + K2); % max scaled func response
  fm = (jXAm1 * f1m + kapA * jXAm2 * f2m)/ (jXAm1 + kapA * jXAm2);
  fhm = (kE * fm - kM * g)/ (fm + g); % max throughput rate
