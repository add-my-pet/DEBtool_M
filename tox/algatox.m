function f = algatox(p, t, c)
  %  created 2002/02/05 by Bas Kooijman
  %
  %% Description
  %  effects on alga growth:
  %   (1) partial killing of inoculum
  %   (2) killing during growth
  %   (3) increase of costs for growth
  %   instantaneous equilibrium of internal concentration
  %   growth is assumed to be nutrient limited
  %     the nutrient pool is exchanging with a pool that is not available
  %     to the algae
  %   algal mass is measured in Optical Densities. The contribution
  %     of living, dead and ghost might differ. The toxic compound can
  %     tranfer living into dead biomass, the dead biomass decays to
  %     ghost biomass according to a first order process.
  %   the no-effect-conc for the three effects are taken to be the same
  %     might actually be different, however! 
  %
  %% Input
  %  p: (17,k) matrix with parameters values in p(:,1) (see below)
  %     01 mM, background nutrient
  %     02 mM, initial nutrient conc
  %     03 mM, initial biomass
  %     04 OD/mM, weight of living in optical density (redundant par)
  %     05 OD/mM, weight of dead in optical density
  %     06 OD/mM, weight of ghosts in optical density
  %     07 bmM, half saturation constant for nutrient
  %     08 mM/mM, yield of reserves on structure
  %     09 mM/(mM*h), max spec nutrient uptake rate
  %     10 1/h, reserve turnover rate
  %     11 1/h, exchange from nutrient to background
  %     12 1/h, exchange from background to nutrient
  %     13 1/h, dead biomass decay rate to ghost
  %     14 mM, no-effect concentration
  %     15 mM, tolerance conc for initial mortality
  %     16 mM, tolerance concentration for costs of growth
  %     17 1/(mM*h), spec killing rate
  %  t: (tn,1) matrix with exposure times
  %  c: (cn,1) matrix with concentrations of toxic compound
  %
  %% Outout
  %  f: (nt,nc) matrix with Optical Densities
  %
  %% Remarks
  %  uses routine dalgatox for integration
  %  Instantaneous equilibrium is assumed for the internal concentration.
  %  Growth is assumed to be nutrient limited, and the nutrient pool is exchanging with a pool that is not available to the algae. 
  %  Algal mass is measured in Optical Densities. The contribution of living biomass, dead biomass and ghost biomass might differ. 
  %  The toxic compound can tranfer living into dead biomass, the dead biomass decays to ghost biomass according to a first order process. 
  %  The no-effect-conc for the three effects are taken to be the same, but they might actually be different, however! 
  %
  %% Example of use
  %  see mydata_algatox
 

  global K yEV kN kE k0 kNB kBN c0 cH cy b ci;

  %% unpack parameter vector
  B0 = p(1);  % mM. background nutrient
  N0 = p(2);  % mM, initial nutrient conc
  X0 = p(3);  % mM, initial biomass
  w =  p(4);  % OD/mM, weight of living in optical density (redundant par)
  wd = p(5);  % OD/mM, weight of dead in optical density
  w0 = p(6);  % OD/mM, weight of ghosts in optical density
  K = p(7);   % mM, half saturation constant for nutrient
  yEV = p(8); % mM/mM, yield of reserves on structure
  kN = p(9);  % mM/(mM*h), max spec nutrient uptake rate
  kE = p(10); % 1/h, reserve turnover rate
  kNB = p(11);% 1/h, exchange from nutrient to background
  kBN = p(12);% 1/h, exchange from background to nutrient
  k0 = p(13); % 1/h, dead biomass decay rate to ghost
  c0 = p(14); % mM, no-effect concentration
  cH = p(15); % mM, tolerance conc for initial mortality
  cy = p(16); % mM, tolerance concentration for costs of growth
  b = p(17);  % 1/(mM*h), spec killing rate

  nt = max(size(t)); nc = max(size(c)); f = zeros (nt, nc);

  m0 = kN/ kE; % initial reserve density
  for i = 1:nc % loop across concentrations
    ci = c(i); % current concentration
    F = e^(-max(0,(c(i)-c0)/ cH)); % initial survival prob
    %% initial state vector background, nutrient, reserve, living, dead, ghost
    Y0 = [B0, N0, m0, X0*F, X0*(1-F), 0]';
    Y = ode23s('dalgatox', t, Y0); % integrate
    %% unpack state vector
    X = Y(:,4); Xd = Y(:,5); Xg = Y(:,6); % living, dead, ghost
    f(:,i) = w*X + wd*Xd + w0*Xg; % optical density
  end
