function f = clim(p, tOD)
  %  created 2002/02/11 by Bas Kooijman, modified 2011/04/12
  %
  %% Description
  %  Algal growth is assumed to be carbon limited
  %   the CO2 pool is exchanging with a HCO3 pool that is not available
  %   to the algae; algal mass is measured in Optical Densities.
  %
  %% Input
  %  p: (9,k) matrix with parameters values in p(:,1) (see below)
  %  tOD: (tn,2) matrix with exposure times
  %
  %% Output
  %  f: (nt, 1) matrix with Optical Densities
  %
  %% Remarks
  %  uses routine dclim for integration
  %
  %% Example of use
  %  see mydata_clim
 
  global K yEV kC kE k0 kCB kBC;

  %% unpack parameter vector
  B0 = p(1);  % mM. background nutrient
  C0 = p(2);  % mM, initial nutrient conc
  X0 = p(3);  % OD, initial biomass
  K = p(4);   % mM, half saturation constant for CO2
  yEV = p(5); % mM/OD, yield of reserves on structure
  kC = p(6);  % mM/(OD*h), max spec nutrient uptake rate
  kE = p(7); % 1/h, reserve turnover rate
  kCB = p(8);% 1/h, exchange from CO2 to HCO3
  kBC = p(9);% 1/h, exchange from HCO3 to CO2

  nt = max(size(tOD)); f = zeros (nt, 1);

  m0 = kC/ kE; % initial reserve density
  % initial state vector HCO3, CO2, reserve, biomass
  Y0 = [B0, C0, m0, X0]';
  [t Y] = ode23s('dclim', tOD(:,1), Y0); % integrate
  % unpack state vector
  f = Y(:,4); % biomass optical density