function dXt = dcycle (t, Xt)
  %  created: 2002/03/03 by Bas Kooijman; modified 2008/03/03
  %    cycling nutrients called by shcycle
  %  change in state variables of a generalized chemostat,
  
  global y_EN_V y_EP_V y_N_EN y_P_EP ...
      j_EN_M j_EP_M j_EN_Am j_EP_Am K_P K_N ...
      kT_E kap_EN kap_EP h h_X h_V r;
  global X0_N X1_N t0_N t1_N X0_P X1_P t0_P t1_P power; % time-dep nutrients
  
  %  unpack Xt
  m_EN = Xt(1); m_EP = Xt(2); % reserves
  X_V  = Xt(3);               % structure

  %  nutrient 
  X_N = X0_N + X1_N * (1 + sin((t-t0_N)/t1_N))^power;
  X_P = X0_P + X1_P * (1 + sin((t-t0_P)/t1_P))^power;

  %  r = fsolve('findr',findr(0)); % 1/d, spec-growth rate
  r = sgr2([m_EN; m_EP], [kT_E; kT_E], [j_EN_M; j_EP_M], [y_EN_V; y_EP_V], [], [], r);
  %  1/d, spec-growth rate
  j_EN_R = (kT_E - r)*m_EN - j_EN_M - y_EN_V*r;
	     % mol/mol.d, spec rejection flux of EN 
  j_EP_R = (kT_E - r)*m_EP - j_EP_M - y_EP_V*r;
	     % mol/mol.d, spec rejection flux of EP 
  j_EN_A = j_EN_Am*(X_N/(K_N + X_N)); %
	     % mol/mol.d, spec assimilation flux of EN
  j_EP_A = j_EP_Am*(X_P/(K_P + X_P));
	     % mol/mol.d, spec assimilation flux of EP 
  
  
  dm_EN = j_EN_A - (1 - kap_EN)*(kT_E - r)*m_EN - ...
      kap_EN*(j_EN_M + y_EN_V*r) - r*m_EN;
	     % mol/mol.d, change in N-reserve density
  dm_EP = j_EP_A - (1 - kap_EP)*(kT_E - r)*m_EP - ...
      kap_EP*(j_EP_M + y_EP_V*r) - r*m_EP;
	     % mol/mol.d, change in P-reserve density
  dX_V = (r - h)*X_V;
	     % M/d, change in structural mass density
  
  %  pack dXt
  dXt = [dm_EN; dm_EP; dX_V];
