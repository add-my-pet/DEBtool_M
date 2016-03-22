%% diso_221_var
% ode's for iso_221_var

%%
function dvar = diso_221_var(t, var, tXT, p)

  %% Syntax
  % dvar =  <../diso_221_var.m *diso_221_var*> (t, var, tXT, p)
  
  %% Description
  % ode's for iso_221_var
  %
  % Input:
  %
  % * t: scalar time since birth
  % * var: 13-vector with states:
  %   cM_X1, cM_X2, M_E1, M_E2, M_H, max_M_H, M_V, max_M_V, cM_ER1, cM_ER2, q, h, S
  % * tXT: (n,3)-matrix with time, X1, X2, T
  % * p: 34-vector with par values (see below)
  %
  %    M_X1      = p( 1); M_X2      = p( 2); % mol, size of food particle of type i
  %    F_X1m     = p( 3); F_X2m     = p( 4); % dm^2/d.cm^2, {F_Xim} spec searching rates
  %   %y_P1X1    = p( 5); y_P2X2    = p( 6); % mol/mol, yield of feaces i on food i
  %    y_E1X1    = p( 7); y_E2X1    = p( 8); % mol/mol, yield of reserve Ei on food X1
  %    y_E1X2    = p( 9); y_E2X2    = p(10); % mol/mol, yield of reserve Ei on food X2
  %    J_X1Am    = p(11); J_X2Am    = p(12); % mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
  %    v         = p(13); kap       = p(14); % cm/d, energy conductance, 
  %                                          % -, allocation fraction to soma
  %    mu_E1     = p(15); mu_E2     = p(16); % J/mol, chemical potential of reserve i
  %    mu_V      = p(17); j_E1M     = p(18); % J/mol, chemical potenial of structure
  %                                          % mol/d.mol, specific som maint costs
  %    J_E1T     = p(19); MV        = p(20); % mol/d.cm^2, {J_E1T}, spec surface-area-linked som maint costs J_E1T/ J_E2T = j_E1M/ j_E2M
  %                                          % mol/cm^3, [M_V] density of structure
  %    k_J       = p(21); k1_J      = p(22); % 1/d, mat maint rate coeff, spec rejuvenation rate                                    
  %    kap_G     = p(23); del_V     = p(24); % -, growth efficiency
  %                                          % -, threshold for death by shrinking
  %    kap_E1    = p(25); kap_E2    = p(26); % -, fraction of rejected mobilised flux that is returned to reserve
  %    kap_R1    = p(27); kap_R2    = p(28); % -, reproduction efficiency for reserve i
  %    E_Hb      = p(29); E_Hp      = p(30); % J, maturity thresholds at birth, puberty
  %    T_A       = p(31); h_H       = p(32); % K, Arrhenius temperature
  %                                          % 1/d, hazerd due to rejuvenation
  %    h_a       = p(33); s_G       = p(34); % 1/d^2, ageing acceleration
  %
  % Output:
  %
  % * dvar: 11-vector with d/dt var

  % unpack parameters
  M_X1      = p( 1); M_X2      = p( 2); % mol, size of food particle of type i
  F_X1m     = p( 3); F_X2m     = p( 4); % dm^2/d.cm^2, {F_Xim} spec searching rates
 %y_P1X1    = p( 5); y_P2X2    = p( 6); % mol/mol, yield of feaces i on food i
  y_E1X1    = p( 7); y_E2X1    = p( 8); % mol/mol, yield of reserve Ei on food X1
  y_E1X2    = p( 9); y_E2X2    = p(10); % mol/mol, yield of reserve Ei on food X2
  J_X1Am    = p(11); J_X2Am    = p(12); % mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi  
  v         = p(13); kap       = p(14); % cm/d, energy conductance, 
                                        % -, allocation fraction to soma
  mu_E1     = p(15); mu_E2     = p(16); % J/mol, chemical potential of reserve i
  mu_V      = p(17); j_E1M     = p(18); % J/mol, chemical potenial of structure
                                        % mol/d.mol, specific som maint costs
  J_E1T     = p(19); MV        = p(20); % mol/d.cm^2, {J_E1T}, spec surface-area-linked som maint costs J_E1T/ J_E2T = j_E1M/ j_E2M
                                        % mol/cm^3, [M_V] density of structure
  k_J       = p(21); k1_J      = p(22); % 1/d, mat maint rate coeff, spec rejuvenation rate                                    
  kap_G     = p(23); del_V     = p(24); % -, growth efficiency
                                        % -, threshold for death by shrinking
  kap_E1    = p(25); kap_E2    = p(26); % -, fraction of rejected mobilised flux that is returned to reserve
  kap_R1    = p(27); kap_R2    = p(28); % -, reproduction efficiency for reserve i
  E_Hb      = p(29); E_Hp      = p(30); % J, maturity thresholds at birth, puberty
  T_A       = p(31); h_H       = p(32); % K, Arrhenius temperature
                                        % 1/d, hazerd due to rejuvenation
  h_a       = p(33); s_G       = p(34); % 1/d^2, ageing acceleration
                                        % -, Gompertz stress coefficient
                                      
  % unpack variables
  %cM_X1 = var( 1); cM_X2   = var( 2); % mol, cumulative ingested food
   M_E1  = var( 3); M_E2    = var( 4); % mol, reserve
   E_H   = var( 5); max_E_H = var( 6); % J, maturity, max maturity
   M_V   = var( 7); max_M_V = var( 8); % mol, structure, max structure
  %cM_E1R= var( 9); cM_E2R  = var(10); % mol, cumulative reprod
   q     = var(11); h       = var(12); % 1/d, 1/d^2 acceleration, harzard
   S     = var(13);                    % -, survival probability
 
  % repair numerical problems: M_Ei must be real and positive
  if isreal(M_E1) == 0 || M_E1 < 0
    M_E1 = 1e-10;
  end
  if isreal(M_E2) == 0 || M_E2 < 0
    M_E2 = 1e-10;
  end

  % get environmental variables at age t (linear interpolation)
  X1 = spline1(t, tXT(:,[1 2])); % mol/cd^2, food density of type 1
  X2 = spline1(t, tXT(:,[1 3])); % mol/cd^2, food density of type 1 
  T  = spline1(t, tXT(:,[1 4])); % K, temperature 

  if E_H < E_Hb % no assimilation before birth or surface-linked maintenance
    X1 = 0; X2 = 0;
    J_E1T = 0;
  end

  % help quantities
  L = (M_V/ MV)^(1/3);               % cm, structural length
  k_E = v/ L;                        % 1/d,  reserve turnover rate
   mu_EV = mu_E1/ mu_V;               % -, ratio of chemical potentials
   m_E1 = M_E1/ M_V; m_E2 = M_E2/ M_V;% mol/mol, reserve density
  % somatic maintenance
  j_E2M = j_E1M * mu_E1/ mu_E2;      % mol/d.mol
  J_E2T = J_E1T * mu_E2/ mu_E1;      % mol/d.cm^2
  j_E1S = j_E1M + J_E1T/ MV/ L;      % mol/d.mol total spec somatic maint
  j_E2S = j_E2M + J_E2T/ MV/ L;      % mol/d.mol
  J_E1S = j_E1S * MV;                % mol/d.cm^3 total spec somatic maint
  J_E2S = j_E2S * MV;                % mol/d.cm^3 total spec somatic maint

  % correct rates for temperature
  TC = tempcorr(T, 293, T_A); % -, temperature correction factor, T_ref = 293 K
  F_X1m     = TC * F_X1m;  F_X2m     = TC * F_X2m;  % dm^2/d.cm^2, {F_Xim} spec searching rates
  J_X1Am    = TC * J_X1Am; J_X2Am    = TC * J_X2Am; % mol/d.cm^2, {J_EiAm^Xi} max specfific assim rate for food X1
  j_E1S     = TC * j_E1S;  j_E2S     = TC * j_E2S;  % mol/d.mol, specific som maint costs
   v         = TC * v;      k_E = TC * k_E;          % cm/d, 1/d, energy conductance, reserve turnover rate
  k_J       = TC * k_J;    k1_J      = TC * k1_J;   % 1/d mat maint rate coeff, spec rejuvenation rate

  % feeding
    J_E2Am_X1 = y_E2X1 * J_X1Am; J_E2Am_X2 = y_E2X2 * J_X2Am; % mol/d.cm^2, max spec assim rate for reserve 2
  m_E1m = max(J_E1Am_X1/ v/ MV, J_E1Am_X2/ v/ MV);          % mol/mol, max reserve 1 density
   m_E2m = max(J_E2Am_X1/ v/ MV, J_E2Am_X2/ v/ MV);          % mol/mol, max reserve 2 density
  s1 = max(0, 1 - m_E1/ m_E1m); s2 = max(0, 1 - m_E2/ m_E2m);% -, stress factors for reserve 1, 2
  rho_X1X2 = s1 * max(0, M_X1/ M_X2 * y_E1X1/ y_E1X2 - 1) + s2 * max(0, M_X1/ M_X2 * y_E2X1/ y_E2X2 - 1);
  rho_X2X1 = s1 * max(0, M_X2/ M_X1 * y_E1X2/ y_E1X1 - 1) + s2 * max(0, M_X2/ M_X1 * y_E2X2/ y_E2X1 - 1);
  h_X1Am = J_X1Am/ M_X1; h_X2Am = J_X2Am/ M_X2;             % #/d.cm^2, max spec feeding rates
  alpha_X1 = h_X1Am + F_X1m * X1 + F_X2m * rho_X2X1 * X2; 
  alpha_X2 = h_X2Am + F_X2m * X2 + F_X1m * rho_X1X2 * X1;
  beta_X1 = F_X1m * X1 * (1 - rho_X1X2);  beta_X2 = F_X2m * X2 * (1 - rho_X2X1);
  f1 = (alpha_X2 * F_X1m * X1 - beta_X1 * F_X2m * X2)/ (alpha_X1 * alpha_X2 - beta_X1 * beta_X2);
  f2 = (alpha_X1 * F_X2m * X2 - beta_X2 * F_X1m * X1)/ (alpha_X1 * alpha_X2 - beta_X1 * beta_X2);
  dcM_X1 = f1 * J_X1Am * L^2; dcM_X2 = f2 * J_X2Am * L^2; % mol/d, feeding rates

  % assimilation
  J_E1A = f1 * y_E1X1 * J_X1Am + f2 * y_E1X2 * J_X2Am; % mol/d.cm^2, {J_E1A}, specific assimilation flux
  J_E2A = f1 * y_E2X1 * J_X1Am + f2 * y_E2X2 * J_X2Am; % mol/d.cm^2, {J_E2A}, specific assimilation flux
  j_E1A = J_E1A/ MV/ L; j_E2A = J_E2A/ MV/ L;          % mol/d.mol, {J_EA}/ L.[M_V], specific assim flux
  J_E1Am = J_E1Am_X1 + J_E1Am_X2;                      % mol/d.cm^2, total max spec assim rate for reserve 1
  J_E2Am = J_E2Am_X1 + J_E2Am_X2;                      % mol/d.cm^2, total max spec assim rate for reserve 2

  % reserve dynamics
  [r j_E1_S j_E2_S j_E1C j_E2C j_E1P j_E2P] = ...         % 1/d, specific growth rate, ....
    sgr_iso_21_var(m_E1, m_E2, j_E1S, j_E2S, mu_E1, mu_E2, mu_V, k_E, kap_G, kap); % use continuation
                  
  dm_E1 = j_E1A - j_E1C + kap_E1 * j_E1P - r * m_E1; % mol/d.mol, change in reserve density
  dm_E2 = j_E2A - j_E2C + kap_E2 * j_E2P - r * m_E2; % mol/d.mol
  dM_E1 = M_V * (dm_E1 + r * m_E1);                  % mol/d, change in reserve
  dM_E2 = M_V * (dm_E2 + r * m_E2);                  % mol/d
  J_E1C = M_V * j_E1C; J_E2C = M_V * j_E2C;          % mol/d, mobilisation rates
  p_C = mu_E1 * J_E1C + mu_E2 * J_E2C;               % J/d, total mobilisation power

  % growth
  dM_V = r * M_V;                                    % mol/d, growth rate (of structure)
  dmax_M_V = max(0, dM_V);                           % mol/d, max value of structure

  % maturation
  dE_H = (1 - kap) * p_C - k_J * E_H;                % J/d, maturation if juvenile
  if E_H >= E_Hp && dE_H >= 0 % adult 
    dE_H = 0;                                        % J/d, no maturation if adult
  elseif dE_H < 0
    dE_H = - k1_J * (E_H - (1 - kap) * p_C/ k_J);    % J/d, rejuvenation
  end
  dmax_E_H = max(0, dE_H);                           % J/d, max value of maturity

  % reproduction in adults
  J_E1R = J_E1C * (1 - kap - k_J * E_H/ p_C);        % mol/d, allocation to reprod from res 1
  J_E2R = J_E2C * (1 - kap - k_J * E_H/ p_C);        % mol/d, allocation to reprod from res 2
  dcM_E1R = kap_R1 * J_E1R * (E_H >= E_Hp);          % mol/d, accumulation in reprod buffer
  dcM_E2R = kap_R2 * J_E2R * (E_H >= E_Hp);          % mol/d, accumulation in reprod buffer

  % survival due to aging, shrinking, rejuvenation
  k_C = (j_E1C - j_E1P)/ m_E1 + (j_E2C - j_E2P)/ m_E2; % 1/d, summed [p_C]/[E_m]
  L_m = kap * min(J_E1Am/ J_E1S, J_E2Am/ J_E2S);     % cm, max structural length
  dq = (q * (L/ L_m)^3 * s_G + h_a) * k_C - r * q;   % 1/d^3, change in acceleration
  dh = q - r * h;                                    % 1/d^2, change in hazard by ageing
  h_S = 1e2 * (M_V < del_V * max_M_V);               % 1/d, hazard by shrinking
  h_R = h_H * (1 - E_H/ max_E_H);                    % 1/d, hazard by rejuvenation 
  dS = - S * (h + h_S + h_R);                        % 1/d, change in survival probability

  % pack output
  dvar = [dcM_X1; dcM_X2; dM_E1; dM_E2; dE_H; dmax_E_H; dM_V; dmax_M_V; dcM_E1R; dcM_E2R; dq; dh; dS];