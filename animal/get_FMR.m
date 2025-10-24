%% get_FMR
% Get field metabolic rate

%%
function FMR = get_FMR(pet, W, T, F)
  %  created at 2025/07/13 by Bas Kooijman
  
  %% Syntax
  % FMR = <../get_FMR.m *get_FMR*> (pet, W, T, F)
  
  %% Description
  % Obtains the field metabolic rate, given body weight, temperature and scaled functional response
  %
  % Input
  %
  % * pet: character string with name of entry, e.g. 'Dapnia_magna'
  % * W: optional scalar with body mass in g (default ultimate mass when f=1)
  % * T: optional scalar with temperature in C (default T_typical)
  % * F: optional scalar with scaled functional response (default 1)
  %  
  % Output
  %
  % * FMR: field metabolic rate in mol/d
  
  %% Remarks
  % uses results_my_pet.mat files to get parameter values and required wget.exe.
  % density of O2 is 1.429 g/liter at 20 degC and 1 atm of pressure, so 
  % 1 mol/d = 32e3 mg/d = 32e3/24/60/1.429 = 15.55 ml/min 
  
  %% Example of use
  % FMR = get_FMR('Daphnia_magna')
 
  if ~isempty(select(pet))
  WT = read_stat(pet,'Ww_i','T_typical'); Ww_i = WT(:,1); T_typ = WT(:,2);
  if ~exist('W','var')
    W = Ww_i; % g, ultimate wet weight
  end
  W = min(W, Ww_i-1e-3);
  if ~exist('T','var')
    T = K2C(T_typ); % C, T_typical
  end
  if ~exist('F','var')
    F = 1; % -, scaled function response
  end
  WD0 = pwd;

    try % entries locally present
      cdEntr(pet);   
      load(['results_', pet, '.mat'],'par','metaPar'); 
    catch % entries not locally present
      results_pet = ['results_', pet, '.mat']; 
      path = [set_path2server, 'add_my_pet/entries/']; % path for results_my_pet.mat files
      if ismac || isunix
        system(['wget -O res.mat ', path, pet, '/', results_pet]);
      else
        system(['powershell wget -O res.mat ', path, pet, '/', results_pet]);
      end
      load('res', 'par', 'metaPar');
    end
    cPar = parscomp_st(par); vars_pull(par); v2struct(par); v2struct(cPar); 
    f = F; % overwrite f, which was lost during load
    TC = tempcorr(C2K(T), C2K(20), T_A); % -, temp correction coefficient
    L = (W/ (1 + f * ome))^(1/3); % cm, struc length
    p_ref = TC * p_Am * L_m^2; % J/d, max assimilation power at max size

    switch metaPar.model
      case {'std', 'stf', 'stx', 'ssj'}
        [l_p, l_b] = get_lp([g k l_T v_Hb v_Hp], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hp]; 
        p_ACSJGRD = p_ref * scaled_power(L, f, pars_power, l_b, l_p);
      case 'sbp' % no growth, no kappa rule after p
        [l_j, l_p, l_b] = get_tj([g; k; l_T; v_Hb; v_Hp-1e-3; v_Hp], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hp]; 
        p_ACSJGRD = p_ref * scaled_power_sbp(L, f, pars_power, l_b, l_p); 
        p_ACSJGRD(3,5) = 0; % p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); 
      case 'abp'% no growth, no kappa rule after p
        [l_j, ~, l_b] = get_lj([g k l_T v_Hb v_Hj v_Hp], f);
        l_p = get_lj([g k l_T v_Hb v_Hp v_Hp+1e-8], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hp, U_Hp+1e-6]; 
        p_ACSJGRD = p_ref * scaled_power_abp(L, f, pars_power, l_b, l_p);
        p_ACSJGRD(3,5) = 0; % p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); 
      case 'abj'
        [l_j, l_p, l_b] = get_lj([g k l_T v_Hb v_Hj v_Hp], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp]; 
        p_ACSJGRD = p_ref * scaled_power_j(L, f, pars_power, l_b, l_j, l_p);
      case 'asj'
        [l_s, l_j, l_p, l_b] = get_ls([g k l_T v_Hb v_Hs v_Hj v_Hp], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v', U_Hb, U_Hs, U_Hj, U_Hp]; 
        p_ACSJGRD = p_ref * scaled_power_s(L, f, pars_power, l_b, l_s, l_j, l_p); 
      case 'hep' % ultimate is here mapped to metam
        [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj_hep([g k v_Hb v_Hp, kap/(1-kap)*E_Rj/E_G], f);
        pars_power = [kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hp, U_Hp+1e-6]; 
        p_ACSJGRD = p_ref * scaled_power_j(L, f, pars_power, l_b, l_p, l_p);
      case 'hax' % ultimate is here mapped to pupation
        v_Rj = kap/ (1 - kap) * E_Rj/ E_G; % -, scaled reprod buffer density at pupation
        pars_tj_hax = [g, k, v_Hb, v_Hp, v_Rj, v_He, kap, kap_V];
        [t_j, t_e, t_p, t_b, l_j, l_e, l_p, l_b, l_i, rho_j, rho_B, u_Ee, info] = get_tj_hax(pars_tj_hax, f);
        pars_power = [kap, kap_V, kap_R, g, k_J, k_M, v, U_Hb, U_Hp, U_He]; 
        p_ACSJGRD = p_ref * scaled_power_hax(L, f, pars_power, l_b, l_p, l_j, l_e, t_j);
      case 'hex' % birth and puberty coincide; ultimate is here mapped to pupation
        pars_tj = [g k v_Hb v_He s_j kap kap_V];
        [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(pars_tj, f);
        pars_power = [kap, kap_V, kap_R, g, k_J, k_M, v, U_Hb, U_He]; 
        p_ACSJGRD = p_ref * scaled_power_hex(L, f, pars_power, l_b, l_j, l_e, t_j);
    end
    J_M = -(n_M\n_O) * eta_O * p_ACSJGRD(:, [1 7 5])';  % mol/d: J_C, J_H, J_O, J_N in rows
    FMR = -J_M(3,:); % mol/d, O2 consumption (positive)

    cd(WD0);
  else
    FMR = NaN;
  end
  end
