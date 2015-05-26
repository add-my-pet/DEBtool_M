function dXdt = dxt (t, X_t)
  %% Created at 2000/10/18 by Bas Kooijman
  %% Differential equations for the chemostat 

  global X_R X_RN h n_N_VA n_N_E n_N_X n_N_VH ...
      kap_EC kap_EN K_NA K_NH b_X b_VA b_EN b_EC ...
      k_EH k_EA j_EC_M j_EN_M j_E_M  ...
      j_EC_Am j_EN_Am j_E_ANm j_E_AXm j_E_AVm j_E_AEm ...
      y_E_X y_EC_V y_E_V y_E_VA y_E_EC y_E_EN;

  X=X_t(1); X_N=X_t(2); X_CH=X_t(3); X_VA=X_t(4); m_EN=X_t(5); m_EC=X_t(6);
  X_VH=X_t(7); m_E=X_t(8);

  j_E_AV = y_E_VA*b_VA*X_VA;   % autotrophic-structure-arrival at heterotroph 
  j_E_AX = y_E_X*b_X*X; % substrate-arrival at heterotroph 
  j_E_AN = j_E_ANm/(1 + K_NH/X_N);   % nitrogen uptake by heterotroph
  j_EN_A  = j_EN_Am/(1 + K_NA/X_N);           % nitrogen uptake by autotroph
  r_A = (m_EN*k_EA - j_EN_M)/(m_EN + n_N_VA); % spec growth rate of  autotroph
  r_H = (m_E*k_EH - j_E_M)/(m_E + y_E_V);     % spec growth rate of heterotroph
   %% arrival of nitrogen in terms of reserves at heterotroph
  j_EH_AN = y_E_EN*(m_EN*j_E_AV/y_E_VA + b_EN*X_N);
  %% arrival of carbohydrate in terms of reserves at heterotroph
  j_EH_AC = y_E_EC*(m_EC*j_E_AV/y_E_VA + b_EC*X_CH);
  %% arrival reserves synthesized from N and CH at heterotroph 
  j_E_AE = 1/(1/j_EH_AC + 1/j_EH_AN - 1/(j_EH_AC + j_EH_AN));
  %% total arriving reserves at heterotroph
  sJ_E_A = j_E_AX + j_E_AV + j_E_AE;
  %% max reserve synthesis by heterotroph 
  wsJ_E_A = j_E_AXm*j_E_AX + j_E_AVm*j_E_AV + j_E_AEm*j_E_AE; 
  %% assimilation by heterotroph 
  j_E_A = 1/(sJ_E_A/ wsJ_E_A + 1/sJ_E_A); 
  %% assimilated carbohydrate by heterotroph 
  j_CH_A = (j_E_AE/sJ_E_A)*j_E_A/y_E_EC;
  %% assimilated substrate by heterotroph 
  j_X_A = (j_E_AX/sJ_E_A)*j_E_A/y_E_X;
  %% assimilated autotrophic-structure by heterotroph 
  j_VA_A = (j_E_AV/sJ_E_A)*j_E_A/y_E_VA;
  %% nitrogen excretion by autotroph
  j_N_EA = (1 - kap_EN)*(k_EA - r_A)*m_EN + kap_EN*(j_EN_M + ...
    n_N_VA*r_A) - n_N_VA*r_A;
  %% nitrogen excretion by heterotroph
  j_N_EH = j_VA_A*(n_N_VA + m_EN) + ...
    (b_EN*X_N/(m_EN*j_E_AV/y_E_VA + b_EN*X_N))* ...
    (j_E_AE/sJ_E_A)*j_E_A*n_N_E + j_X_A*n_N_X - j_E_A*n_N_E + ...
    (k_EH - r_H)*m_E*n_N_E - r_H*n_N_VH; 
  j_CH_E = max(0,(1 - kap_EC)*((k_EA - r_A)*m_EC - j_EC_M - ...
    y_EC_V*r_A));% carbohydrate excretion by autotroph


  dXdt = zeros(8,1);
  
  %% conc substrate 
  dXdt(1)= (X_R - X)*h - X_VH*j_X_A; 

  %% conc nitrogen 
  dXdt(2) = (X_RN - X_N)*h + X_VA*(j_N_EA - j_EN_A) + X_VH*j_N_EH; 

  %% conc carbohydrate 
  dXdt(3) = -X_CH*h + X_VA*j_CH_E + X_VH*(m_EC*j_VA_A - j_CH_A); 

  %% conc autotrophic structure
  dXdt(4) = X_VA*(r_A - h) - X_VH*j_VA_A; 

  %% N-reserve-density of autotroph
  dXdt(5) = j_EN_A - (1 - kap_EN)*(k_EA - r_A)*m_EN - ...
    kap_EN*(j_EN_M + n_N_VA*r_A) - r_A*m_EN; 

  %% CH-reserve-density autotroph 
  dXdt(6) = j_EC_Am - (1 - kap_EC)*(k_EH - r_A)*m_EC - ...
    kap_EC*(j_EC_M + y_EC_V*r_A) - r_A*m_EC;

  %% conc heterotrophic structure
  dXdt(7) = X_VH*(r_H - h);

  %% reserve-density of heterotroph
  dXdt(8) = j_E_A - k_EH*m_E;

