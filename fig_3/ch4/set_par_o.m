function par = set_par_o

  %path('U:\matlab\debtool\lib\misc;U:\matlab\debtool\lib\regr;U:\matlab\debtool\animal;',path)

  %% 2006/03/27 Set anchovy parameters
  tb = 135; % 1, d, day of birth in the year
  TA = 9800; % 2, K, Arrhenius temperature ; ref = after Regner 1996;
  T1 = 286; % 3, K, Reference temperature ; ; ref = ;
  TAL = 30000; % 4, K, Arrhenius temperature at low temp \cite[p57]{Kooy2000}
  TL = 281; % 5, K, lower boundary temp range
  TR = 285; % 6, K, temperature at start spawning
  K = .045; % 7, chlo_a/d.m^2, saturation constant
  %Hb = 0.0040 ;% , d.cm^2, scaled maturity at birth
  Lb = .1; % 8, d.cm^2, scaled maturity at birth
  Hj = 8  ;% 9, d.cm^2, scaled maturity at metamorphosis
  %Hp =100;% , d.cm^2, scaled maturity at puberty
  Lp = 1.6; % 10, d.cm^2, scaled maturity at puberty
  g = 6; % 11, -, energy investment ratio
  v = .031748 * 16.5838; % 12, cm, energy conductance * M shape correction factor
  kap = 0.65; % 13, was 0.65;% -, Veer
  kapR = 0.95; % 14, -, Fraction of reproduction energy fixed in eggs; ref = ;
  kM = .015; % 15, 1/d, somatic maintenance rate coeff
  kJ = kM;%.01; % 16, 1/d, maturity maintenance rate coeff
  vB = .1; % 17, cm/d, batch speed (low value gives large batches)
  vOA =0 ;%2e-6;% 18, mum/d, otolith speed for assimilation
  vOD =1.1861e-005; % 19, mum/d, otolith speed for dissipation
  vOG =.00011049; % 20, mum/d, otolith speed for growth
  %vOb  = 0;%.0002;% , mum/d, otolith speed for degradation
  delS = 20;% 21, -, shape of the otosac
  vOp  = 0;%.0003;% 22, mm/d, otolith speed for degradation   --> not used anymore
  d_V  = 1; % 23, g/cm^3, specific density of structure
  rho_E = 8000;% 24, J/g, = mu_E / w_E; reserve
  pAm = 22;%150; % 25, mol/d.cm^2, spec max assim rate {J_EAm}
  shape = 0.172; % 26, -, shape coefficient
  shapeOb = 1;%20; % 27, -, shape coefficient for embryo otolith in mm
  shapeOp = 0.401;%15; % 28, -, shape coefficient for adult otolith in mm
  spawn = 3/6; % 29, -, (approximate) length of spawning season as fraction of year
  p_rE =pAm  / rho_E;% 30 , g/cm^2/d^-1 , used for parameter estimation
  tm = 4 *365-150;% 31, end date of the simulation
  
    %% pack parameters
  par = [tb; TA; T1; TAL; TL; TR; K; Lb; Hj; Lp; g; v; kap; kapR; kM; kJ; vB; ...
	 vOA; vOD; vOG; delS; vOp; d_V; rho_E; pAm; shape; shapeOb; shapeOp; spawn;...
     p_rE ; tm];