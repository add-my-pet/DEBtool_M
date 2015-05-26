function dX = dstate1_mixo (t, X_t)
  %% routine called from shtime1_mixo
  %% Differential equations for closed 1-reserve mixotroph system

global j_L_F Ctot Ntot j_EV_AHVm j_EE_AHEm j_EA_Am j_L_FK ...
  K_C K_N K_NE K_NV K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
  k_EA k_EH k_EV k_EE z_C z_N z_CH y_DVE y_DEE y_EV ...
  k_E k_M h n_NV n_NE;


  %% unpack state vector for easy reference
  C=X_t(1); N=X_t(2); DV=X_t(3); DE=X_t(4); V=X_t(5); E=X_t(6);
  m_E = E/V; 

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
  
  dX = zeros(6,1); % create 6-vector for output

  %% change in state variables 
  dX(1) = V*(j_C_AA + j_C_AHV + j_C_AHE + j_C_G + j_C_M); % DIC 
  dX(2) = V*(j_N_AA + j_N_AHV + j_N_AHE + j_N_G + j_N_M); % DIN
  dX(3) = V*(j_DV_AHV + j_DV_H);          % DV, V-detritus
  dX(4) = V*(j_DE_AHE + j_DE_H);          % DE, E-detritus
  dX(5) = V*(j_V_G + j_V_H);              % V, Structure 
  dX(6) = V*(j_E_AA + j_E_AHV + j_E_AHE + j_E_G + j_E_M + j_E_H); % E, Reserve

