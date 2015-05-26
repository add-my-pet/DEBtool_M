function k = flux_5 (r, par)
  %% k = flux_5 (r, par)
  %% created at 2007/06/24 by Bas Kooijman
  %% r: n-vector with specific growth rates
  %% par: 5-vector with parameter values
  %% k: n,5-matrix with fluxes Ac Aa M Gc Ga

  %% unpack parameters
  yEX = par(1);  % mol/mol, yield of reserve on substrate
  yVE = par(2);  % mol/mol, yield of structure on reserve
  jEAm = par(3); % mol/mol.h, max spec assim flux
  kE = par(4);   % 1/h, reserve turnover
  kM = par(5);   % 1/h, maint rate coeff

  yXE = 1/yEX; % mol/mol
  yEV = 1/yVE; % mol/mol
  jEM = kM * yEV; % mol/(mol.h), spec maint flux
  rm = (jEAm - jEM)/ (jEAm/ kE + yEV);  % 1/h max spec growth rate

  r = r(:); nr = length(r); % turn r into a column vector
  mE = yEV * (r + kM) ./ (kE - r); % reserve density
  jEA = kE * mE;                   % spec assim flux
  jEG = r * yEV;                   % spec growth flux

  %% fluxes Ac Aa M Gc Ga
  k = [(yXE - 1) * jEA, jEA, jEM * ones(nr,1), (1 - yVE) * jEG, yVE * jEG];
