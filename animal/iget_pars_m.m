%% iget_pars_m
% Gets data from parameters for foetal development

%%
function d = iget_pars_m(par, x)
  %  created 2007/08/12 by Bas Kooijman; modified 2009/09/29
  
  %% Syntax
  % d = <../get_pars_m.m *get_pars_m*> (par, x)
  
  %% Description
  % Gets data from parameters for foetal development
  %
  % Input
  %
  % * par: (19)-vector with parameters (see below)
  % * x: independent variable, not used
  %
  % Output
  %
  % * d: (29,1)-matrix with parameters plus quantities
  %
  %    1 ab, d, age at birth
  %    2 ap, d, age at puberty
  %    3 Lb, mm, length at birth
  %    4 Lp, mm, length at puberty
  %    5 Li, mm, ultimate length
  %    6 Wb, g, weight at birth
  %    7 Wp, g, weight at puberty
  %    8 Wi, g, ultimate weight
  %    9 rB, 1/d, von Bertalanffy growth rate
  %    10 Ri, #/d, maximum reproduction rate
  %    11 am, d, life span
  %    12-29: parameters
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>

  % unpack par
  T    =   par(1); % K, actual body temperature ADAPT THIS FOR B.musculus
  T_ref  = par(2); % K, temp for which rate pars are given 
  T_A  =  par(3); % K, Arrhenius temp
  f = par(4); % scaled functional response
  z = par(5);       % zoom factor ADAPT THIS FOR B.musculus
  del_M = par(6); % -, shape coefficient to convert vol-length to physical length
  %F_m = par(7);       % l/d.cm^2, {F_m} max spec searching rate
  %kap_X = par(8);     % -, digestion efficiency of food to reserve
  v = par(9);        % cm/d, energy conductance
  kap = par(10);       % -, alloaction fraction to soma = growth + somatic maintenance
  kap_R = par(11);    % -, reproduction efficiency
  p_M = par(12);        % J/d.cm^3, [p_M] vol-specific somatic maintenance
  p_T =  par(13);        % J/d.cm^2, {p_T} surface-specific som maintenance
  k_J = par(14);     % 1/d, < k_M = p_M/E_G, maturity maint rate coefficient
  E_G = par(15);      % J/cm^3, [E_G], spec cost for structure
  E_Hb = par(16); % J, E_H^b
  E_Hp = par(17);  % J, E_H^p 
  h_a = par(18);   % 1/d^2, Weibull aging acceleration
  s_G = par(19);       % -, Gompertz stress coefficient

  global dwm

  d_V = dwm(2,1); %d_E = dwm(3,1);
  w_V = dwm(2,2); w_E = dwm(3,2);
  % mu_V = dwm(2,3); 
  mu_E = dwm(3,3);

  % Selected copy-paste from parscomp & statistics
  p_Am = z * p_M/ kap; % J/d.cm^2, {p_Am} spec assimilation flux

  TC = tempcorr(T,T_ref,T_A);   % -, Temperature Correction factor; ONLY WORK WITH T_A

  %FT_m = TC * F_m;                 % L/d.cm^2, {F_m} max spec searching rate
  pT_Am = TC * p_Am;               % J/d.cm^2, temp corrected spec assimilation rate
  vT = TC * v;                     % cm/d, temp corrected energy conductance 
  pT_M = TC * p_M;                 % J/d.cm^3, temp corrected vol-specific som maint costs
  pT_T = TC * p_T;                 % J/d.cm^2, temp corrected sur-specific som maint costs
  kT_J = TC * k_J;                 % 1/d, temp corrected mat maint rate coefficient
  %hT_a = TC * TC * h_a;            % 1/d^2, temp corrected aging acceleration

  M_V = d_V/ w_V;                  % mol/cm^3, written as [M_V] in the book

  JT_E_Am = pT_Am/ mu_E;           % mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux

  y_V_E = mu_E * M_V/ E_G;  % mol/mol, yield of structure on reserve
  y_E_V = 1/ y_V_E;                % mol/mol, yield of reserve on structure

  kT_M = pT_M/ E_G;                % 1/d, somatic maintenance rate coefficient
  k = kT_J/ kT_M;                  % 1/d, maintenance ratio
  %pT_Xm = pT_Am/ kap_X;            % J/d.cm^2, max spec feeding power

  E_m = pT_Am/ vT;                 % J/cm^3, reserve capacity [E_m]
  m_Em = y_E_V * E_m/ E_G;         % mol/mol, reserve capacity 
  g = E_G/ kap/ E_m;               % -, energy investment ratio

  L_m = vT/ kT_M/ g;               % cm, maximum length
  L_T = pT_T/ pT_M;                % cm, heating length (also applies to osmotic work)
  l_T = L_T/ L_m;                  % -, scaled heating length

  M_Hb = E_Hb/ mu_E;               % mmol, maturity at birth
  M_Hp = E_Hp/ mu_E;               % mmol, maturity at puberty
  U_Hb = M_Hb/ JT_E_Am;            % cm^2 d, scaled maturity at birth
  V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
  v_Hb = V_Hb * g^2 * kT_M^3/ vT^2;% -, scaled maturity density at birth
  %u_Hb = U_Hb * g^2 * kT_M^3/ vT^2;% -, scaled maturity density at birth
  U_Hp = M_Hp/ JT_E_Am;            % cm^2 d, scaled maturity at puberty 
  V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
  v_Hp = V_Hp * g^2 * kT_M^3/ vT^2;% -, scaled maturity density at puberty
  %u_Hp = U_Hp * g^2 * kT_M^3/ vT^2;% -, scaled maturity density at puberty  

  % foetal development
  pars_lb = [g; k; v_Hb];
  [l_b, t_b info] = get_lb_foetus(pars_lb);
  if info ~= 1
    fprintf('warning: invalid parameter value combination for foetus \n')
  end
  L_b = L_m * l_b; % cm, length at birth of foetus  at f = 1
  a_b = t_b/ kT_M; % d, age at birth of foetus at f = 1
  W_b = L_b^3 * d_V * (1 + f * m_Em * w_E/ w_V); % weight at birth

  % puberty
  pars_lp = [g; k; l_T; v_Hb; v_Hp];
  l_p = get_lp(pars_lp, f,l_b); L_p = L_m * l_p;
  ir_B = 3/ kT_M + 3 * f * L_m/ vT; r_B = 1/ir_B; % d, 1/von Bert growth rate
  l_i = f - l_T; L_i = L_m * l_i; % ultimate scaled length
  t_p = t_b + ir_B * log((l_i - l_b)/ (l_i - l_p)); a_p = t_p/ kT_M;
  W_p = L_p^3 * d_V * (1 + f * m_Em * w_E/ w_V); % weight at puberty
 
  % ultimate weight
  W_i = L_i^3 * d_V * (1 + f * m_Em * w_E/ w_V); % ultimate weight

  % reproduction
  pars_R = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];
  R_i = reprod_rate(L_i, f, pars_R); % ultimate reproduction rate

  % life span
  pars_tm = [g; k; l_T; v_Hb; v_Hp; h_a/ kT_M^2; s_G]; 
  t_m = get_tm_s(pars_tm, f, l_b); a_m = t_m/ kT_M; % d, mean life span

  % convert structural to physical length
  L_b = L_b/ del_M;
  L_p = L_p/ del_M;
  L_i = L_i/ del_M;

  % pack output
  d = [a_b; a_p; L_b; L_p; L_i; W_b; W_p; W_i; r_B; R_i; a_m; par];
  