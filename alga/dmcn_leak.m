function dXt = dmcn_leak (t,Xt)
  %  created: 2007/01/20 by Bas Kooijman
  %
  %% Input
  %  t: scalar with time
  %  Xt: 2-vector with reserve densities: carbohydrates & nitrate
  %
  %% Ouput
  %  dXt: 2-vector with change in reserve densities
  %    given Light(t), DIC(t), DIN(t); see p170-171 of DEB-book
  
  global tL tC tN y_EC_V y_EN_V ...
      j_EC_M j_EN_M j_EC_Am j_EC_AM j_EN_Am j_EN_AM z_C ...
      k_E kap_EC kap_EN;
  
  %  unpack Xt
  m_EC = Xt(1); m_EN = Xt(2); % mol per mol of structure

  %  carbon fixation, p166 of DEB-book (5.10)
  %  spline is in debtool/lib/misc
  X_C = spline(t,tC); % DIC at time t as multiple of half sat coeff
  L = spline(t,tL);   % light at time t as multiple of half sat flux
  f_C = X_C/ (1 + X_C);
  f_C = (1 + 1/ z_C)/ (1 + 1/(z_C * f_C) + 1/ L - 1/(z_C * f_C + L));
  j_EC_A = max(0, f_C * j_EC_AM - (j_EC_AM/ j_EC_Am - 1) * m_EC * k_E);
				% mol/mol.d, spec assimilation flux of EC
  X_N = spline(t,tN); % DIN at time t as multiple of half-sat coeff
  f_N = X_N/ (1 + X_N);
  j_EN_A = max(0, f_N * j_EN_AM - (j_EN_AM/ j_EN_Am - 1) * m_EN * k_E);
	     % mol/mol.d, spec assimilation flux of EN

  %  1/d, spec-growth rate; find_r is in DEBtool/lib/misc
  %  see p 169 of DEB book eq (5.15)
  [r,info] = find_r([m_EC,m_EN], [k_E,k_E], [j_EC_M,j_EN_M], [y_EC_V,y_EN_V]);
  if info ~= 1
    fprintf('no convergence for spec growth rate\n');
  end
  j_EC_R = (k_E - r) * m_EC - j_EC_M - y_EC_V * r;
	     % mol/mol.d, spec rejection flux of EC 
  j_EN_R = (k_E - r) * m_EN - j_EN_M - y_EN_V * r;
	     % mol/mol.d, spec rejection flux of EN 
  
  dm_EC = j_EC_A - (1 - kap_EC) * j_EC_R - j_EC_M - r * (m_EC + y_EC_V);
	     % mol/mol.d, change in C-reserve density
  dm_EN = j_EN_A - (1 - kap_EN) * j_EN_R - j_EN_M - r * (m_EN + y_EN_V);
	     % mol/mol.d, change in N-reserve density
  
  %  pack dXt
  dXt = [dm_EC; dm_EN];
