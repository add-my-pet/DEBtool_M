%% mcn
% gets reserve densities, spec growth, excretion

%%
function tmrj = mcn(t,p,tLCN,mcn0)
  %  created: 2007/01/19 by Bas Kooijman
  
  %% Syntax
  % tmrj = <../mcn.m *mcn*> (t,p,tLCN,mcn0)
  
  %% Description
  % Gets reserve densities, spec growth, excretion
  %
  % Input:
  %
  % * t: nt-vector with time points
  % * p: 10-vector with parameters
  %
  %      -1 z_C, -, weight coeff of DIC relative to light
  %      -2 j_EC_Am, #/#.t, max spec C-assimilation
  %      -3 j_EN_Am, #/#.t, max spec N-assimilation
  %      -4 y_EC_V, #/#, yield of C-reserve on structure
  %      -5 y_EN_V, #/#, yield of N-reserve on structure
  %      -6 j_EC_M, #/#.t, spec maint flux paid from C-reserve
  %      -7 j_EN_M, #/#.t, spec maint flux paid from N-reserve
  %      -8 k_E, 1/t, reserve turnover rate
  %      -9 kap_EC, -, fraction of rejected C-reserve to C-reserve
  %      -10 kap_EN, -, fraction of rejected N-reserve to N-reserve
  %
  % * tLCN: (n,4)-matrix with time, light, DIC, DIN
  % * mcn0: (2-vector with initial reserve densities for C, N
  %
  % Output:
  %
  % * tmrj: (nt,6)-matrix with time, reserve densities, spec growth, excretion

  global tL tC tN y_EC_V y_EN_V ...
      j_EC_M j_EN_M j_EC_Am j_EN_Am z_C ...
      k_E kap_EC kap_EN;

  % unpack environmental conditions
  tL = tLCN(:,[1 2]); % -, Light intensity as multiple of half sat flux
  tC = tLCN(:,[1 3]); % -, DIC as multiple of half sat concentration
  tN = tLCN(:,[1 4]); % -, DIN as mulple of half sat concentration

  % unpack parameters
  z_C    = p(1); % -, weight coeff of DIC relative to light
  j_EC_Am= p(2); % #/#.t, max spec C-assimilation
  j_EN_Am= p(3); % #/#.t, max spec N-assimilation
  y_EC_V = p(4); % #/#, yield of C-reserve on structure
  y_EN_V = p(5); % #/#, yield of N-reserve on structure
  j_EC_M = p(6); % #/#.t, spec maint flux paid from C-reserve
  j_EN_M = p(7); % #/#.t, spec maint flux paid from N-reserve
  k_E    = p(8); % 1/t, reserve turnover rate
  kap_EC = p(9); % -, fraction of rejected C-reserve to C-reserve
  kap_EN = p(10);% -, fraction of rejected N-reserve to N-reserve

  [t, mcn] = ode15s('dmcn', t, mcn0);

  nt = size(t,1); tmrj = [t, mcn, zeros(nt,3)];
  for i = 1:nt
    r = find_r(mcn(i,:), [k_E,k_E], [j_EC_M,j_EN_M], [y_EC_V,y_EN_V]);
    % 1/d, spec-growth rate; find_r is in DEBtool/lib/misc
    j_EC_R = (k_E - r) * mcn(i,1) - j_EC_M - y_EC_V * r;
	     % mol/mol.d, spec rejection flux of EC 
    j_EN_R = (k_E - r) * mcn(i,2) - j_EN_M - y_EN_V * r;
				% mol/mol.d, spec rejection flux of EN
    tmrj(i,[4 5 6]) = [r, (1 - kap_EC) * j_EC_R, (1 - kap_EN) * j_EN_R];
  end
