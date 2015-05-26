% created 2000/10/26 by Bas Kooijman, modified 2014/06/03
%
%% Description
% writes report on compound parameters and statistics
% called by 'pars_animal', after running 'parscomp', 'statistics'

if exist('txt_statistics','var') == 0
  report_init
end

n_author = length(author);
if n_author == 1
  txt_author = author{1};
elseif n_author == 2
  txt_author = [author{1}, ', ', author{2}];
else
  txt_author = [author{1}, ', et al.'];
end
txt_date = [num2str(date(1)), '/', num2str(date(2)), '/', num2str(date(3))]; 
%txt_date = num2str(date);
if exist('author_mod', 'var') == 1 && exist('date_mod', 'var') == 1
  n_author_mod = length(author_mod);
  if n_author_mod == 1
    txt_author_mod = author{1};
  elseif n_author == 2
    txt_author_mod = [author_mod{1}, ', ', author_mod{2}];
  else
    txt_author_mod = [author_mod{1}, ', et al.'];
  end
  txt_date_mod = [num2str(date_mod(1)), '/', num2str(date_mod(2)), '/', num2str(date_mod(3))]; 
else
  txt_author_mod = '';
  txt_date_mod =  '';
end

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

 if E_Hj ~= E_Hb && foetus == 1
   TYPE = 4; % acceleration and foetal development
 elseif E_Hj ~= E_Hb
   TYPE = 3; % acceleration
 elseif foetus == 1
   TYPE = 2; % foetal development
 else
   TYPE = 1; % standard
 end
 
if exist('file_name','var') == 0  % print to screen if no file_name is specified
  printpar(txt_statistics, val_statistics)
else
  fprintf([num2str(n_spec), ' ', species, '\n']);
end

% printpar(txt_par, val_par)
