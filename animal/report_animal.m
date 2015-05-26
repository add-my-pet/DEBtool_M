% created 2000/10/26 by Bas Kooijman, modified 2014/06/03
%
%% Description
% writes report on compound parameters and statistics
% called by 'pars_animal', after running 'parscomp', 'statistics'

txt_par = { ...     
  % 1 temperature 
    'actual body temperature, T, K';                          %  1
    'temp for which rate pars are given, T_ref, K';           %  2
    'Arrhenius temp, T_A, K';                                 %  3
    'lower boundary tolerance range, T_L, K';                 %  4
    'upper boundary tolerance range, T_H, K';                 %  5
    'Arrhenius temp for lower boundary, T_AL, K';             %  6
    'Arrhenius temp for upper boundary, T_AH, K';             %  7
  % 2 feeding 
    'scaled functional response, f, -';                       %  8
  % 3 scaling
    'zoom factor, z, -';                                      %  9
    'shape coefficient, del_M, -';                            % 10
  % 4 assimilation
    'max spec searching rate, {F_m}, l/d.cm^2';               % 11
    'digestion efficiency of food to reserve, kap_X, -';      % 12
    'faecation efficiency of food to faeces, kap_X_P, -;';    % 13
  % 5 mobilisation & allocation 
    'energy conductance, v, cm/d';                            % 14
    'allocation fraction to soma, kap, -' ;                   % 15
    'reproduction efficiency, kap_R, -';                      % 16
  % 6 maintenance
    'vol-specific somatic maintenance, [p_M], J/d.cm^3';      % 17
    'surface-specific som maintenance, {p_T}, J/d.cm^2';      % 18
    'maturity maint rate coefficient, k_J, 1/d';              % 19
  % 7 growth
    'specific cost for structure, [E_G], J/cm^3';             % 20
  % 8 life stages
    'maturity at birth, E_H^b, J';                            % 21
    'maturity at metamorphosis, E_H^j, J';                    % 22
    'maturity at puberty, E_H^p, J';                          % 23
  % 9 aging
    'Weibull aging acceleration, h_a, 1/d^2';                 % 24
    'Gompertz stress coefficient, s_G, -';                    % 25
     };

val_par = [ ... 
T; T_ref; T_A; T_L; T_H; T_AL ;T_AH % 1 | 1 2 3 4 5 6 7
f;                                  % 2 | 8
z; del_M;                           % 3 | 9 10
F_m; kap_X; kap_X_P;                % 4 | 11 12 13
v; kap; kap_R;                      % 5 | 14 15 16
p_M; p_T; k_J;                      % 6 | 17 18 19
E_G                                 % 7 | 20
E_Hb; E_Hj; E_Hp;                   % 8 | 21 22 23
h_a ; s_G                           % 9 | 24 25
];

txt_par = { ...     
  % 1 temperature 
    'actual body temperature, T, K';                          %  1
    'temp for which rate pars are given, T_ref, K';           %  2
    'Arrhenius temp, T_A, K';                                 %  3
    'lower boundary tolerance range, T_L, K';                 %  4
    'upper boundary tolerance range, T_H, K';                 %  5
    'Arrhenius temp for lower boundary, T_AL, K';             %  6
    'Arrhenius temp for upper boundary, T_AH, K';             %  7
  % 2 feeding 
    'scaled functional response, f, -';                       %  8
  % 3 scaling
    'zoom factor, z, -';                                      %  9
    'shape coefficient, del_M, -';                            % 10
  % 4 assimilation
    'max spec searching rate, {F_m}, l/d.cm^2';               % 11
    'digestion efficiency of food to reserve, kap_X, -';      % 12
    'faecation efficiency of food to faeces, kap_X_P, -;';    % 13
  % 5 mobilisation & allocation 
    'energy conductance, v, cm/d';                            % 14
    'allocation fraction to soma, kap, -' ;                   % 15
    'reproduction efficiency, kap_R, -';                      % 16
  % 6 maintenance
    'vol-specific somatic maintenance, [p_M], J/d.cm^3';      % 17
    'surface-specific som maintenance, {p_T}, J/d.cm^2';      % 18
    'maturity maint rate coefficient, k_J, 1/d';              % 19
  % 7 growth
    'specific cost for structure, [E_G], J/cm^3';             % 20
  % 8 life stages
    'maturity at birth, E_H^b, J';                            % 21
    'maturity at metamorphosis, E_H^j, J';                    % 22
    'maturity at puberty, E_H^p, J';                          % 23
  % 9 aging
    'Weibull aging acceleration, h_a, 1/d^2';                 % 24
    'Gompertz stress coefficient, s_G, -';                    % 25
     };

  % text for chemical coefficients
    txt_mudn = {... % used in report_xls
    'chemical potentials for X V E P, mu_O, J/mol'; 
    'specific densities for X V E P, d_O, g/cm^3'; 
    'chemical indices for X V E P, n_O, -'};

% html version
txt_par_primary = {
  % 1 temperature #FFC6A5
    'actual body temperature, T, K';                          %  1
    'Arrhenius temp, T_A, K';                                 %  2
    'lower boundary tolerance range, T_L, K';                 %  3
    'upper boundary tolerance range, T_H, K';                 %  4
    'Arrhenius temp for lower boundary, T_AL, K';             %  5
    'Arrhenius temp for upper boundary, T_AH, K';             %  6
  % 2 feeding     #F7BDDE
    'scaled functional response, f, -';                       %  7
  % 3 scaling     #DEBDDE
    'zoom factor, z, -';                                      %  8
    'shape coefficient, del_M, -';                            %  9
  % 4 assimilation #CEEFBD
    'max spec searching rate, {F_m}, l/d.cm^2';               % 10
    'digestion efficiency of food to reserve, kap_X, -';      % 11
    'faecation efficiency of food to faeces, kap_X_P, -;';    % 12
    'max spec assimilation rate, {p_Am}, J/d.cm^2';           % 13
  % 5 mobilisation & allocation #DEF3BD
    'energy conductance, v, cm/d';                            % 14
    'allocation fraction to soma, kap, -' ;                   % 15
    'reproduction efficiency, kap_R, -';                      % 16
  % 6 maintenance #FFFF9C
    'vol-specific somatic maintenance, [p_M], J/d.cm^3';      % 17
    'surface-specific som maintenance, {p_T}, J/d.cm^2';      % 18
    'maturity maint rate coefficient, k_J, 1/d';              % 19
  % 7 growth #FFFFC6
    'specific cost for structure, [E_G], J/cm^3';             % 20
  % 8 life stages #94D6E7
    'maturity at birth, E_H^b, J';                            % 21
    'maturity at metamorphosis, E_H^j, J';                    % 22
    'maturity at puberty, E_H^p, J';                          % 23
  % 9 aging #BDC6DE
    'Weibull aging acceleration, h_a, 1/d^2';                 % 24
    'Gompertz stress coefficient, s_G, -';                    % 25
  % 10 chemical potentials #C6E7DE
    'chemical potential of food, mu_X, J/mol';                % 26
    'chemical potential of structure, mu_V, J/mol';           % 27
    'chemical potential of reserve, mu_E, J/mol';             % 28
    'chemical potential of faeces, mu_P, J/mol';              % 29
  % 11 specific densities #C6EFF7
    'spec density of food, d_X,  g/cm^3';                     % 30 
    'spec density of structure, d_V,  g/cm^3';                % 31
    'spec density of reserve, d_E,  g/cm^3';                  % 32
    'spec density of faeces, d_P,  g/cm^3';                   % 33
  % 12 chemical indices #F7BDDE; #FFFFFF
    'chem. index of hydrogen in food, n_HX, -';               % 34
    'chem. index of oxygen in food, n_OX, -';                 % 35
    'chem. index of hydrogen in food, n_NX, -';               % 36
    'chem. index of nitrogen in structure, n_HV, -';          % 37
    'chem. index of oxygen in structure, n_OV, -';            % 38
    'chem. index of nitrogen in structure, n_NV, -';          % 39
    'chem. index of hydrogen in reserve, n_HE, -';            % 40
    'chem. index of oxygen in reserve, n_OE, -';              % 41
    'chem. index of nitrogen in reserve, n_NE, -';            % 42
    'chem. index of hydrogen in faeces, n_HP, -';             % 43
    'chem. index of oxygen in faeces, n_OP, -';               % 44
    'chem. index of nitrogen in faeces, n_NP'};               % 45

txt_sym_primary = {... % symbols for primary parameters
  'T, K'; 'T_A, K'; 'T_L, K'; 'T_H, K'; 'T_AL, K'; 'T_AH, K';
  'f, -'; 'z, -'; 'del_M, -'; '{F_m}, l/d.cm^2'; 'kap_X, -'; 'kap_X_P, -</TH>';
  '{p_Am}, J/d.cm^2'; 'v, cm/d'; 'kap, -'; 'kap_R, -';
  '[p_M], J/d.cm^3'; '{p_T}, J/d.cm^2'; 'k_J, 1/d'; '[E_G], J/cm^3';
  'E_Hb, J'; 'E_Hj, J'; 'E_Hp, J'; 'h_a, 1/d^2'; 's_G, -';
  'mu_X, J/mol'; 'mu_V, J/mol'; 'mu_E, J/mol'; 'mu_P, J/mol';
  'd_X,  g/cm^3'; 'd_V,  g/cm^3'; 'd_E,  g/cm^3'; 'd_P,  g/cm^3';
  'n_HX, -'; 'n_OX, -'; 'n_NX, -'; 'n_HV, -'; 'n_OV, -'; 'n_NV, -';
  'n_HE, -'; 'n_OE, -'; 'n_NE, -'; 'n_HP, -'; 'n_OP, -'; 'n_NP, -'};

n_par_primary = size(txt_sym_primary, 1);

col_par_primary = {... % colours for primary parameters
    '#FFC6A5'; '#F7BDDE'; '#DEBDDE'; '#CEEFBD'; '#DEF3BD'; '#FFFF9C'; '#FFFFC6'; '#94D6E7'; '#BDC6DE'; 
    '#C6E7DE'; '#C6EFF7'; '#F7BDDE'; '#FFFFFF'; '#F7BDDE'; '#FFFFFF'};
col_par_primary = col_par_primary([1 1 1 1 1 1 2 3 3 4 4 4 4 5 5 5 6 6 6 7 8 8 8 9 9 10 10 10 10 11 11 11 11 12 12 12 13 13 13 14 14 14 15 15 15]);    

%% text for statistics

txt_temperature = { ... % 1 
   'reference temp, T_ref, K ';                                            %   1
   'actual temp, T, K ';                                                   %   2
   'temperature correction factor, c_T, - '};                              %   3
txt_size_at_start = { ... % 2 
   'initial reserve mass at growth ceasing at birth, M_E^0, mol ';         %   4
   'initial reserve mass at maturation ceasing at birth, M_E^0, mol ';     %   5
   'initial reserve mass at maturation ceasing at puberty, M_E^0, mol ';   %   6
   'initial reserve mass at f, M_E^0, mol ';                               %   7
   'initial reserve energy at f, E_0, J ';                                 %   8
   'initial dry weight at f, W_d^0, g '};                                  %   9
txt_size_at_birth = { ... % 3 
   'fraction of reserve left at birth, U_E^b/ U_E^0, - ';                  %  10
   'structural length at birth, L_b, cm ';                                 %  11
   'structural mass at birth, M_V^b, mol ';                                %  12
   'physical length at birth, L_w^b, cm ';                                 %  13
   'dry weight at birth, W_d^b, g ';                                       %  14
   'birth weight as fraction of ultimate, W_b/ W_i, - '};                  %  15
txt_size_at_metamorphosis = { ... % 4 
   'structural length at metamorphosis, L_j, cm ';                         %  16
   'structural mass at metamorphosis, M_V^j, mol ';                        %  17
   'physical length at metamorphosis, L_w^j, cm ';                         %  18
   'dry weight at metamorphosis, W_d^j, g ';                               %  19
   'metamorphosis weight as fraction of ultimate, W_j/ W_i, - '};          %  20
txt_size_at_puberty = { ... % 5 
   'structural length at puberty, L_p, cm ';                               %  21
   'structural mass at puberty, M_V^p, mol ';                              %  22
   'physical length at puberty, L_w^p, cm ';                               %  23
   'dry weight at puberty, W_d^p, g ';                                     %  24
   'puberty weight as fraction of ultimate, W_p/ W_i, - '};                %  25
txt_final_size = { ... % 6 
   'maximum structural length, L_m, cm ';                                  %  26
   'ultimate structural length, L_i, cm';                                  %  27
   'ultimate structural mass, M_V^i, mol ';                                %  28
   'physical ultimate length, L_w^i, cm ';                                 %  29
   'maximum dry weight, W_d^m, g ';                                        %  30
   'ultimate dry weight, W_d^i, g';                                        %  31
   'fraction of weight that is structure, del_V, - '};                     %  32
txt_searching = { ... % 7      
   'max spec searching rate at T, {F_m}, l/d.cm^2';                        %  33
   'clearance rate at birth, CR_b, l/d';                                   %  34
   'clearance rate at puberty, CR_p, l/d';                                 %  35
   'ultimate clearance rate, CR_i, l/d'};                                  %  36
txt_food_densities = { ... % 8 
   'half saturation coefficient, K, M ';                                   %  37
   'food dens for maturation ceasing at birth, X_J^b, M ';                 %  38
   'food dens for growth ceasing at birth, X_G^b, M ';                     %  39
   'food dens for maturation and growth ceasing at puberty, X_J^p, M '};   %  40
txt_scaled_func_resp = { ... % 9 
   'scaled functional response, f, - ';                                    %  41
   'func resp for growth ceasing at birth, f_G^b, - ';                     %  42
   'func resp for maturation ceasing at birth, f_J^b, - ';                 %  43
   'func resp for maturation and growth ceasing at puberty, f_J^p, - '};   %  44
txt_feeding = { ... % 10 
   'max surface-spec feeding rate, {p_Xm}, J/d.cm^2 ';                     %  45
   'max surface-spec feeding rate, {J_XAm}, mol/d.cm^2 ';                  %  46
   'food energy intake at birth, p_Xb, J/d';                               %  47
   'food mass intake at birth, J_XAb, mol/d';                              %  48
   'food energy intake at puberty, p_Xp, J/d';                             %  49
   'food mass intake at puberty, J_XAp, mol/d';                            %  50
   'ultimate food energy intake, p_Xi, J/d';                               %  51
   'ultimate food mass intake, J_XAi, mol/d';                              %  52
   'max survival time when starved, [E_m]/[p_M], d'};                      %  53
txt_assimilation = { ... % 11 
   'max spec assimilation rate at T, {p_Am}, J/d.cm^2';                    %  54
   'max surface-spec assimilation rate, {J_EAm}, mol/d.cm^2 ';             %  55
   'yield of reserve on food, y_EX, mol/mol ';                             %  56
   'yield of faeces on food, y_PX, mol/mol '};                             %  57
txt_reserve_dynamics = { ... % 12 
   'energy conductance at T, v, cm/d';                                     %  58
   'maximum reserve residence time, t_E, d';                               %  59
   'reserve capacity, [E_m], J/cm^3 ';                                     %  60
   'reserve capacity, m_Em, mol/mol '};                                    %  61
txt_maintenance = { ... % 13 
   'vol-specific somatic maintenance at T, [p_M], J/d.cm^3';               %  62
   'surface-specific som maintenance at T, {p_T}, J/d.cm^2';               %  63
   'heating length, L_T, cm ';                                             %  64
   'somatic maintenance rate coeff, k_M, 1/d';                             %  65
   'maturity maint rate coefficient at T, k_J, 1/d';                       %  66
   'maintenance ratio, k, - ';                                             %  67
   'volume-spec som maint costs, [J_EM], mol/d.cm^3 ';                     %  68
   'surface-spec som maint costs, {J_ET}, mol/d.cm^2 ';                    %  69
   'mass-spec somatic  maint costs, j_EM,  mol/mol.d ';                    %  70
   'mass-spec maturity  maint costs, j_EJ, mol/mol.d '};                   %  71
txt_respiration = { ... % 14 
   'specific dynamic action for L = L_b, SDA, mol O/ mol X ';              %  72
   'respiration quotient for L = L_b, RQ, mol C/ mol O ';                  %  73
   'urination quotient for L = L_b, UQ, mol N/ mol O ';                    %  74
   'watering quotient for L = L_b, WQ, mol H/ mol O ';                     %  75
   'dioxygen use per dry weight Wd_b, L/g.h';                              %  76
   'heat dissipation for L = L_b, p_T^+, J/d ';                            %  77
   'specific dynamic action for L = L_p, SDA, mol O/ mol X ';              %  78
   'respiration quotient for L = L_p, RQ, mol C/ mol O ';                  %  79
   'urination quotient for L = L_p, UQ, mol N/ mol O ';                    %  80
   'watering quotient for L = L_p, WQ, mol H/ mol O ';                     %  81
   'dioxygen use per dry weight Wd_p, L/g.h';                              %  82
   'heat dissipation for L = L_p, p_T^+, J/d ';                            %  83
   'specific dynamic action for L = L_i, SDA, mol O/ mol X ';              %  84
   'respiration quotient for L = L_i, RQ, mol C/ mol O ';                  %  85
   'urination quotient for L = L_i, UQ, mol N/ mol O ';                    %  86
   'watering quotient for L = L_i, WQ, mol H/ mol O ';                     %  87
   'dioxygen use per dry weight Wd_i, L/g.h';                              %  88
   'heat dissipation for L = L_i, p_T^+, J/d '};                           %  89
txt_growth = { ... % 15 
   'yield of structure on reserve, y_VE, mol/mol ';                        %  90
   'growth efficiency, kappa_G, - ';                                       %  91
   'energy investment ratio, g, - ';                                       %  92
   'von Bertalanffy growth rate, r_B, 1/d '};                              %  93
txt_reproduction = { ... % 16 
   'ultimate reproduction rate, R_i, 1/d ';                                %  94
   'gonado-somatic index, GSI, mol/mol ';                                  %  95
   'acceleration factor, s_M, -';                                          %  96
   'altriciality index, log10 s_H^pb, -';                                  %  97
   'supply stress, s_s, -'};                                               %  98
txt_age_aging = { ... % 17  
   'age at birth, a_b, d ';                                                %  99
   'age at metamorphosis, a_j, d ';                                        % 100
   'age at puberty, a_p, d ';                                              % 101
   'age at 99% of ultimate length, d';                                     % 102
   'mean life span, a_m, d ';                                              % 103
   'survival probability at birth, S_b, - ';                               % 104
   'survival probability at puberty, S_p, - ';                             % 105
   'Weibull aging acceleration at T, h_a , 1/d^2';                         % 106
   'Weibull aging rate at T, h_W, 1/d';                                    % 107
   'Gompertz aging rate at T, h_G, 1/d'};                                  % 108
txt_conversion = { ... % 18 
   'vol-spec structural mass, [M_V], mol/cm^3 ';                           % 109
   'vol-spec structural energy, [E_V], J/cm^3 ';                           % 110
   'energy density of whole dry body, <E + E_V>, J/g '};                   % 111
txt_population = { ... % 19 
   'maximum specific population growth rate, r_m, 1/d ';                   % 112
   'mean age of juveniles + adults at f=1, Ea, d ';                        % 113
   'mean structural length of juveniles + adults at f=1, EL, cm ';         % 114
   'mean squared structural length of juv + adults at f=1, EL^2, cm^2 ';   % 115
   'mean structural cubed length of juv + adults at f=1, EL^3, cm^3 ';     % 116
   'scaled func response at no pop growth, f_0, - ';                       % 117
   'mean age of juveniles + adults at r=0, Ea, d ';                        % 118
   'mean structural length of juveniles + adults at r=0, EL, cm ';         % 119
   'mean squared structural length of juv + adults at r=0, EL^2, cm^2 ';   % 120
   'mean cubed structural length of juv + adults at r=0, EL^3, cm^3 '};    % 121
txt_statistics = [ ...
    txt_temperature                  %  1  #FFC6A5  3
    txt_size_at_start                %  2  #FFFFFF  6
    txt_size_at_birth                %  3  #C6E7DE  6
    txt_size_at_metamorphosis        %  4  #CEEFBD  5
    txt_size_at_puberty              %  5  #CEEFBD  5
    txt_final_size                   %  6  #DEF3BD  7
    txt_searching                    %  7  #FFFFC6  4
    txt_food_densities               %  8  #BDC6DE  4
    txt_scaled_func_resp             %  9  #C6B5DE  4
    txt_feeding                      % 10  #DEBDDE  9
    txt_assimilation                 % 11  #F7BDDE  4
    txt_reserve_dynamics             % 12  #C6E7DE  4
    txt_maintenance                  % 13  #FFFFC6 10
    txt_respiration                  % 14  #FFC6A5 18
    txt_growth                       % 15  #FFFFC6  4
    txt_reproduction                 % 16  #F7BDDE  5
    txt_age_aging                    % 17  #BDC6DE 10
    txt_conversion                   % 18  #FFFFC6  3
    txt_population];                 % 19  #FFFFFF 10

val_statistics = [ ...                      % 
    T_ref; T; TC;                           %  1 | 1 2 3
    M_E0_min_b; M_E0_min_p; M_E0; E_0; W_0; %  2 | 4 5 6 7 8 9
    del_Ub; L_b; M_Vb; Lw_b; W_b; del_Wb;   %  3 | 10 11 12 13 14 15
    L_j; M_Vj; Lw_j; W_j; del_Wj;           %  4 | 16 17 18 19 20
    L_p; M_Vp; Lw_p; W_p; del_Wp;           %  5 | 21 22 23 24 25
    L_m; L_i; M_Vi; Lw_i; W_m; W_i; del_V;  %  6 | 26 27 28 29 30 31 32
    FT_m; CR_b; CR_p; CR_i;                 %  7 | 33 34 35 36
    K; Kb_min; Kp_min;                      %  8 | 37 38 39 40
    f; eb_min; ep_min;                      %  9 | 41 42 43 44
    pT_Xm; JT_X_Am; pT_Xb;                  % 10 | 45 46 47
      JT_XAb; pT_Xp; JT_XAp; pT_Xi; JT_XAi; %    | 48 49 50 51 52
      t_starve;                             %    | 53
    pT_Am; JT_E_Am; y_E_X; y_P_X;           % 11 | 54 55 56 57
    vT; t_E; E_m; m_Em;                     % 12 | 58 59 60 61
    pT_M; pT_T; L_T; kT_M; kT_J; k;         % 13 | 62 63 64 65 66 67
      JT_E_M; JT_E_T; jT_E_M; jT_E_J;       %    | 68 69 70 71
    SDA_b; RQ_b; UQ_b; WQ_b; VO_b; p_Tt_b;  % 14 | 72 73 74 75 76 77
      SDA_p; RQ_p; UQ_p; WQ_p; VO_p; p_Tt_p;%    | 78 79 80 81 82 83
      SDA_i; RQ_i; UQ_i; WQ_i; VO_i; p_Tt_i;%    | 84 85 86 87 88 90
    y_V_E; kap_G; g; r_B;                   % 15 | 91 92 93 94
    R_i; GI; s_M; s_H; s_s;                 % 16 | 95 96 97 98 99
    a_b; a_j; a_p; a_99; a_m; S_b; S_p;     % 17 | 100 101 102 103 104 105 106
      hT_a; hT_W; hT_G;                     %    | 107 108 109
    M_V; E_V; xi_W_E;                       % 18 | 110 111 112
    r_m; Ea_m; EL_m; EL2_m; EL3_m;          % 19 | 113 114 115 116 117
      f_r; Ea_0; EL_0; EL2_0; EL3_0;        %    | 118 119 120 121 122
    ];

  printpar(txt_statistics, val_statistics)
  fprintf('\n');
  printpar(txt_par, val_par)
