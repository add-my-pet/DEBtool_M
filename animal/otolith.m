%% otolith
% Gets otolith length and color as function of time

%%
function tOd = otolith(tM, p, nMO, aA, aD, aG, odds)
  %  created by Bas Kooijman 2008/03/17
  
  %% Syntax
  % tOd = <../otolith.m *otolith*> (tM, p, nMO, aA, aD, aG, odds)
  
  %% Description
  % Gets otolith length and color as function of time
  %
  % Input
  %
  % * tM: (nt,15)-matrix with values for
  %
  %      time, res M_E, struc M_V, mat M_H, oto M_OD, oto M_OG,
  %      del_*E, del_*V, temp T, which is output from isotope
  %
  % * p: vector with parameters
  %
  % * nMO: (4,8)-matrix with elements in rows, compounds in cols
  %
  %      cols: CO2, H2O, O2, N-waste, food, structure, reserve, faeces
  %
  % * aA: (5,8)-matrix with reshuffle coefficients for assimilation
  %
  %      rows prod E P C H N; cols: substr (X,O) for elements *;
  %      not used in this version; output from isotope
  %
  % * aD: (4,12)-matrix with reshuffle coefficients for dissipation
  %
  %      rows prod V C H N; cols: substr (E,V,O) for elements *;
  %      output from isotope
  %
  % * aG: (4,8)-matrix with reshuffle coefficients for growth
  %
  %      rows prod V C H N; cols: substr (E,O) for elements *;
  %      output from isotope
  %
  % * odds: (4,4)-matrix with odds ratios
  %
  %      rows: elements *
  %      cols: X in assim A_a, E,V in dissi D_a, E in growth G_a
  %
  % Output
  %
  % * tOd: (nt,12)-matrix with time, otolith length & color, del_CO
  
  %% Remarks
  % Meant to be applied in combination with <../isotope.html *isotope*> 
  
  %% Example of use
  % See <../mydata_isotope.m *mydata_isotope*>

  global T_ref

  nt = size(tM,1); tOd = zeros(nt,12);

  % unpack chemical indices
  n_M = nMO(:,1:4); n_O = nMO(:,5:8);

  % unpack parameters
  JEAm = p(1); b = p(2);    yEX = p(3); yVE = p(4);  v = p(5);
  JEM = p(6);  JET = p(7);  kJ = p(8);  kap = p(9);  kapR = p(10);
  MHb = p(11); MHp = p(12); MV = p(13); yPX = p(14); yVE_D = p(15); 
  kapD = p(16); TA = p(17); yOE_D = p(18); yOE_G = p(19);

  kM = yVE * JEM/ MV; % somatic maintenance rate coefficient
  MEm = JEAm/ v; % [M_Em] = {J_EAm}/v  max reserve density (mass/ vol)
  mEm = MEm/ MV; % max reserve density (mass/ mass)
  g = v * MV/ (kap * JEAm * yVE); % energy inverstmet ratio
  Lm = v/ (kM * g); % maximum length
  Lh = JET/ JEM; % heating length

  for i = 1:nt
    % unpack state variables
    t = tM(i,1); M_E = tM(i,2); M_V = tM(i,3); M_H = tM(i,4);
    M_OD = tM(i,5); M_OG = tM(i,6);
    del_CE = tM(i,7);  del_HE = tM(i,8);  del_OE = tM(i,9);  del_NE = tM(i,10);
    del_CV = tM(i,11); del_HV = tM(i,12); del_OV = tM(i,13); del_NV = tM(i,14);
    T = tM(i,15);

    % adapt rates to current temperature		  
    cT = tempcorr(T, T_ref, TA);
    JEAmT = cT * JEAm; kJT = cT * kJ; JEMT = cT * JEM; JETT = cT * JET;
 
    % convert variables
    L = (M_V/ MV) ^ (1/3); % structural length
    ee = (M_E/ M_V)/ mEm; % scaled reserve density, dim-less

    % organic fluxes J_jk
    %   J = flux, j = compound, k = process; J_jk < 0 if j disappears
    J_EC = - JEAmT * L ^2 .* ...
       (g * ee / (g + ee)) * (1 + (Lh + L) / (g * Lm)); % neg
    J_EJ = - kJT * M_H; % maturity maintenance; neg
    J_ER = (1 - kap) * J_EC + J_EJ; % maturation/reproduction; neg
    J_EM = - JEMT * L ^ 3; % volume-linked somatic maintenance; neg
    J_ET = - JETT * L ^ 2; % surface-linked somatic maintenance; neg
    J_ED = J_EM + J_ET + J_EJ + (1 - (M_H > MHp) * kapR) * J_ER; % neg
    J_EG = min(-1e-4, kap * J_EC - J_EM - J_ET); % growth sink of reserve; neg
    J_VD = yVE_D * J_ED; % neg
    J_VG = - yVE * J_EG; % growth; pos

    % coefficients n_Cs_0k; n_O: food X, structure V, reserve E, faeces P
    %   n = chem index, C = carbon, s = substrate, 0 = isotope, k = process
    % modified by odds ratios that are unequal to one
    %  (4,4)-matrix of odds ratios has elements in rows and 
    %  cols of odds: X in assim A_a, E,V in dissi D_a, E in growth G_a

    % anabolic dissip substr (E,V,O)
    n_CE_0D = n_O(1,3) * del_CE; 
    kapDa = kapD; kapDc = 1 - kapDa;
    B = n_CE_0D - kapDc - (n_CE_0D + kapDa) * odds(1,2); 
    C = 4 * (1 - odds(1,2)) * odds(1,2) * n_CE_0D * kapDa;
    n_CE_0Da = 2 * n_CE_0D * odds(1,2)/ (sqrt(B * B + C) - B);
    n_CE_0Dc = (n_CE_0D - n_CE_0Da * kapDa)/ kapDc;
    n_CE_0D = (kapDa * n_CE_0Da + kapDc * n_CE_0Dc);

    % anabolic growth substr (E,O)
    n_CE_0G = n_CE_0D;
    kapGa = yVE; kapGc = 1 - kapGa;
    B = n_CE_0G - kapGc - (n_CE_0G + kapGa) * odds(1,4); 
    C = 4 * (1 - odds(1,4)) * odds(1,4) * n_CE_0G * kapGa;
    n_CE_0Ga = 2 * n_CE_0G * odds(1,4)/ (sqrt(B * B + C) - B);
    n_CE_0Gc = (n_CE_0G - n_CE_0Ga * kapGa)/ kapGc;
    n_CE_0G = (kapGa * n_CE_0Ga + kapGc * n_CE_0Gc);

    LO = (M_OD + M_OG).^(1/3); % otolith length
    dM_O = yOE_D * J_ED + yOE_G * J_EG; % - change in M_O (in C-moles/time)
    % the actual change should be * (1 - M_O/ delS/ M_V)
    % this factor applies to J_ED as well as J_EG 
    O = yOE_G * J_EG / dM_O; % otolith color (between 0 and 1)

    % link isotope C of otolith to that in reserve in D & G
    n_CO_0D = n_CE_0D; n_CO_0Da = n_CE_0Da;  n_CO_0Dc = n_CE_0Dc;
    n_CO_0G = n_CE_0G; n_CO_0Ga = n_CE_0Ga;  n_CO_0Gc = n_CE_0Gc;
    % 9 ways to select from total, anabolic and catabolic fluxes in D & G
    del_CO1 = (n_CO_0D * yOE_D * J_ED + n_CO_0G * yOE_G * J_EG)/ dM_O;
    del_CO2 = (n_CO_0Da* yOE_D * J_ED + n_CO_0G * yOE_G * J_EG)/ dM_O;
    del_CO3 = (n_CO_0Dc* yOE_D * J_ED + n_CO_0G * yOE_G * J_EG)/ dM_O;
    del_CO4 = (n_CO_0D * yOE_D * J_ED + n_CO_0Ga* yOE_G * J_EG)/ dM_O;
    del_CO5 = (n_CO_0Da* yOE_D * J_ED + n_CO_0Ga* yOE_G * J_EG)/ dM_O;
    del_CO6 = (n_CO_0Dc* yOE_D * J_ED + n_CO_0Ga* yOE_G * J_EG)/ dM_O;
    del_CO7 = (n_CO_0D * yOE_D * J_ED + n_CO_0Gc* yOE_G * J_EG)/ dM_O;
    del_CO8 = (n_CO_0Da* yOE_D * J_ED + n_CO_0Gc* yOE_G * J_EG)/ dM_O;
    del_CO9 = (n_CO_0Dc* yOE_D * J_ED + n_CO_0Gc* yOE_G * J_EG)/ dM_O; 

    % pack output
    tOd(i,:) = [t LO O ...
	        del_CO1 del_CO2 del_CO3 ...
	        del_CO4 del_CO5 del_CO6 ...
	        del_CO7 del_CO8 del_CO9];
  end
