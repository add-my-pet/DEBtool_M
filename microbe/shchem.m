function shchem (s)
  %% X: (nX,1)-vector with concentrations of CH4 (mM)
  %% N: (nN,1)-vector with concentrations of NH3 (mM)
  %% s: scalar with number of the selected compound: i = 1,2 ..,7
  %% flux: flux of X, C, H, O, N, E or V
  global jEAm KX KN kM kE yVE yEX Y
  
  %% reserve fluxes
  jEM = kM/ yVE; % flux of E in association with maintenance
  rm = (jEAm - jEM)/(jEAm/kE+1/yVE); % max spec growth rate
  nr = 100; r = linspace(0,rm,nr)'; % set growth rates
  mE = (jEM + r/yVE)./(kE-r); % reserve density at r
  jEA = mE*kE; % assim of E
  jEG = r/yVE; % flux of E in association with growth

  %% process rates, decomposed to: AC, AA, M, GC, GA
  k  = [(1/yEX - 1) * jEA, jEA, jEM*ones(nr,1), (1 - yVE) * jEG, yVE * jEG];
  %% fluxes of compounds (vector-valued reaction rate)
  flux = k*Y'; % flux of X, C, H, O, N, E, V

  %% plotting
  if s == 1
    xlabel('spec growth rate, 1/h'); ylabel('spec flux, mol/mol.h');
    plot (r, flux(:,1), 'g', r, flux(:,2), 'k', r, flux(:,4), 'r', ...
    r, flux(:,5), 'b', r, flux(:,6), 'k', [0;rm], [0;0], 'k');
  elseif s == 2
    xlabel('spec growth rate, 1/h'); ylabel('flux ratio, mol/mol');
    plot (r, flux(:,1)./flux(:,4), 'g', ...
	  r, flux(:,2)./flux(:,4), 'k', ...
	  r, flux(:,5)./flux(:,4), 'b', ...
	  [0;rm], [0;0], 'k');
  end