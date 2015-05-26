function [X, lim]= state1_mixo (Ctot, Ntot)
  %  created: 2001/09/07 by Bas Kooijman, modofied 2009/01/05
  %
  %  routine called from shstate1, domain mixo
  %  Equilibria for closed 1-reserve mixotroph system
  %
  %% Output
  %  X: (1) DIC (2) DIN (3) Struc-Ditritus (4) Res-Ditritus
  %     (5) Structure (6) Reserve
  %  lim: = 1 light  = 2 carbon = 3 nitrogen limitation

global j_EV_AHVm j_EE_AHEm j_EA_Am j_L_FK ...
  K_C K_N K_NE K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
  k_EA k_EH k_EV k_EE z_C z_N z_CH y_DVE y_DEE y_EV ...
  k_E k_M h n_NV n_NE;

  % help variables 
  m_E = y_EV * k_M/ (k_E - h);
  j_V_G = k_M * h/ (k_M + k_E - h);
  a_EE = 1/ (1 + y_DEE/ (m_E * y_DVE));
  k_EHM = a_EE * k_EE + (1 - a_EE) * k_EV;
  j_E_A = y_EV * (k_M + j_V_G) + h * m_E^2/ (y_EV + m_E);
  j_E_AHV = h * m_E/ (y_DVE * (y_EV + m_E));
  j_E_AHE = h * m_E^2/ (y_DEE * (y_EV + m_E));
  j_E_AA = j_E_A - j_E_AHE - j_E_AHV;
  a_EA = 1/(1 + j_E_AHE/ (a_EE * j_E_AA));
  k_EM = a_EA * k_EA + (1 - a_EA) * k_EH;
  j_EA_AA = a_EA/ (rho_EA/ j_E_A - rho_EA/ k_EM);
  j_EH_AH = j_EA_AA * (1/ a_EA - 1) * rho_EA/ rho_EH;
  j_EE_AHE = a_EE/ (rho_EE/ j_EH_AH - rho_EE/ k_EHM);
  j_EV_AHV = j_EE_AHE * (1/a_EE - 1) * rho_EE/ rho_EV;
  
  j_E_AH = (1 - a_EA) * j_E_A;
  a = (1 + 1/z_N + 1/z_CH - 1/(z_N + z_CH)) * j_EA_Am/ j_EA_AA;
  f_CH = (sqrt(1 + 4/(a * z_N - z_N - 1)) - 1) * z_N/ (2 * z_CH);
  f_N = (sqrt(1 + 4/ (a * z_CH - z_CH - 1)) - 1) * z_CH/ (2 * z_N);
  f_C = 1/ ((z_C + 1)/ f_CH - z_C);
    
  % initial guesses for state variables   

  % light limitation
      XL(3) = K_DV/ (j_EV_AHVm/ j_EV_AHV - 1);         % DV, V-Detritus
      XL(4) = K_DE/ (j_EE_AHEm/ j_EE_AHE - 1);         % DE, E-Detritus
      XL(5) = 0;                                       % V, Structure 
      XL(6) = 0;                                       % E, Reserve 
      XL(1) = Ctot - XL(3) - XL(4);                    % DIC
      XL(2) = Ntot - n_NV * (XL(3) + XL(4));           % DIN

  % carbon limitation
      XC(3) = K_DV/ (j_EV_AHVm/ j_EV_AHV - 1);          % DV, V-Detritus
      XC(4) = K_DE/ (j_EE_AHEm/ j_EE_AHE - 1);          % DE, E-Detritus
      XC(1) = K_C/ (1/ f_C - 1);                        % DIC 
      XC(5) = (Ctot - XC(1) - XC(3) - XC(4))/ (1 + m_E);% V, Structure 
      XC(6) = m_E * XC(5);                              % E, Reserve
      XC(2) = Ntot - n_NV * (XC(3) + XC(5)) - n_NE * (XC(4) + XC(6)); % DIN

  % nitrogen limitation

      XN(3) = K_DV/ (j_EV_AHVm/ j_EV_AHV - 1);          % DV, V-Detritus
      XN(4) = K_DE/ (j_EE_AHEm/ j_EE_AHE - 1);          % DE, E-Detritus
      XN(2) = K_N/ (1/ f_N - 1);                        % DIN
      XN(5) = (Ntot - XN(2) - n_NV * XN(3) - n_NE * XN(4))/ ...
	  (n_NV + n_NE * m_E);                          % V, Structure 
      XN(6) = m_E * XN(5);                              % E, Reserve
      XN(1) = Ctot - sum(XN([3 4 5 6])) ;               % DIC 
  
  if length(XN) == sum(XN > 0)
    X = XN; lim = 3; % N limitation
  elseif length(XC) == sum(XC > 0)
    X = XC; lim = 2; % C limitation
  else
    X = XL; lim = 1; % L limitation
  end
