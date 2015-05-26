function h = haz_fm2(x, t)
  %  x: dummy (not used)
  %  t: time
  %  h: hazard rate for binary mixture
  %  called by fomort2 via haz2surv

  global h0 CA0 CB0 bA bB kA kB dAB % model parameters
  global cA cB % external forcing variables

  CA = (1 - exp(- t * kA)) * cA; % internal conc of A in external units
  CB = (1 - exp(- t * kB)) * cB; % internal conc of B in external units

  if 1 > CA/ CA0 + CB/ CB0
    CAe = 0; CBe = 0;
  else
    wA = (CA/ CA0)/ (CA/ CA0 + CB/ CB0); wB = 1 - wA;
    CAe = max(0, CA - CA0 * wA); % effective conc of A
    CBe = max(0, CB - CB0 * wB); % effective conc of B
  end
  
  h = h0 * t; % blank hazard rate 
  h = max(0, h + bA * CAe + bB * CBe + dAB * CAe .* CBe); % total hazard rate
