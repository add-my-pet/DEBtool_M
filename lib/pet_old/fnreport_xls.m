%% routine to pimp Species.xls, called by pars_my_pets

i = i + 1; % increment row number

%% sheet 1, table of contents
  xlswrite(file_name, {species}, 1, ['B', num2str(i)])
   
%% sheet 2, primary parameters
if i == 1
  xlswrite(file_name, {'species'},         2, 'A1');
  xlswrite(file_name, {'T_ref, K'},        2, 'B1');
  xlswrite(file_name, {'T_A, K'},          2, 'C1');
  xlswrite(file_name, {'T_L, K'},          2, 'D1');
  xlswrite(file_name, {'T_H, K'},          2, 'E1');
  xlswrite(file_name, {'T_AL, K'},         2, 'F1');
  xlswrite(file_name, {'T_AH, K'},         2, 'G1');
  xlswrite(file_name, {'z, -'},            2, 'H1');
  xlswrite(file_name, {'del_M, -'},        2, 'I1');
  xlswrite(file_name, {'{F_M}, l/d.cm^2'}, 2, 'J1');
  xlswrite(file_name, {'kap_X, -'},        2, 'K1');
  xlswrite(file_name, {'kap_X_P, -'},      2, 'L1');
  xlswrite(file_name, {'{p_Am}, J/d.cm^2'},2, 'M1');
  xlswrite(file_name, {'v, cm/d'},         2, 'N1');
  xlswrite(file_name, {'kap, -'},          2, 'O1');
  xlswrite(file_name, {'kap_R, -'},        2, 'P1');
  xlswrite(file_name, {'[p_M], J/d.cm^3'}, 2, 'Q1');
  xlswrite(file_name, {'{p_T}, J/d.cm^2'}, 2, 'R1');
  xlswrite(file_name, {'k_J, 1/d'},        2, 'S1');
  xlswrite(file_name, {'[E_G], J/d.cm^3'}, 2, 'T1');
  xlswrite(file_name, {'E_Hb, J'},         2, 'U1');
  xlswrite(file_name, {'E_Hp, J'},         2, 'V1');
  xlswrite(file_name, {'h_a, 1/d^2'},      2, 'W1');
  xlswrite(file_name, {'s_G, -'},          2, 'X1');
  xlswrite(file_name, {'f, -'},            2, 'Y1');
  xlswrite(file_name, {'mu_X, J/mol'},     2, 'Z1');
  xlswrite(file_name, {'mu_V, J/mol'},     2, 'AA1');
  xlswrite(file_name, {'mu_E, J/mol'},     2, 'AB1');
  xlswrite(file_name, {'mu_P, J/mol'},     2, 'AC1');
  xlswrite(file_name, {'d_X,  g/cm^3'},    2, 'AD1');
  xlswrite(file_name, {'d_V,  g/cm^3'},    2, 'AE1');
  xlswrite(file_name, {'d_E,  g/cm^3'},    2, 'AF1');
  xlswrite(file_name, {'d_P,  g/cm^3'},    2, 'AG1');
  xlswrite(file_name, {'n_HX, -'},         2, 'AH1');
  xlswrite(file_name, {'n_OX, -'},         2, 'AI1');
  xlswrite(file_name, {'n_NX, -'},         2, 'AJ1');
  xlswrite(file_name, {'n_HV, -'},         2, 'AK1');
  xlswrite(file_name, {'n_OV, -'},         2, 'AL1');
  xlswrite(file_name, {'n_NV, -'},         2, 'AM1');
  xlswrite(file_name, {'n_HE, -'},         2, 'AN1');
  xlswrite(file_name, {'n_OE, -'},         2, 'AO1');
  xlswrite(file_name, {'n_NE, -'},         2, 'AP1');
  xlswrite(file_name, {'n_HP, -'},         2, 'AQ1');
  xlswrite(file_name, {'n_OP, -'},         2, 'AR1');
  xlswrite(file_name, {'n_NP, -'},         2, 'AS1');
else
  j = i + 1;
  xlswrite(file_name, {species},         2, ['A', num2str(j)]);
  xlswrite(file_name, T_ref,             2, ['B', num2str(j)]);
  xlswrite(file_name, T_A,               2, ['C', num2str(j)]);
  xlswrite(file_name, T_L,               2, ['D', num2str(j)]);
  xlswrite(file_name, T_H,               2, ['E', num2str(j)]);
  xlswrite(file_name, T_AL,              2, ['F', num2str(j)]);
  xlswrite(file_name, T_AH,              2, ['G', num2str(j)]);
  xlswrite(file_name, z,                 2, ['H', num2str(j)]);
  xlswrite(file_name, del_M,             2, ['I', num2str(j)]);
  xlswrite(file_name, F_m,               2, ['J', num2str(j)]);
  xlswrite(file_name, kap_X,             2, ['K', num2str(j)]);
  xlswrite(file_name, kap_X_P,           2, ['L', num2str(j)]);
  xlswrite(file_name, p_Am,              2, ['M', num2str(j)]);
  xlswrite(file_name, v,                 2, ['N', num2str(j)]);
  xlswrite(file_name, kap,               2, ['O', num2str(j)]);
  xlswrite(file_name, kap_R,             2, ['P', num2str(j)]);
  xlswrite(file_name, p_M,               2, ['Q', num2str(j)]);
  xlswrite(file_name, p_T,               2, ['R', num2str(j)]);
  xlswrite(file_name, k_J,               2, ['S', num2str(j)]);
  xlswrite(file_name, E_G,               2, ['T', num2str(j)]);
  xlswrite(file_name, E_Hb,              2, ['U', num2str(j)]);
  xlswrite(file_name, E_Hp,              2, ['V', num2str(j)]);
  xlswrite(file_name, h_a,               2, ['W', num2str(j)]);
  xlswrite(file_name, s_G,               2, ['X', num2str(j)]);
  xlswrite(file_name, f,                 2, ['Y', num2str(j)]);
  xlswrite(file_name, mu_X,              2, ['Z', num2str(j)]);
  xlswrite(file_name, mu_V,              2, ['AA', num2str(j)]);
  xlswrite(file_name, mu_E,              2, ['AB', num2str(j)]);
  xlswrite(file_name, mu_P,              2, ['AC', num2str(j)]);
  xlswrite(file_name, d_O(1),            2, ['AD', num2str(j)]);
  xlswrite(file_name, d_O(2),            2, ['AE', num2str(j)]);
  xlswrite(file_name, d_O(3),            2, ['AF', num2str(j)]);
  xlswrite(file_name, d_O(4),            2, ['AG', num2str(j)]);
  xlswrite(file_name, n_O(2,1),          2, ['AH', num2str(j)]);
  xlswrite(file_name, n_O(3,1),          2, ['AI', num2str(j)]);
  xlswrite(file_name, n_O(4,1),          2, ['AJ', num2str(j)]);
  xlswrite(file_name, n_O(2,2),          2, ['AK', num2str(j)]);
  xlswrite(file_name, n_O(3,2),          2, ['AL', num2str(j)]);
  xlswrite(file_name, n_O(4,2),          2, ['AM', num2str(j)]);
  xlswrite(file_name, n_O(2,3),          2, ['AN', num2str(j)]);
  xlswrite(file_name, n_O(3,3),          2, ['AO', num2str(j)]);
  xlswrite(file_name, n_O(4,3),          2, ['AP', num2str(j)]);
  xlswrite(file_name, n_O(2,4),          2, ['AQ', num2str(j)]);
  xlswrite(file_name, n_O(3,4),          2, ['AR', num2str(j)]);
  xlswrite(file_name, n_O(4,4),          2, ['AS', num2str(j)]);
end

%% sheet species
if i > 1
  xlswrite(file_name, {'specific densities, d_O'},  species, 'D26');
  xlswrite(file_name, d_O, species, 'E26:H26');
  xlswrite(file_name, {'chemical indices, n_O'},  species, 'D27');
  xlswrite(file_name, n_O, species, 'E27:H29');
end
