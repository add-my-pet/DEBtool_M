%% isotope
% Gets isotope frequencies in as functions of time

%%
function [tMd aA_out aD_out aG_out] = ...
      isotope(tTXd_, Md, p, nMO, aA_, aD_, aG_, odds_)
  %  created 2008/02/10 by Bas Kooijman , modified 2008/03/17
  
  %% Syntax
  % [tMd aA_out aD_out aG_out] = <../isotope.m *isotope*> (tTXd_, Md, p, nMO, aA_, aD_, aG_, odds_)
  
  %% Description
  %  Obtains the isotope frequencies of the chemical elements C, H, O and N in reserve and structure 
  %    as function of time, given the trajectories of temperature and food density with the isotope frequencies in food. 
  %
  % Input
  %
  % * tTXd_: (n,8)-matrix with cols (* = chem elements C,H,O,N)
  %
  %      time, temp, food dens X, del_*X, del_OO
  %
  % * Md: 13-vector with values for time t = 0
  %      res M_E(0), struc M_V(0), mat M_H(0), oto M_OD(0), oto M_OG(0), del_*E(0), del_*V(0)
  % * p: 17-vector with DEB-parameters
  %      {J_EAm}, {F_m}, y_EX, y_VE, v, [J_EM], {J_ET}, k_J, kap, kap_R, M_Hb,
  %      M_Hp, [M_V], y_PC, y_VE_D. kap_D, T_A, y_OE_D, y_OE_G, del_S
  % * nMO: (4,8)-matrix with elements in rows, compounds in cols
  %
  %      cols: CO2, H2O, O2, N-waste, food, structure, reserve, faeces
  %
  % * aA_: (5,8)-matrix with reshuffle coefficients for assimilation
  %
  %      rows prod E P C H N; cols: substr (X,O) for elements *;
  %      optional, default: complete reshuffling
  %
  % * aD_: (4,12)-matrix with reshuffle coefficients for dissipation
  %
  %      rows prod V C H N; cols: substr (E,V,O) for elements *
  %      optional, default: complete reshuffling
  %
  % * aG_: (4,8)-matrix with reshuffle coefficients for growth
  %
  %      rows prod V C H N; cols: substr (E,O) for elements *
  %      optional, default: complete reshuffling
  % * odds_: (4,4)-matrix with odds ratios
  %
  %      rows: elements *
  %      cols: X in assim A_a, E,V in dissi D_a, E in growth G_a
  %      optional (default ones)
  %
  % Output
  %
  % * tMd: (n,14)-matrix with cols
  %      time, res M_E, struc M_V, mat M_H, otol M_OD, otol M_OG,
  %      del_CE, del_HE, del_OE, del_NE, del_CV, del_HV, del_OV, del_NV
  % * aA_out; aD_out; aG_out specified aA, aD, aG
  
  %% Remarks
  % The theory of isotpe dynamics is discussed in
  % <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *Section 4.7 of the DEB book*>.
  
  %% Example of use
  % See <../mydata_isotope.m *mydata_isotope*>, which also uses function <otolith.html *otolith*> to get 13C in otoliths 
  %   under all 9 choices of selection from total, anabolic or catabolic fluxes of dissipation and growth. 

  global tTXd n_M n_O aA aD aG odds
  global JEAm yEX yVE JEM JET kJ kap kapR MHb MHp MV yPX yVE_D kapD TA
  global yOE_D yOE_G delS
  global K kM MEm mEm g Lm Lh T_ref Y_ME_A Y_ME_D Y_ME_G 

  nt = size(tTXd_,1); % number of time points
  tTXd = [tTXd_; tTXd_(nt,:)]; % copy to make global for isotope_flux
  tTXd(nt+1,1) = 100 + tTXd(nt,1); % always interpolate during integration

  T_ref = 286; % edit if necessary
  % unpack p; rates are at temp T_ref
  JEAm = p(1); b = p(2);    yEX = p(3); yVE = p(4);  v = p(5);
  JEM = p(6);  JET = p(7);  kJ = p(8);  kap = p(9);  kapR = p(10);
  MHb = p(11); MHp = p(12); MV = p(13); yPX = p(14); yVE_D = p(15); 
  kapD = p(16); TA = p(17); yOE_D = p(18); yOE_G = p(19); delS = p(20);

  % convert
  JXAm = JEAm/ yEX; % max spec food uptake rate
  K = JXAm/ b; % half saturation coefficient
  kM = yVE * JEM/ MV; % somatic maintenance rate coefficient
  MEm = JEAm/ v; % [M_Em] = {J_EAm}/v  max reserve density (mass/ vol)
  mEm = MEm/ MV; % max reserve density (mass/ mass)
  g = v * MV/ (kap * JEAm * yVE); % energy investment ratio
  Lm = v/ (kM * g); % maximum length
  Lh = JET/ JEM; % heating length

  % unpack nMO
  n_M = nMO(:, 1:4);  % chemical indices for minerals C H O N
  n_O = nMO(:, 5:8);  % chemical indices for organics X V E P

  % yields of organic compounds X V E P and minerals C H O N
  %   on reserve in assim, dissip, growth
  Y_MO = - inv(n_M) * n_O; % neglect mass in otoliths
  Y_OE_A = [-1/yEX; 0; 1; yPX/yEX]; Y_ME_A = Y_MO * Y_OE_A;
  % n_M * Y_ME_A  + n_O * Y_OE_A  % test, must be zeros
  Y_OE_D = [0; 0; 1; 0]; Y_ME_D = Y_MO * Y_OE_D;
  % the fact that V is substrate and product does not affect Y_ME_D
  % n_M * Y_ME_D  + n_O * Y_OE_D  % test, must be zeros
  Y_OE_G = [0; -yVE; 1; 0]; Y_ME_G = Y_MO * Y_OE_G;
  % n_M * Y_ME_G  + n_O * Y_OE_G  % test, must be zeros
  % notice that normalizing flux J_E* is a product in A, but substr in D,G
  %   so dioxygen flux Y_ME_*(3) (= substr) is neg in A, and pos in D, G

  % assign reshuffle parameters and odds ratios
  if exist('aA_','var') == 0;
    aA_ = [];
  end
  if isempty(aA_)
    % rows prod E P C H N; cols: substr (X,O) for elements *;
    Y_PE_A = [Y_OE_A(3) * n_O(:,3)'; % prod E, elements C H O N
	      Y_OE_A(4) * n_O(:,4)'; % prod P, elements C H O N
	    - Y_ME_A(1) * n_M(:,1)'; % prod C, elements C H O N
	    - Y_ME_A(2) * n_M(:,2)'; % prod H, elements C H O N
	    - Y_ME_A(4) * n_M(:,4)'];% prod N, elements C H O N
    s = sum(Y_PE_A, 1); Y_PE_A = Y_PE_A ./ [s;s;s;s;s]; 
    aA = Y_PE_A(:,[1 1 2 2 3 3 4 4]);
  else
    aA = aA_;
  end
  if exist('aD_','var') == 0;
    aD_ = [];
  end
  if isempty(aD_)
    % rows prod V C H N; cols: substr (E,V,O) for elements *
    Y_PE_D = [yVE_D * n_O(:,2)';    % prod V, elements C H O N
	      - Y_ME_D(1) * n_M(:,1)';  % prod C, elements C H O N
              - Y_ME_D(2) * n_M(:,2)';  % prod H, elements C H O N
	      - Y_ME_D(4) * n_M(:,4)']; % prod N, elements C H O N
    % V as product in D has yield y_VE_D, not Y_OE_D(2)
    s = sum(Y_PE_D, 1); Y_PE_D = Y_PE_D ./ [s;s;s;s];
    aD = Y_PE_D(:,[1 1 1 2 2 2 3 3 3 4 4 4]);
  else
    aD = aD_;
  end
  if exist('aG_','var') == 0;
    aG_ = [];
  end
  if isempty(aG_)
    % rows prod V C H N; cols: substr (E,O) for elements *
    Y_PE_G = [- Y_OE_G(2) * n_O(:,2)'; % prod V, elements C H O N
	      - Y_ME_G(1) * n_M(:,1)'; % prod C, elements C H O N
              - Y_ME_G(2) * n_M(:,2)'; % prod H, elements C H O N
	      - Y_ME_G(4) * n_M(:,4)'];% prod N, elements C H O N
    s = sum(Y_PE_G, 1); Y_PE_G = Y_PE_G ./ [s;s;s;s];
    aG = Y_PE_G(:,[1 1 2 2 3 3 4 4]);
  else
    aG = aG_;
  end
  aA_out = aA; aD_out = aD; aG_out = aG; % copy to output
  if exist('odds_','var') == 0;
    odds_ = [];
  end
  if isempty(odds_)
    odds = ones(4,4);
  else
    odds = odds_;
  end
  
  t = tTXd(1:nt,1); % time points
  [t, Md] = ode23s('isotope_flux', t, Md);
  tMd = [t, Md];
