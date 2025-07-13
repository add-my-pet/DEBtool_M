%% get_FMR
% Get field metabolic rate

%%
function FMR = get_FMR(pet, W, T, f)
  %  created at 2025/07/13 by Bas Kooijman
  
  %% Syntax
  % FMR = <../get_FMR.m *get_FMR*> (pet, W, T, f)
  
  %% Description
  % Obtains the field metabolic rate, given body weight, temperature and scaled functional response
  %
  % Input
  %
  % * pet: character string with name of entry, e.g. 'Dapnia_magna'
  % * W: optional scalar with body mass in g (default ultimate mass when f=1)
  % * T: optional scalar with temperature in C (default 20 C)
  % * f: optional scalar with scaled functional response (defalt 1)
  %  
  % Output
  %
  % * FMR: field metabolic rate in mol/d
  
  %% Remarks
  % uses allStat to get parameter values
  
  %% Example of use
  % FMR = get_FMR('Daphnia_magna')
 
  if ~exist('W','var')
    W = read_stat(pet,'Wwi'); % g, ultimate wet weight
  end
  if ~exist('T','var')
    T = 20; % C, T_ref
  end
  if ~exist('f','var')
    f = 1; % -, scaled function response
  end
  
  TC = tempcorr(C2K(T), C2K(20), read_stat(pet,'T_A')); % -, temp correction coefficient
  L = (W/ (1 + f * read_stat(pet,'ome')))^(1/3); % cm, struc length
  model = read_stat(pet,'model'); model = model{:}; p_Am = read_stat(pet,'p_Am'); L_m = read_stat(pet,'L_m');
  p_ref = TC * p_Am * L_m^2; % J/d, max assimilation power at max size

  switch model
    case {'std', 'stf', 'stx', 'ssj'}
      L3 = read_stat(pet,{'L_b', 'L_p', 'L_i'}); L_b=L3(1); L_p=L3(2); L_i=L3(3); 
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hp'}); 
      if L_i < L_p || L_i - L_p < 1e-8
        p_ACSJGRD = p_ref * scaled_power(L, f, pars_power, L_b/L_m, L_p/L_m);
      else
        p_ACSJGRD = p_ref * scaled_power(L, f, pars_power, L_b/L_m, L_p/L_m);
      end
    case 'sbp' % no growth, no kappa rule after p
      L2 = read_stat(pet,{'L_b', 'L_p'}); L_b=L2(1); L_p=L2(2);  
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hp'}); 
      p_ACSJGRD = p_ref * scaled_power_sbp(L, f, pars_power, L_b/L_m, L_p/L_m); 
      p_ACSJGRD(3,5) = 0; % p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); 
    case 'abp'% no growth, no kappa rule after p
      L2 = read_stat(pet,{'L_b', 'L_p'}); L_b=L2(1); L_p=L2(2); 
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hp'}); 
      pars_power = [pars_power, pars_power(9) + 1e-6];
      p_ACSJGRD = p_ref * scaled_power_abp(L, f, pars_power, L_b/L_m, L_p/L_m);
      p_ACSJGRD(3,5) = 0; % p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); 
    case 'abj'
      L3 = read_stat(pet,{'L_b', 'L_j', 'L_p'}); L_b=L3(1); L_j=L3(2); L_p=L3(3); 
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hj', 'U_Hp'}); 
      p_ACSJGRD = p_ref * scaled_power_j(L, f, pars_power, L_b/L_m, L_j/L_m, L_p/L_m);
    case 'asj'
      L4 = read_stat(pet,{'L_b', 'L_s', 'L_j', 'L_p'}); L_b=L4(1); L_s=L4(2); L_j=L4(3); L_p=L4(4); 
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hs', 'U_Hj', 'U_Hp'}); 
      p_ACSJGRD = p_ref * scaled_power_s(L, f, pars_power, L_b/L_m, L_s/L_m, L_j/L_m, L_p/L_m); 
    case 'hep' % ultimate is here mapped to metam
      L3 = read_stat(pet,{'L_b', 'L_j', 'L_p'}); L_b=L3(1); L_j=L3(2); L_p=L3(3); 
      pars_power = read_stat(pet,{'kap', 'kap_R', 'g', 'k_J', 'k_M', 'L_T', 'v', 'U_Hb', 'U_Hp'}); 
      pars_power = [pars_power, pars_power(9) + 1e-6];
      p_ACSJGRD = p_ref * scaled_power_j(L, f, pars_power, L_b/L_m, L_p/L_m, L_j/L_m);
    case 'hax' % ultimate is here mapped to pupation
      L4 = read_stat(pet,{'L_b', 'L_p', 'L_j', 'L_e'}); L_b=L4(1); L_p=L4(2); L_j=L4(3); L_3=L4(4); 
      pars_power = read_stat(pet,{'kap', 'kap_V', 'kap_R', 'g', 'k_J',  'k_M', 'v', 'U_Hb', 'U_Hp', 'U_He'}); 
      p_ACSJGRD = p_ref * scaled_power_hax(L, f, pars_power, L_b/L_m, L_p/L_m, L_j/L_m, L_e/L_m, read_stat(pet,t_j));
    case 'hex' % birth and puberty coincide; ultimate is here mapped to pupation
      L3 = read_stat(pet,{'L_b', 'L_j', 'L_e'}); L_b=L3(1); L_j=L3(2); L_e=L3(3); 
      pars_power = read_stat(pet,{'kap', 'kap_V', 'kap_R', 'g', 'k_J',  'k_M', 'v', 'U_Hb', 'U_He'}); 
      p_ACSJGRD = p_ref * scaled_power_hex(L, f, pars_power, L_b/L_m, L_j/L_m, L_e/L_m, read_stat(pet,t_j));
  end
  n_O = read_stat(pet, {'n_CX', 'n_HX', 'n_OX', 'n_NX','n_CV', 'n_HV', 'n_OV', 'n_NV','n_CE', 'n_HE', 'n_OE', 'n_NE','n_CP', 'n_HP', 'n_OP', 'n_NP' });
  n_M = read_stat(pet, {'n_CC', 'n_HC', 'n_OC', 'n_NC','n_CH', 'n_HH', 'n_OH', 'n_NH','n_CO', 'n_HO', 'n_OO', 'n_NO','n_CN', 'n_HN', 'n_ON', 'n_NN' });
  n_O = n_O([1:4;5:8;9:12;13:16])'; n_M = n_M([1:4;5:8;9:12;13:16])'; 
  p_eta = read_stat(pet, {'mu_E', 'y_X_E', 'y_P_E', 'y_V_E'});
  mu_E = p_eta(1); y_X_E = p_eta(2); y_P_E = p_eta(3); y_V_E = p_eta(4);
  eta_XA = y_X_E/ mu_E; eta_PA = y_P_E/ mu_E; eta_VG = y_V_E/ mu_E; eta_O = [-eta_XA 0 0; 0 0 eta_VG; 1/mu_E -1/mu_E -1/mu_E; eta_PA 0 0];
  p_ADG = p_ACSJGRD(:, [1 7 5]);
  J_M = - (n_M\n_O) * eta_O * p_ADG';  % mol/d: J_C, J_H, J_O, J_N in rows
  FMR = -J_M(3,:); % mol/d 
end