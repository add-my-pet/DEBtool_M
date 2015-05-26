function f = findt_pavlova(t, x)
  %% called from fig_5_5
  %% like find_pavlova, but with extra (unused) first argument
  global KP KB jPAm jBAm kP kB jPM jBM yPV yBV kapP kapB XrP XrB h;

  %% kB = kP; % set turnover rates equal; fix kB!!!
  
  %% unpack x
  MV = x(1); % biomass density
  XP = x(2); XB = x(3); % concentrations of nutrients
  mP = x(4); mB = x(5); % reserve densities
  ZP = x(6); ZB = x(7); % concentrations of excreted nutrients

  %% assimilation fluxes
  jPA = jPAm * XP/ (KP + XP);
  jBA = jBAm * XB/ (KB + XB);

  %% specific growth rate
  [r err] = find_r([mP mB], [kP kB], [jPM jBM], [yPV yBV]);
  if err ~= 1
    fprintf('Warning: no growth rate found \n'); 
  end
  
  %% rejection fluxes (5.16) {170}
  jPR = (kP - r) * mP - jPM - yPV * r;
  jBR = (kB - r) * mB - jBM - yBV * r;

  %% biomass dynamics
  dMV = (r - h) * MV;
  %% nutrient dynamics Eq (5.23) + (5.24) {171}
  dXP = (XrP - XP) * h - jPA * MV; 
  dXB = (XrB - XB) * h - jBA * MV; 
  %% reserve dynamics Eq (5.20) {171}
  dmP = jPA - r * mP - (1 - kapP) * (kP - r) * mP - kapP * (jPM + yPV * r);
  dmB = jBA - r * mB - (1 - kapB) * (kB - r) * mB - kapB * (jBM + yBV * r);
  %% excreted nutrient dynamics
  dZP = MV * ((1 - kapP) * jPR + jPM) - h * ZP;
  dZB = MV * ((1 - kapB) * jBR + jBM) - h * ZB;
  f = [dMV dXP dXB dmP dmB dZP dZB]';
