function X = findstaten3 (X_t)
  %% routine called from gstate3, domain mixo
  %% Differential equations for closed 3-reserve mixotroph system
  %% assuming N limitation, obtaining V and C from mass balance

global j_L_F Ctot Ntot j_EV_AHVm j_EE_AHEm j_EC_Am j_EN_Am j_L_FK ...
K_C K_N K_NE K_NV K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
k_EV k_EE z_C z_N y_DVE y_DEE y_EV y_ECV y_ENV y_NEN ...
k_E k_M kap_EC kap_EN h n_NV n_NE n_NEN;

  %% unpack state vector for easy reference
  N=X_t(1); DV=X_t(2); DE=X_t(3); E=X_t(4); EC=X_t(5); EN=X_t(6);
  V = (Ntot - N - n_NV*DV - n_NE*DE - n_NE*E - n_NEN*EN)/n_NV;
  C = Ctot - DV - DE - V - E - EC;
  m_E = E/V; m_EC = EC/V; m_EN = EN/V;

  %% help variables 
  f_C = C/ (K_C + C);
  a = z_C * f_C; b = -j_L_F/ j_L_FK;
  f_CH = (1 + 1/z_C)/ (1 + 1/a + 1/b - 1/(a + b));
  j_EC_AA = f_CH * j_EC_Am;

  f_N = N/ (K_N + N);
  j_EN_AA = f_N * j_EN_Am;

  a = N/ K_NV; b = DV/ K_DV;
  j_EV_AHV = j_EV_AHVm/ (1 + 1/a + 1/b - 1/(a + b));

  a = N/ K_NE; b = DE/ K_DE;
  j_EE_AHE = j_EE_AHEm/ (1 + 1/a + 1/b - 1/(a + b));

  a_EE = 1/(1 + rho_EV * j_EV_AHV/ (rho_EE * j_EE_AHE));
  k_EHM = a_EE * k_EE + (1 - a_EE) * k_EV;
  j_E_AH = 1/ (1/ k_EHM + a_EE/ (rho_EE * j_EE_AHE));

  %% organic fluxes
  a = m_EC/ y_ECV; b = m_EN/ y_ENV;
  g = m_E/ y_EV + 1/ (1/a + 1/b - 1/(a + b));
  a_H = m_E/ (y_EV * g); a_A = 1 - a_H;
  j_V_G = (k_E * g - k_M)/ (g + 1);
  j_EC_E = (1 - kap_EC) * (m_EC * (k_E - j_V_G) - a_A * y_ECV * (j_V_G + k_M));
  j_EN_E = (1 - kap_EN)* (m_EN * (k_E - j_V_G) - a_A* y_ENV * (j_V_G + k_M));
  
  j_E_AHE = a_EE * j_E_AH;
  j_E_AHV = (1 - a_EE) * j_E_AH;
  j_DE_AHE = - y_DEE * j_E_AHE;
  j_DV_AHV = - y_DVE * j_E_AHV;
  j_E_G = - j_V_G * a_H * y_EV;
  j_EC_G = - j_V_G * a_A * y_ECV; 
  j_EN_G = - j_V_G * a_A * y_ENV;
  j_E_M = - k_M * a_H * y_EV;
  j_EC_M = - k_M * a_A * y_ECV ;
  j_EN_M = - k_M * a_A * y_ENV;
  j_V_H = - h * (m_E/ (y_EV + m_E) + m_EC/ (y_ECV + m_EC) + ...
		 m_EN/(y_ENV + m_EN));
  j_V_H = - h; % overwrite!
  j_DV_H = - j_V_H;
  j_E_H = m_E * j_V_H;
  j_DE_H = - j_E_H;
  j_EC_H = m_EC * j_V_H;
  j_EN_H = m_EN * j_V_H;

  %% mineral fluxes
  j_C_AA = - j_EC_AA;
  j_C_AHV = - j_DV_AHV - j_E_AHV;
  j_C_AHE = - j_DE_AHE - j_E_AHE;
  j_C_E = j_EC_E;
  j_C_G = - j_V_G - j_E_G - j_EC_G;
  j_C_M = - j_E_M - j_EC_M;
  j_C_H = - j_EC_H;
  j_N_AA = - y_NEN * j_EN_AA;
  j_N_AHV = - n_NV * j_DV_AHV - n_NE * j_E_AHV;
  j_N_AHE = - n_NE * j_DE_AHE - n_NE * j_E_AHE;
  j_N_E = y_NEN * j_EN_E;
  j_N_G = - n_NV * j_V_G - n_NE * j_E_G - j_EN_G;
  j_N_M = - n_NE * j_E_M - j_EN_M;
  j_N_H = - y_NEN * j_EN_H;

  X = zeros(6,1); % create 6-vector for output

  %% change in organic compounds that are set equal to zero
  X(1) = j_DV_AHV + j_DV_H;          % DV, V-detritus
  X(2) = j_DE_AHE + j_DE_H;          % DE, E-detritus
  X(3) = j_V_G + j_V_H;              % V, Structure 
  X(4) = j_E_AHV + j_E_AHE + j_E_G + j_E_M + j_E_H;
	                             % E, Reserve
  X(5) = j_EC_AA - j_EC_E + j_EC_G + j_EC_M + j_EC_H;
				     % EC, C-reserve
  X(6) = j_EN_AA - j_EN_E + j_EN_G + j_EN_M + j_EN_H;
				     % EN, N-reserve


