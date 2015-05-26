function tmrj = mcn_lm(t,p,tLCN,mcn0)
  %  created: 2007/01/19 by Bas Kooijman
  %
  %% Description
  %  like mcn, but extended with the leak and the Morel model
  %
  %% Input
  %  t: nt-vector with time points
  %  p: 12-vector with parameters
  %  tLCN: (n,4)-matrix with time, light, DIC, DIN
  %  mcn0: (2-vector with initial reserve densities for C, N
  %
  %% Output
  %  tmrj: (nt,16)-matrix with time, reserve densities, spec growth, excretion

  global tL tC tN y_EC_V y_EN_V ...
      j_EC_M j_EN_M j_EC_Am j_EC_AM j_EN_Am j_EN_AM z_C ...
      k_E kap_EC kap_EN;

  %% unpack environmental conditions
  tL = tLCN(:,[1 2]); % -, Light intensity as multiple of half sat flux
  tC = tLCN(:,[1 3]); % -, DIC as multiple of half sat concentration
  tN = tLCN(:,[1 4]); % -, DIN as mulple of half sat concentration

  %% unpack parameters
  z_C    = p(1); % -, weight coeff of DIC relative to light
  j_EC_Am= p(2); % #/#.t, max spec C-assimilation
  j_EC_AM= p(3); % #/#.t, max spec C-assimilation
  j_EN_Am= p(4); % #/#.t, max spec N-assimilation
  j_EN_AM= p(5); % #/#.t, max spec N-assimilation
  y_EC_V = p(6); % #/#, yield of C-reserve on structure
  y_EN_V = p(7); % #/#, yield of N-reserve on structure
  j_EC_M = p(8); % #/#.t, spec maint flux paid from C-reserve
  j_EN_M = p(9); % #/#.t, spec maint flux paid from N-reserve
  k_E    = p(10);% 1/t, reserve turnover rate
  kap_EC = p(11);% -, fraction of rejected C-reserve to C-reserve
  kap_EN = p(12);% -, fraction of rejected N-reserve to N-reserve

  [t, mcn] = ode45('dmcn', t, mcn0);
  [t, mcn_leak]  = ode45('dmcn_leak', t, mcn0);
  [t, mcn_morel] = ode45('dmcn_morel', t, mcn0);

  nt = size(t,1);
  tmrj = [t, mcn, zeros(nt,3),mcn_leak, zeros(nt,3), mcn_morel, zeros(nt,3)];
  for i = 1:nt
    % standard formulation
    r = find_r(mcn(i,:), [k_E,k_E], [j_EC_M,j_EN_M], [y_EC_V,y_EN_V]);
    % 1/d, spec-growth rate; find_r is in DEBtool/lib/misc
    j_EC_R = (k_E - r) * mcn(i,1) - j_EC_M - y_EC_V * r;
	     % mol/mol.d, spec rejection flux of EC 
    j_EN_R = (k_E - r) * mcn(i,2) - j_EN_M - y_EN_V * r;
				% mol/mol.d, spec rejection flux of EN
    tmrj(i,[4 5 6]) = [r, (1 - kap_EC) * j_EC_R, (1 - kap_EN) * j_EN_R];
    % leak model
    r = find_r(mcn_leak(i,:), [k_E,k_E], [j_EC_M,j_EN_M], [y_EC_V,y_EN_V]);
    % 1/d, spec-growth rate; find_r is in DEBtool/lib/misc
    j_EC_R = (k_E - r) * mcn_leak(i,1) - j_EC_M - y_EC_V * r;
	     % mol/mol.d, spec rejection flux of EC 
    j_EN_R = (k_E - r) * mcn_leak(i,2) - j_EN_M - y_EN_V * r;
				% mol/mol.d, spec rejection flux of EN
    tmrj(i,[9 10 11]) = [r, (1 - kap_EC) * j_EC_R, (1 - kap_EN) * j_EN_R];
    % morel model
    r = find_r(mcn_morel(i,:), [k_E,k_E], [j_EC_M,j_EN_M], [y_EC_V,y_EN_V]);
    %% 1/d, spec-growth rate; find_r is in DEBtool/lib/misc
    j_EC_R = (k_E - r) * mcn_morel(i,1) - j_EC_M - y_EC_V * r;
	     % mol/mol.d, spec rejection flux of EC 
    j_EN_R = (k_E - r) * mcn_morel(i,2) - j_EN_M - y_EN_V * r;
				% mol/mol.d, spec rejection flux of EN
    tmrj(i,[14 15 16]) = [r, (1 - kap_EC) * j_EC_R, (1 - kap_EN) * j_EN_R];
  
  end
