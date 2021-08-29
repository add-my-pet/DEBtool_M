%% get_wR
% Gets the neonate weight per mol O2

%%
function w_R = get_wR(par)
  % created 2021/08/28 by Bas Kooijman
  
  %% Syntax
  % wR = <../get_wR.m *get_wR*> (par)
  
  %% Description
  % gets the neonate weight per mol O2 for a fully growth adult at abundant food.
  % It is a yield coefficient with the dimensions of a molecular weight
  % Intended use: consider this if reproduction data is unreliable or lacking.
  %
  % Input
  %
  % * par: structure with parameter values, as used in AmP  
  %
  % Output
  %
  % * w_R: scalar with neonate weight per mol O2
  
  %% Remarks
  % The typical value is 10 g/mol.
  % This fuction is supposed to apply for all models with asymptotic growth
  % Although the dioxygen flux is generally taken to be negative, 
  %  it is taken positive here to give w_R the dimensions of a molecular weight.
  %
  % Used parameters in par: 
  %
  % * kap, -, allocation fraction of mobilised reserve to soma
  % * kap_X, -, digestion efficiency
  % * kap_P, -, defacation efficiency; fraction (1 - kap_X - kap_P) is dissipated
  % * kap_R, -, reproduction efficiency
  % * z, - , zoom factor (def: z = \kappa * {p_Am}/ [p_M]/ L_ref with L_ref = 1 cm)
  % * v, cm/d, energy conductance 
  % * k_J, 1/d, maturity maintenance rate coefficient 
  % * p_T, J/d.cm^2, surface area-specific somatic maintenance
  % * p_M, J/d.cm^3, volume-specific somatic maintenance
  % * E_G, J/cm^3, cost for structure 
  % * E_Hb, J, maturity at birth 
  % * E_Hs, J, maturity at start acceleration(optional, default E_Hb) 
  % * E_Hj, J, maturity at end acceleration(optional, default E_Hb) 
  % * E_Hp, J, maturity at puberty 
  % * d_E, g/cm^3, specific density of reserve 
  % * mu_X, J/mol, chemical potential of food 
  % * mu_E, J/mol, chemical potential of reserve 
  % * mu_P, J/mol, chmecial potential of faeces 
  % * n_**, - , chemical coefficients for organics and minerals

  %% Example of use
  %
  % * add in mydata-file: data.w_R = 10; % g/mol, neonate mass per mol O2
  % * add in predict-file: prdData.w_R = get_wR(par);
  % * optionally give it reduced weight in mydata-file: weights.w_R = 0.2 * weights.w_R;
  %
  % load('path/results_my_pet', 'par'); get_wR(par) with 'my_pet' replaced by an appropriate entry name
  
  vars_pull(par); % unpack par
  % compound parameters:
  p_Am = z * p_M/ kap; % J/d.cm^2, max spec assim before accelleration (is a primary parameter and zoom factor z a compound one)
  E_m = p_Am/ v; % J/cm^3, reserve capacity
  L_m = kap * p_Am/ p_M; % cm, max structural length (without acceleration)
  l_T = p_T/ p_M/ L_m ;  % -, scaled heating length
  k_M = p_M/ E_G; % 1/d, maintenance rate coefficient
  k = k_J/ k_M; % -, maintenance ratio
  g = E_G/ kap/ E_m; % -, energy investment ratio
  v_Hb = E_Hb/ g/ E_m/ L_m^3/ (1 - kap); % -, scaled maturity at birth
  v_Hp = E_Hp/ g/ E_m/ L_m^3/ (1 - kap); % -, scaled maturity at puberty
  n_O = [n_CX, n_CV, n_CE, n_CP; n_HX, n_HV, n_HE, n_HP; n_OX, n_OV, n_OE, n_OP; n_NX, n_NV, n_NE, n_NP]; % -, chemical indices for organics
  n_M = [n_CC, n_CH, n_CO, n_CN; n_HC, n_HH, n_HO, n_HN; n_OC, n_OH, n_OO, n_ON; n_NC, n_NH, n_NO, n_NN]; % -, chemical indices for minerals
  w_E = 12 * n_O(1,3) + n_O(2,3) + 16 * n_O(3,3) + 14 * n_O(4,3); % g/mol, mol weight of reserve
  ome = E_m/ mu_E * w_E/ d_E; % -, relative contribution of reserve to wet weight
  
  % acceleration  factor
  if exist('E_Hj','var') && exist('E_Hs','var') 
    v_Hs = E_Hs/ g/ E_m/ L_m^3/ (1 - kap); % -, scaled maturity at start acceleration
    v_Hj = E_Hj/ g/ E_m/ L_m^3/ (1 - kap); % -, scaled maturity at end acceleration
    [l_s, l_j] = get_ls([g, k, l_T, v_Hb, v_Hs, v_Hj, v_Hp]);
    s_M = l_j/ l_s; 
  elseif exist('E_Hj','var')
    v_Hj = E_Hj/ g/ E_m/ L_m^3/ (1 - kap); % -, scaled maturity at end acceleration
    [l_j, ~, l_b] = get_lj([g, k, l_T, v_Hb, v_Hj, v_Hp]);
    s_M = l_j/ l_b; 
  else
    s_M = 1; 
  end 
 
  % neonate mass production rate
  [u_E0, l_b] = get_ue0([g, k, v_Hb]); % -, scaled initial reserve
  L_b = L_m * l_b; % cm, structural length at birth
  Ww_b = L_b^3 * (1 + ome); % g, wet weight at birth
  R_m = kap_R * (1 - kap) * k_M * (s_M * (s_M - l_T)^2 - k * v_Hp)/ u_E0; % 1/d, max reprod rate
  J_Wb = Ww_b * R_m; % g/d, neonate mass production rate
  
  % respiration
  E_0 = u_E0 * g * E_m * L_m^3; % J, initial reserve 
  J_X = s_M * p_Am * L_m^2 * (s_M - l_T)^2/ mu_X/ kap_X; % mol/d, food flux
  J_V = 0; % mol/d, growth of structure
  J_ER = R_m * E_0/ kap_R/ mu_E; % mol/d, reserve flux to offspring
  J_P = s_M * p_Am * L_m^2 * (s_M - l_T)^2/ kap_X * kap_P/ mu_P; % mol/d, faeces flux
  J_M = - (n_M\n_O) * [J_X; J_V; J_ER; J_P]; % mol/d, mineral fluxes (J_E = 0)
  J_O = J_M(3); % mol/d, O2 flux (taken positive)
  
  % neonate weight per mol O2
  w_R = J_Wb/ J_O; % g/mol
