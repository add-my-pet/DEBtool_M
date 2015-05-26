function dX = dchem (X)
  %  created: 2000/09/21 by Bas Kooijman
  %  equilibrium states of a chemostat,
  %    see p170-171 of DEB-book
  %    excreted reserves are NOT available for assimilation
  %      see dchem1 for alternative
  
  global X_N X_P m_EN m_EP y_EN_V y_EP_V y_N_EN y_P_EP ...
      jT_EN_M jT_EP_M jT_EN_Am jT_EP_Am K_P K_N ...
      kT_E kap_EN kap_EP X_Nr X_Pr h;
  
  %  unpack X
  X_N  = X(1); X_DN = X(2);
  X_P  = X(3); X_DP = X(4);
  m_EN = X(5); m_EP = X(6);
  X_V  = X(7); 

  j_EN_R = (kT_E - h) * m_EN - jT_EN_M - y_EN_V * h;
	     % mol/mol.d, spec rejection flux of EN 
  j_EP_R = (kT_E - h) * m_EP - jT_EP_M - y_EP_V * h;
	     % mol/mol.d, spec rejection flux of EP 
  j_EN_A = jT_EN_Am * (X_N ./ (K_N + X_N)); %
	     % mol/mol.d, spec assimilation flux of EN
  j_EP_A = jT_EP_Am*(X_P./(K_P + X_P));
	     % mol/mol.d, spec assimilation flux of EP 
  
  dX_N = X_Nr*h - X_N*h - y_N_EN*j_EN_A.*X_V;
	     % M/d, change in ammonia concentration
  dX_DN = ((1 - kap_EN) * y_N_EN * j_EN_R + y_N_EN * jT_EN_M) .* X_V - h*X_DN;
	     % M/d, change in excreted N-reserve concentration
  dX_P = X_Pr * h - X_P * h - y_P_EP * j_EP_A .* X_V;
	     % M/d, change in phosphate concentration
  dX_DP = ((1 - kap_EP) * y_P_EP * j_EP_R + y_P_EP * jT_EP_M) .* X_V - h*X_DP;
	     % M/d, change in excreted P-reserve concentration
  dm_EN = j_EN_A - (1 - kap_EN) * (kT_E - h) * m_EN - ...
      kap_EN * (jT_EN_M + y_EN_V*h) - h*m_EN;
	     % mol/mol.d, change in N-reserve density
  dm_EP = j_EP_A - (1 - kap_EP) * (kT_E - h) * m_EP - ...
      kap_EP * (jT_EP_M + y_EP_V * h) - h * m_EP;
	     % mol/mol.d, change in P-reserve density
  dX_V =  1 ./ (1./((m_EN*(kT_E - h) - jT_EN_M)/y_EN_V) + ...
	  1 ./ ((m_EP*(kT_E - h) - jT_EP_M)/y_EP_V) - ...
          1 ./ ((m_EN*(kT_E - h) - jT_EN_M)/y_EN_V + ...
            (m_EP*(kT_E - h) - jT_EP_M)/y_EP_V)) - h;
	     % M/d, change in structural mass density
 
  dX = [dX_N, dX_DN, dX_P, dX_DP, dm_EN, dm_EP, dX_V]';
