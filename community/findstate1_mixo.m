function X = findstate1_mixo (X_t)
  %% routine called from gstate1_mixo
  %% Equations for closed 1-reserve mixotroph system
  %%  given Ctot and Ntot
  %% X_t: 4-vector with initial estimates for organic compounds

global j_L_F Ctot Ntot j_EV_AHVm j_EE_AHEm j_EA_Am j_L_FK ...
  K_C K_N K_NE K_NV K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
  k_EA k_EH k_EV k_EE z_C z_N z_CH y_DVE y_DEE y_EV ...
  k_E k_M h n_NV n_NE;


  %% unpack state vector for easy reference
  DV=X_t(1); DE=X_t(2); V=X_t(3); E=X_t(4);
  m_E = E/max(V,1e-8); 

  C = Ctot - DV - DE - V - E;
  N = Ntot - n_NV*DV - n_NE*DE - n_NV*V - n_NE*E;

  %% help variables 

  f_C = C/ (K_C + C);
  a = z_C * f_C; b = -j_L_F/ j_L_FK;
  f_CH = (1 + 1/z_C)/ (1 + 1/a + 1/b - 1/(a + b));

  f_N = N / (K_N + N);
  a = z_N * f_N; b = z_CH * f_CH;
  j_EA_AA = j_EA_Am * (1 + 1/z_N + 1/z_CH - 1/(z_N + z_CH))/ ...
  (1 + 1/a + 1/b - 1/(a + b));

  a = N/ K_NE; b = DE/ K_DE;
  j_EE_AHE = j_EE_AHEm/ (1 + 1/a + 1/b - 1/(a + b));

  a = N/ K_NV; b = DV/ K_DV;
  j_EV_AHV = j_EV_AHVm/ (1 + 1/a + 1/b - 1/(a + b));

  a_EE = 1/ (1 + rho_EV * j_EV_AHV/ (rho_EE * j_EE_AHE));
  k_EHM = a_EE * k_EE + (1 - a_EE) * k_EV;
  j_EH_AH = 1/ (1/ k_EHM + a_EE/ (rho_EE * j_EE_AHE));

  a_EA = 1/(1 + rho_EH * j_EH_AH/ (rho_EA * j_EA_AA));
  k_EM = a_EA * k_EA + (1 - a_EA) * k_EH;
  j_E_A = 1/ (1/ k_EM + a_EA/ (rho_EA * j_EA_AA));

  %% organic fluxes
  j_E_AA = a_EA * j_E_A;
  j_E_AHE = a_EE * (1 - a_EA) * j_E_A;
  j_E_AHV = (1 - a_EE) * (1 - a_EA) * j_E_A;
  j_DE_AHE = - y_DEE * j_E_AHE;
  j_DV_AHV = - y_DVE * j_E_AHV;
  j_V_G = (m_E * k_E - y_EV * k_M)/ (m_E + y_EV);
  j_E_G = - y_EV * j_V_G;
  j_E_M = - y_EV * k_M;
  j_V_H = -h * m_E/ (y_EV + m_E);
  j_DV_H = h * m_E/ (y_EV + m_E);
  j_E_H = -h * m_E^2/ (y_EV + m_E);
  j_DE_H = h * m_E^2/ (y_EV + m_E);

  %% mineral fluxes
  j_C_AA = - j_E_AA;
  j_C_AHV = - j_DV_AHV - j_E_AHV;
  j_C_AHE = - j_DE_AHE - j_E_AHE;
  j_C_G = - j_V_G - j_E_G;
  j_C_M = - j_E_M;
  j_N_AA = - n_NE * j_E_AA;
  j_N_AHV = - n_NV * j_DV_AHV - n_NE * j_E_AHV;
  j_N_AHE = - n_NE * j_DE_AHE - n_NE * j_E_AHE;
  j_N_G = -n_NV * j_V_G - n_NE * j_E_G;
  j_N_M = - n_NE * j_E_M;
  
  X = zeros(4,1); % create 4-vector for output

  %%  change in organic compound that must be set equal to zero 
  X(1) = V*(j_DV_AHV + j_DV_H);          % DV, V-detritus
  X(2) = V*(j_DE_AHE + j_DE_H);          % DE, E-detritus
  X(3) = V*(j_V_G + j_V_H);              % V, Structure 
  X(4) = V*(j_E_AA + j_E_AHV + j_E_AHE + j_E_G + j_E_M + j_E_H); % E, Reserve





