%% popStatistics_st
% Computes implied population properties of DEB models
%%
function [stat, txtStat, Hfig_surv, Hfig_stab] = popStatistics_st(model, par, T, F) 
% created 2019/07/08 by Bas Kooijman

%% Syntax
% [stat txtStat] = <../popStatistics_st.m *popStatistics_st*>(model, par, T, f)

%% Description
% Computes quantities that depend on parameters, temperature and food level at population level.
% View results with prt_my_pet_pop, which is a shell around this function.
% The allowed models are: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hex.
% If 4th input is a character string, it should specify a fraction for f in the interval (f_min, 1), i.e. f_min + f * (1 - f_min)
%
% Input
%
% * model: string with name of model
% * par :  structure with primary parameters at reference temperature in time-length-energy frame
% * T:     optional scalar with temperature in Kelvin; default C2K(20)
% * F:     optional scalar scaled functional response (default 1), or character string representing a fraction
% 
% Output
% 
% * stat: structure with statistics (see under remarks) with fields, units and labels
%
%     - f: scaled function response (set by input F)
%     - T: absolute temperature (set by input)
%     - TC: temperature correction factor
%
%     for with and without thinning, at f_min, f and f_max
%     - f:  scaled functional response
%     - r:  population growth rate
%     - t2: population doubling time
%     - S_b: survivor probability at birth
%     - S_p: survivor probability at puberty
%     - theta_jn: fraction of post-natals that is juvenile
%     - theta_e: fraction of individuals that is embryo
%     - del_ea: number of embryos per adult
%     - ER: mean reproduction rate of adults
%     - EL_n: mean structural length of post-natals
%     - EL2_n: mean squared structural length of post-natals
%     - EL3_n: mean cubed structural length of post-natals
%     - EL_a: mean structural length of adults
%     - EL2_a: mean squared structural length of adults
%     - EL3_a: mean cubed structural length of adults
%     - EWw_n: mean wet weight of post-natals
%     - EWw_a: mean wet weight of adults
%     - hWw_n: post-natal spec production of dead post-natals
%     - Ep_A: mean assimilation energy of post-natals
%     - EJ_X: mean ingestion rate of wet food by post-natals
%     - EJ_P: mean production rate of wet feces by post-natals
%
% * txtStat: structure with temp, fresp, units, labels for stat

%% Remarks
% Assumes that parameters are given in standard units (d, cm, mol, J, K); this is not checked!
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
% The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref
%
% For required model-specific fields, see <get_parfields.html *get_parfields*>.

%% Example of use
% load('results_species.mat'); [stat, txtStat] = popStatistics_st(metaPar.model, par); printstat_st(stat, txtStat)

  
  choices = {'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hex'};
  if ~any(strcmp(model,choices))
    fprintf('warning statistics_st: invalid model key \n')
    stat = []; txtStat = [];
    return;
  end    
     
  if ~exist('T', 'var') || isempty(T)
    T = C2K(20);   % K, body temperature
  end
 
  if ~exist('F', 'var') || isempty(F) || ( ~ischar(F) && F == 1) % overwrite f in par
    par.f = 1; n_fVal = 2;
  else
    par.f = F; n_fVal = 3;
  end
  
  if ~isfield(par, 'h_B0b')
    par.h_B0b = 0;
  end
  if ~isfield(par, 'h_Bbp')
    par.h_Bbp = 0;
  end
  if ~isfield(par, 'h_Bpi')
    par.h_Bpi = 0;
  end

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);  
  
  if any(ismember({'z_m','E_Hpm'},fieldnames(par)))
    male = 1; % male and females parameters differ
  else
    male = 0; % male and females parameters are the same
  end

  % temperature correction
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  pT_Am = TC * p_Am; vT = TC * v; kT_M = TC * k_M; kT_J = TC * k_J;

  % initiate output with f, T, TC, h_B0b, h_Bbp, h_Bpi
  stat.T = K2C(T);        units.T = 'C';       label.T = 'body temperature'; 
  stat.c_T = TC;          units.c_T = '-';     label.c_T = 'temperature correction factor'; 

  txtStat.units = units; % just for exist of function before the end is reached
  txtStat.label = label; % just for exist of function before the end is reached

  switch model
    % var_00 means var for f=f_min and thinning=0; var_11 means var for f=f_max and thinning=1
    % var_00m means var for f=f_min and thinning=0 and male
    % if ischar(F), f_ris0 depends on thinning, but the-in-between-f's are taken the same, corresponding with thinning=1
    
    %% std, stx
    case {'std','stx'}
      par.thinning = 1; 
      % growth
      [f_01, S_b_01, S_p_01, a_b_01, t_p_01, info_01] = f_ris0_std (par, T); t2_01 = NaN; 
      if info_01 == 0
        EL_01=NaN; EL2_01=NaN; EL3_01=NaN; EL_a_01=NaN; EL2_a_01=NaN; EL3_a_01=NaN; EWw_n_01=NaN; EWw_a_01=NaN; hWw_n_01=NaN; theta_jn_01=NaN; 
        S_p_01=NaN; tS_01=[NaN NaN]; tSs_01=[NaN NaN];
      else
        [EL_01, EL2_01, EL3_01, EL_a_01, EL2_a_01, EL3_a_01, EWw_n_01, EWw_a_01, hWw_n_01, theta_jn_01, S_p_01, tS_01, tSs_01] = ssd_std(par, T, f_01, 0);
      end 
      if n_fVal == 3
        if ischar(F)
          f_f1 = str2double(F);
          if f_f1 < 0 || f_f1 > 1
            fprintf(['Warning from popStatistics_st: specified f = ', num2str(f_f1), ' is outside the interval (0,1)\n']);
            return
          end
          f_f1 = f_01 + f_f1 * (1 - f_01); % -, scaled function response
        else
          f_f1 = F;
        end
        if f_f1 < f_01
          fprintf(['Warning from popStatistics_st: specified f = ', num2str(f_f1), ' is smaller than minimum value ', num2str(f_01), '\n']);
          return
        end
        if isnan(f_f1)
          r_f1=NaN; t2_f1=NaN; S_b_f1=NaN; S_p_f1=NaN; a_b_f1=NaN; t_p_f1=NaN; info_f1 = 0;
          EL_f1=NaN; EL2_f1=NaN; EL3_f1=NaN; EL_a_f1=NaN; EL2_a_f1=NaN; EL3_a_f1=NaN; EWw_n_f1=NaN; EWw_a_f1=NaN; hWw_n_f1=NaN; theta_jn_f1=NaN; 
          S_p_f1=NaN; tS_f1=[NaN NaN]; tSs_f1=[NaN NaN];
        else
          [r_f1, S_b_f1, S_p_f1, a_b_f1, t_p_f1, info_f1] = sgr_std (par, T, f_f1); t2_f1 = (log(2))/ r_f1;
        end
        if info_f1 == 0
          EL_f1=NaN; EL2_f1=NaN; EL3_f1=NaN; EL_a_f1=NaN; EL2_a_f1=NaN; EL3_a_f1=NaN; EWw_n_f1=NaN; EWw_a_f1=NaN; hWw_n_f1=NaN; theta_jn_f1=NaN; 
          S_p_f1=NaN; tS_f1=[NaN NaN]; tSs_f1=[NaN NaN];
        else
          [EL_f1, EL2_f1, EL3_f1, EL_a_f1, EL2_a_f1, EL3_a_f1, EWw_n_f1, EWw_a_f1, hWw_n_f1, theta_jn_f1, S_p_f1, tS_f1, tSs_f1] = ssd_std(par, T, f_f1, r_f1);
        end
      end
      [r_11, S_b_11, S_p_11, a_b_11, t_p_11, info_11] = sgr_std (par, T, 1); t2_11 = (log(2))/ r_11;
      if info_11 == 0
        EL_11=NaN; EL2_11=NaN; EL3_11=NaN; EL_a_11=NaN; EL2_a_11=NaN; EL3_a_11=NaN; EWw_n_11=NaN; EWw_a_11=NaN; hWw_n_11=NaN; theta_jn_11=NaN; 
        S_p_11=NaN; tS_11=[NaN NaN]; tSs_11=[NaN NaN];
      else
        [EL_11, EL2_11, EL3_11, EL_a_11, EL2_a_11, EL3_a_11, EWw_n_11, EWw_a_11, hWw_n_11, theta_jn_11, S_p_11, tS_11, tSs_11] = ssd_std(par, T, 1, r_11);
      end
      
      if isnan(f_01)
        ER_01=NaN; del_ea_01=NaN; theta_e_01=NaN;
      else
      % reproduction
      p_C = f_01 * g/ (f_01 + g) * E_m * (vT * EL2_a_01 + kT_M * (EL3_a_01 + L_T * EL2_a_01)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(f_01, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_01 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adult female
      del_ea_01 = ER_01 * a_b_01 * exp(h_B0b * a_b_01/ 2); % -, number of embryos per adult
      theta_e_01 = del_ea_01/ (del_ea_01 + 1/ (1 - theta_jn_01)); % -, fraction of individuals that is embryo
      end
      if n_fVal == 3
        p_C = f_f1 * g/ (f_f1 + g) * E_m * (vT * EL2_a_f1 + kT_M * (EL3_a_f1 + L_T * EL2_a_f1)); % J/d, mean mobilisation of adults
        p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
        if isnan(f_f1)
          ER_f1=NaN; del_ea_f1=NaN; theta_e_f1=NaN;
        else
        E_0 = p_Am * initial_scaled_reserve(f_f1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
        ER_f1 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
        del_ea_f1 = ER_f1 * a_b_f1 * exp(h_B0b * a_b_f1/ 2); % -, number of embryos per adult
        theta_e_f1 = del_ea_f1/ (del_ea_f1 + 1/ (1 - theta_jn_f1)); % -, fraction of individuals that is embryo
        end
      end
      p_C = g/ (1 + g) * E_m * (vT * EL2_a_11 + kT_M * (EL3_a_11 + L_T * EL2_a_11)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_11 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
      del_ea_11 = ER_11 * a_b_11 * exp(h_B0b * a_b_11/ 2); % -, number of embryos per adult
      theta_e_11 = del_ea_11/ (del_ea_11 + 1/ (1 - theta_jn_11)); % -, fraction of individuals that is embryo

      % food/feces
      Ep_A_01 = EL2_01 * pT_Am * f_01; EJ_X_01 = Ep_A_01/ kap_X/ mu_X * w_X/ d_X; EJ_P_01 = Ep_A_01/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if n_fVal == 3
        Ep_A_f1 = EL2_f1 * pT_Am * f_f1; EJ_X_f1 = Ep_A_f1/ kap_X/ mu_X * w_X/ d_X; EJ_P_f1 = Ep_A_f1/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_11 = EL2_11 * pT_Am; EJ_X_11 = Ep_A_11/ kap_X/ mu_X * w_X/ d_X; EJ_P_11 = Ep_A_11/ kap_X * kap_P/ mu_P * w_P/ d_P;
      
      par.thinning = 0;
      % growth
      [f_00, S_b_00, S_p_00, a_b_00, t_p_00, info_00] = f_ris0_std (par, T); t2_00 = NaN;
      if info_00 == 0
        EL_00=NaN; EL2_00=NaN; EL3_00=NaN; EL_a_00=NaN; EL2_a_00=NaN; EL3_a_00=NaN; EWw_n_00=NaN; EWw_a_00=NaN; hWw_n_00=NaN; theta_jn_00=NaN; 
        S_p_00=NaN; tS_00=[NaN NaN]; tSs_00=[NaN NaN];
      else
        [EL_00, EL2_00, EL3_00, EL_a_00, EL2_a_00, EL3_a_00, EWw_n_00, EWw_a_00, hWw_n_00, theta_jn_00, S_p_00, tS_00, tSs_00] = ssd_std(par, T, f_00, 0);
      end
      if n_fVal == 3
        if ischar(F) && ~isnan(f_f1)
          f_f0 = f_f1; % f_00 + str2double(F) * (1 - f_00); % -, scaled function response
        elseif ischar(F)
          f_f0 = f_00 + str2double(F) * (1 - f_00); % -, scaled function response
        else
          f_f0 = F;
        end
        if isnan(f_f0)
          r_f0=NaN; t2_f0=NaN; S_b_f0=NaN; S_p_f0=NaN; a_b_f0=NaN; t_p_f0=NaN; info_f0 = 0;
          EL_f0=NaN; EL2_f0=NaN; EL3_f0=NaN; EL_a_f0=NaN; EL2_a_f0=NaN; EL3_a_f0=NaN; EWw_n_f0=NaN; EWw_a_f0=NaN; hWw_n_f0=NaN; theta_jn_f0=NaN; 
          S_p_f0=NaN; tS_f0=[NaN NaN]; tSs_f0=[NaN NaN];
        else
          [r_f0, S_b_f0, S_p_f0, a_b_f0, t_p_f0, info_f0] = sgr_std (par, T, f_f0); t2_f0 = (log(2))/ r_f0;
        end
        if info_f0 == 0
          EL_f0=NaN; EL2_f0=NaN; EL3_f0=NaN; EL_a_f0=NaN; EL2_a_f0=NaN; EL3_a_f0=NaN; EWw_n_f0=NaN; EWw_a_f0=NaN; hWw_n_f0=NaN; theta_jn_f0=NaN; 
          S_p_f0=NaN; tS_f0=[NaN NaN]; tSs_f0=[NaN NaN];
        else
          [EL_f0, EL2_f0, EL3_f0, EL_a_f0, EL2_a_f0, EL3_a_f0, EWw_n_f0, EWw_a_f0, hWw_n_f0, theta_jn_f0, S_p_f0, tS_f0, tSs_f0] = ssd_std(par, T, f_f0, r_f0);
        end
      end
      [r_10, S_b_10, S_p_10, a_b_10, t_p_10, info_10] = sgr_std (par, T, 1); t2_10 = (log(2))/ r_10;
      if info_10 == 0
        EL_10=NaN; EL2_10=NaN; EL3_10=NaN; EL_a_10=NaN; EL2_a_10=NaN; EL3_a_10=NaN; EWw_n_10=NaN; EWw_a_10=NaN; hWw_n_10=NaN; theta_jn_10=NaN; S_p_10=NaN; tS_10=NaN; tSs_10=NaN;
      else
        [EL_10, EL2_10, EL3_10, EL_a_10, EL2_a_10, EL3_a_10, EWw_n_10, EWw_a_10, hWw_n_10, theta_jn_10, S_p_10, tS_10, tSs_10] = ssd_std(par, T, 1, r_10);
      end
      
      % reproduction
      p_C = f_00 * g/ (f_00 + g) * E_m * (vT * EL2_a_00 + kT_M * (EL3_a_00 + L_T * EL2_a_00)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(f_00, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_00 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adult female
      del_ea_00 = ER_00 * a_b_00 * exp(h_B0b * a_b_00/ 2); % -, number of embryos per adult
      theta_e_00 = del_ea_00/ (del_ea_00 + 1/ (1 - theta_jn_00)); % -, fraction of individuals that is embryo
      if n_fVal == 3
        p_C = f_f0 * g/ (f_f0 + g) * E_m * (vT * EL2_a_f0 + kT_M * (EL3_a_f0 + L_T * EL2_a_f0)); % J/d, mean mobilisation of adults
        p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
        if isnan(f_f0)
           ER_f0=NaN; del_ea_f0=NaN; theta_e_f0=NaN;
        else
        E_0 = p_Am * initial_scaled_reserve(f_f0, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
        ER_f0 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
        del_ea_f0 = ER_f0 * a_b_f0 * exp(h_B0b * a_b_f0/ 2); % -, number of embryos per adult
        theta_e_f0 = del_ea_f0/ (del_ea_f0 + 1/ (1 - theta_jn_f0));
        end
      end
      p_C = g/ (1 + g) * E_m * (vT * EL2_a_10 + kT_M * (EL3_a_10 + L_T * EL2_a_10)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_10 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adult female
      del_ea_10 = ER_10 * a_b_10 * exp(h_B0b * a_b_10/ 2); % -, number of embryos per adult
      theta_e_10 = del_ea_10/ (del_ea_10 + 1/ (1 - theta_jn_10)); % -, fraction of individuals that is embryo

      % food/feces
      Ep_A_00 = EL2_00 * pT_Am * f_00; EJ_X_00 = Ep_A_00/ kap_X/ mu_X * w_X/ d_X; EJ_P_00 = Ep_A_00/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if ~(n_fVal == 2)
        Ep_A_f0 = EL2_f0 * pT_Am * f_f0; EJ_X_f0 = Ep_A_f0/ kap_X/ mu_X * w_X/ d_X; EJ_P_f0 = Ep_A_f0/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_10 = EL2_10 * pT_Am; EJ_X_10 = Ep_A_10/ kap_X/ mu_X * w_X/ d_X; EJ_P_10 = Ep_A_10/ kap_X * kap_P/ mu_P * w_P/ d_P;
      
      if male % overwrite of par!!!! parameters become male parameters
        if isfield(par,'z_m')
           par.z = par.z_m;
        end
        if isfield(par,'E_Hbm')
           par.E_Hb = par.E_Hbm;
        end
        if isfield(par,'E_Hpm')
           par.E_Hp = par.E_Hpm;
        end
        % unpack par and compute statisitics
        cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);  
      par.thinning = 1; 
      % growth
      [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], f_01); a_b_01m = tau_b/ kT_M; t_p_01m = (tau_p - tau_b)/ kT_M;
      [EL_01m, EL2_01m, EL3_01m, EL_a_01m, EL2_a_01m, EL3_a_01m, EWw_n_01m, EWw_a_01m, hWw_n_01m, theta_jn_01m, S_p_01m] = ssd_std(par, T, f_01, 0);
      if n_fVal == 3
        [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], f_f1); a_b_f1m = tau_b/ kT_M; t_p_f1m = (tau_p - tau_b)/ kT_M;
        [EL_f1m, EL2_f1m, EL3_f1m, EL_a_f1m, EL2_a_f1m, EL3_a_f1m, EWw_n_f1m, EWw_a_f1m, hWw_n_f1m, theta_jn_f1m, S_p_f1m] = ssd_std(par, T, f_f1, r_f1);
      end
      [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], 1); a_b_11m = tau_b/ kT_M; t_p_11m = (tau_p - tau_b)/ kT_M;
      [EL_11m, EL2_11m, EL3_11m, EL_a_11m, EL2_a_11m, EL3_a_11m, EWw_n_11m, EWw_a_11m, hWw_n_11m, theta_jn_11m, S_p_11m] = ssd_std(par, T, 1, r_11);
      

      % food/feces
      Ep_A_01m = EL2_01m * pT_Am * f_01; EJ_X_01m = Ep_A_01m/ kap_X/ mu_X * w_X/ d_X; EJ_P_01m = Ep_A_01m/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if n_fVal == 3
        Ep_A_f1m = EL2_f1m * pT_Am * f_f1; EJ_X_f1m = Ep_A_f1m/ kap_X/ mu_X * w_X/ d_X; EJ_P_f1m = Ep_A_f1m/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_11m = EL2_11m * pT_Am; EJ_X_11m = Ep_A_11m/ kap_X/ mu_X * w_X/ d_X; EJ_P_11m = Ep_A_11m/ kap_X * kap_P/ mu_P * w_P/ d_P;
      
      par.thinning = 0;
      % growth
      [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], f_00); a_b_00m = tau_b/ kT_M; t_p_00m = (tau_p - tau_b)/ kT_M;
      if info_00 == 0
        EL_00m=NaN; EL2_00m=NaN; EL3_00m=NaN; EL_a_00m=NaN; EL2_a_00m=NaN; EL3_a_00m=NaN; EWw_n_00m=NaN; EWw_a_00m=NaN; hWw_n_00m=NaN; theta_jn_00m=NaN; S_p_00m=NaN;
      else
        [EL_00m, EL2_00m, EL3_00m, EL_a_00m, EL2_a_00m, EL3_a_00m, EWw_n_00m, EWw_a_00m, hWw_n_00m, theta_jn_00m, S_p_00m] = ssd_std(par, T, f_00, 0);
      end
      if n_fVal == 3
        if ischar(F)
          f_f0 = f_f1; % f_00 + str2double(F) * (1 - f_00); % -, scaled function response
        else
          f_f0 = F;
        end
        [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], f_f0); a_b_f0m = tau_b/ kT_M; t_p_f0m = (tau_p - tau_b)/ kT_M;
        if info_f0 == 0
          EL_f0m=NaN; EL2_f0m=NaN; EL3_f0m=NaN; EL_a_f0m=NaN; EL2_a_f0m=NaN; EL3_a_f0m=NaN; EWw_n_f0m=NaN; EWw_a_f0m=NaN; hWw_n_f0m=NaN; theta_jn_f0m=NaN; S_p_f0m=NaN;
        else
          [EL_f0m, EL2_f0m, EL3_f0m, EL_a_f0m, EL2_a_f0m, EL3_a_f0m, EWw_n_f0m, EWw_a_f0m, hWw_n_f0m, theta_jn_f0m, S_p_f0m] = ssd_std(par, T, f_f0, r_f0);
        end
      end
     [tau_p, tau_b] = get_tp([g k l_T v_Hb v_Hp], 1); a_b_10m = tau_b/ kT_M; t_p_10m = (tau_p - tau_b)/ kT_M;
     if info_10 == 0
       EL_10m, EL2_10m, EL3_10m, EL_a_10m, EL2_a_10m, EL3_a_10m, EWw_n_10m=NaN; EWw_a_10m=NaN; hWw_n_10m=NaN; theta_jn_10m=NaN; S_p_10m=NaN;
     else
       [EL_10m, EL2_10m, EL3_10m, EL_a_10m, EL2_a_10m, EL3_a_10m, EWw_n_10m, EWw_a_10m, hWw_n_10m, theta_jn_10m, S_p_10m] = ssd_std(par, T, 1, r_10);
     end
      

      % food/feces
      Ep_A_00m = EL2_00m * pT_Am * f_00; EJ_X_00m = Ep_A_00m/ kap_X/ mu_X * w_X/ d_X; EJ_P_00m = Ep_A_00m/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if ~(n_fVal == 2)
        Ep_A_f0m = EL2_f0m * pT_Am * f_f0; EJ_X_f0m = Ep_A_f0m/ kap_X/ mu_X * w_X/ d_X; EJ_P_f0m = Ep_A_f0m/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_10m = EL2_10m * pT_Am; EJ_X_10m = Ep_A_10m/ kap_X/ mu_X * w_X/ d_X; EJ_P_10m = Ep_A_10m/ kap_X * kap_P/ mu_P * w_P/ d_P;
        
      end

    %% stf
    otherwise
      return
            
  end
  
  % add statistics to output structure
  % fill units, label, adding to output structure is done below
  units.f    = '-';      label.f   = 'scaled functional response';
  units.r    = '1/d';    label.r   = 'spec pop growth rate';
  units.t2   = 'd';      label.t2  = 'population doubling time';
  units.S_b  = '-';      label.S_b = 'survival probability at birth';
  units.S_p  = '-';      label.S_p = 'survival probability at puberty';
  units.a_b  = 'd';      label.a_b = 'age at birth';
  units.t_p  = 'd';      label.t_p = 'time since birth at puberty';
  units.theta_jn = '-';  label.theta_jn = 'fraction of post-natals that is juvenile';
  units.theta_e = '-';   label.theta_e = 'fraction of individuals that is embryo';
  units.del_ea = '-';    label.del_ea = 'number of embryos per adult in population';
  units.ER = '1/d';      label.ER  = 'mean reproduction rate per adult female';
  units.EL_n   = 'cm';   label.EL_n   = 'mean structural length of post-natals';
  units.EL2_n  = 'cm^2'; label.EL2_n  = 'mean squared structural length of post-natals';
  units.EL3_n  = 'cm^3'; label.EL3_n  = 'mean cubed structural length of post-natals';
  units.EL_a   = 'cm';   label.EL_a   = 'mean structural length of adults';
  units.EL2_a  = 'cm^2'; label.EL2_a  = 'mean squared structural length of adults';
  units.EL3_a  = 'cm^3'; label.EL3_a  = 'mean cubed structural length of adults';
  units.EWw_n  = 'g';    label.EWw_n     = 'mean wet weight of post-natals';
  units.EWw_a  = 'g';    label.EWw_a  = 'mean wet weight of adults';
  units.hWw_n = 'g/d';   label.hWw_n  = 'post-natal spec production of dead post-natals';
  units.Ep_A = 'J/d';    label.Ep_A = 'mean assimilation energy of post-natals';
  units.EJ_X = 'g/d';    label.EJ_X = 'mean ingestion rate of wet food by post-natals';
  units.EJ_P = 'g/d';    label.EJ_P = 'mean production rate of wet feces by post-natals';
  
  % fill stat for thinning false, true and f = f_min, f, f_max
  stat.f.f0.thin1.f   = f_01;   stat.f.f0.thin0.f   = f_00;   
  stat.r.f0.thin1.f   = 0;      stat.r.f0.thin0.f  = 0;       
  stat.t2.f0.thin1.f  = t2_01;  stat.t2.f0.thin0.f  = t2_00;  
  stat.S_b.f0.thin1.f = S_b_01; stat.S_b.f0.thin0.f = S_b_00; 
  stat.S_p.f0.thin1.f = S_p_01; stat.S_p.f0.thin0.f = S_p_00; 
  stat.a_b.f0.thin1.f = a_b_01; stat.a_b.f0.thin0.f = a_b_00; 
  stat.t_p.f0.thin1.f = t_p_01; stat.t_p.f0.thin0.f = t_p_00; 
  stat.theta_jn.f0.thin1.f = theta_jn_01; stat.theta_jn.f0.thin0.f = theta_jn_00; 
  stat.theta_e.f0.thin1.f = theta_e_01; stat.theta_e.f0.thin0.f = theta_e_00; 
  stat.del_ea.f0.thin1.f  = del_ea_01; stat.del_ea.f0.thin0.f  = del_ea_00;  
  stat.ER.f0.thin1.f     = ER_01;  stat.ER.f0.thin0.f  = ER_00;  
  stat.EL_n.f0.thin1.f   = EL_01;   stat.EL_n.f0.thin0.f   = EL_00;   
  stat.EL2_n.f0.thin1.f  = EL2_01;  stat.EL2_n.f0.thin0.f  = EL2_00;  
  stat.EL3_n.f0.thin1.f  = EL3_01;  stat.EL3_n.f0.thin0.f  = EL3_00;  
  stat.EL_a.f0.thin1.f   = EL_a_01;   stat.EL_a.f0.thin0.f   = EL_a_00;   
  stat.EL2_a.f0.thin1.f  = EL2_a_01;  stat.EL2_a.f0.thin0.f  = EL2_a_00;  
  stat.EL3_a.f0.thin1.f  = EL3_a_01;  stat.EL3_a.f0.thin0.f  = EL3_a_00;  
  stat.EWw_n.f0.thin1.f  = EWw_n_01;  stat.EWw_n.f0.thin0.f  = EWw_n_00;  
  stat.EWw_a.f0.thin1.f  = EWw_a_01;  stat.EWw_a.f0.thin0.f  = EWw_a_00;  
  stat.hWw_n.f0.thin1.f    = hWw_n_01;  stat.hWw_n.f0.thin0.f  = hWw_n_00;  
  stat.Ep_A.f0.thin1.f   = Ep_A_01; stat.Ep_A.f0.thin0.f = Ep_A_00;  
  stat.EJ_X.f0.thin1.f   = EJ_X_01; stat.EJ_X.f0.thin0.f = EJ_X_00;  
  stat.EJ_P.f0.thin1.f   = EJ_P_01; stat.EJ_P.f0.thin0.f = EJ_P_00;  
  %
  if n_fVal == 3
    stat.f.f.thin1.f   = f_f1;   stat.f.f.thin0.f   = f_f0;  
    stat.r.f.thin1.f   = r_f1;   stat.r.f.thin0.f   = r_f0;   
    stat.t2.f.thin1.f  = t2_f1;  stat.t2.f.thin0.f  = t2_f0;   
    stat.S_b.f.thin1.f = S_b_f1; stat.S_b.f.thin0.f = S_b_f0; 
    stat.S_p.f.thin1.f = S_p_f1; stat.S_p.f.thin0.f = S_p_f0; 
    stat.a_b.f.thin1.f = a_b_f1; stat.a_b.f.thin0.f = a_b_f0; 
    stat.t_p.f.thin1.f = t_p_f1; stat.t_p.f.thin0.f = t_p_f0; 
    stat.theta_jn.f.thin1.f = theta_jn_f1; stat.theta_jn.f.thin0.f = theta_jn_f0; 
    stat.theta_e.f.thin1.f = theta_e_f1; stat.theta_e.f.thin0.f = theta_e_f0; 
    stat.del_ea.f.thin1.f  = del_ea_f1; stat.del_ea.f.thin0.f  = del_ea_f0;  
    stat.ER.f.thin1.f  = ER_f1;  stat.ER.f.thin0.f  = ER_f0;  
    stat.EL_n.f.thin1.f   = EL_f1;   stat.EL_n.f.thin0.f   = EL_f0;   
    stat.EL2_n.f.thin1.f  = EL2_f1;  stat.EL2_n.f.thin0.f  = EL2_f0;  
    stat.EL3_n.f.thin1.f  = EL3_f1;  stat.EL3_n.f.thin0.f  = EL3_f0;  
    stat.EL_a.f.thin1.f   = EL_a_f1;   stat.EL_a.f.thin0.f   = EL_a_f0;   
    stat.EL2_a.f.thin1.f  = EL2_a_f1;  stat.EL2_a.f.thin0.f  = EL2_a_f0;  
    stat.EL3_a.f.thin1.f  = EL3_a_f1;  stat.EL3_a.f.thin0.f  = EL3_a_f0;  
    stat.EWw_n.f.thin1.f  = EWw_n_f1;  stat.EWw_n.f.thin0.f  = EWw_n_f0;
    stat.EWw_a.f.thin1.f  = EWw_a_f1;  stat.EWw_a.f.thin0.f  = EWw_a_f0;
    stat.hWw_n.f.thin1.f  = hWw_n_f1;  stat.hWw_n.f.thin0.f  = hWw_n_f0;
    stat.Ep_A.f.thin1.f = Ep_A_f1; stat.Ep_A.f.thin0.f = Ep_A_f0;
    stat.EJ_X.f.thin1.f = EJ_X_f1; stat.EJ_X.f.thin0.f = EJ_X_f0;  
    stat.EJ_P.f.thin1.f = EJ_P_f1; stat.EJ_P.f.thin0.f = EJ_P_f0;  
  end
  %
  stat.f.f1.thin1.f   = 1;      stat.f.f1.thin0.f   = 1;  
  stat.r.f1.thin1.f   = r_11;   stat.r.f1.thin0.f   = r_10;     
  stat.t2.f1.thin1.f  = t2_11;  stat.t2.f1.thin0.f  = t2_10;     
  stat.S_b.f1.thin1.f = S_b_11; stat.S_b.f1.thin0.f = S_b_10; 
  stat.S_p.f1.thin1.f = S_p_11; stat.S_p.f1.thin0.f = S_p_10; 
  stat.a_b.f1.thin1.f = a_b_11; stat.a_b.f1.thin0.f = a_b_10; 
  stat.t_p.f1.thin1.f = t_p_11; stat.t_p.f1.thin0.f = t_p_10; 
  stat.theta_jn.f1.thin1.f = theta_jn_11; stat.theta_jn.f1.thin0.f = theta_jn_10; 
  stat.theta_e.f1.thin1.f = theta_e_11; stat.theta_e.f1.thin0.f = theta_e_10; 
  stat.del_ea.f1.thin1.f  = del_ea_11; stat.del_ea.f1.thin0.f  = del_ea_10;  
  stat.ER.f1.thin1.f  = ER_11;  stat.ER.f1.thin0.f  = ER_10;  
  stat.EL_n.f1.thin1.f   = EL_11;   stat.EL_n.f1.thin0.f   = EL_10;   
  stat.EL2_n.f1.thin1.f  = EL2_11;  stat.EL2_n.f1.thin0.f  = EL2_10;  
  stat.EL3_n.f1.thin1.f  = EL3_11;  stat.EL3_n.f1.thin0.f  = EL3_10;  
  stat.EL_a.f1.thin1.f   = EL_a_11;   stat.EL_a.f1.thin0.f   = EL_a_10;   
  stat.EL2_a.f1.thin1.f  = EL2_a_11;  stat.EL2_a.f1.thin0.f  = EL2_a_10;  
  stat.EL3_a.f1.thin1.f  = EL3_a_11;  stat.EL3_a.f1.thin0.f  = EL3_a_10;  
  stat.EWw_n.f1.thin1.f  = EWw_n_11;  stat.EWw_n.f1.thin0.f  = EWw_n_10;
  stat.EWw_a.f1.thin1.f  = EWw_a_11;  stat.EWw_a.f1.thin0.f  = EWw_a_10;
  stat.hWw_n.f1.thin1.f  = hWw_n_11;  stat.hWw_n.f1.thin0.f  = hWw_n_10;
  stat.Ep_A.f1.thin1.f = Ep_A_11; stat.Ep_A.f1.thin0.f = Ep_A_10;
  stat.EJ_X.f1.thin1.f = EJ_X_11; stat.EJ_X.f1.thin0.f = EJ_X_10;  
  stat.EJ_P.f1.thin1.f = EJ_P_11; stat.EJ_P.f1.thin0.f = EJ_P_10;  

  if male % parameters of male differ from female
  % fill stat for thinning false, true and f = f_min, f, f_max
  stat.f.f0.thin1.m   = f_01;   stat.f.f0.thin0.m   = f_00;   
  stat.r.f0.thin1.m   = 0;      stat.r.f0.thin0.m  = 0;       
  stat.t2.f0.thin1.m  = t2_01;  stat.t2.f0.thin0.m  = t2_00;  
  stat.S_b.f0.thin1.m = S_b_01; stat.S_b.f0.thin0.m = S_b_00; 
  stat.S_p.f0.thin1.m = S_p_01m; stat.S_p.f0.thin0.m = S_p_00m; 
  stat.a_b.f0.thin1.m = a_b_01m; stat.a_b.f0.thin0.m = a_b_00m; 
  stat.t_p.f0.thin1.m = t_p_01m; stat.t_p.f0.thin0.m = t_p_00m; 
  stat.theta_jn.f0.thin1.m = theta_jn_01m; stat.theta_jn.f0.thin0.m = theta_jn_00m; 
  stat.theta_e.f0.thin1.m = theta_e_01; stat.theta_e.f0.thin0.m = theta_e_00; 
  stat.del_ea.f0.thin1.m  = del_ea_01; stat.del_ea.f0.thin0.m  = del_ea_00;  
  stat.ER.f0.thin1.m     = [];  stat.ER.f0.thin0.m  = [];  
  stat.EL_n.f0.thin1.m   = EL_01m;   stat.EL_n.f0.thin0.m   = EL_00m;   
  stat.EL2_n.f0.thin1.m  = EL2_01m;  stat.EL2_n.f0.thin0.m  = EL2_00m;  
  stat.EL3_n.f0.thin1.m  = EL3_01m;  stat.EL3_n.f0.thin0.m  = EL3_00m;  
  stat.EL_a.f0.thin1.m   = EL_a_01m;   stat.EL_a.f0.thin0.m   = EL_a_00m;   
  stat.EL2_a.f0.thin1.m  = EL2_a_01m;  stat.EL2_a.f0.thin0.m  = EL2_a_00m;  
  stat.EL3_a.f0.thin1.m  = EL3_a_01m;  stat.EL3_a.f0.thin0.m  = EL3_a_00m;  
  stat.EWw_n.f0.thin1.m  = EWw_n_01m;  stat.EWw_n.f0.thin0.m  = EWw_n_00m;  
  stat.EWw_a.f0.thin1.m  = EWw_a_01m;  stat.EWw_a.f0.thin0.m  = EWw_a_00m;  
  stat.hWw_n.f0.thin1.m  = hWw_n_01m;  stat.hWw_n.f0.thin0.m  = hWw_n_00m;  
  stat.Ep_A.f0.thin1.m   = Ep_A_01m; stat.Ep_A.f0.thin0.m = Ep_A_00m;  
  stat.EJ_X.f0.thin1.m   = EJ_X_01m; stat.EJ_X.f0.thin0.m = EJ_X_00m;  
  stat.EJ_P.f0.thin1.m   = EJ_P_01m; stat.EJ_P.f0.thin0.m = EJ_P_00m;  
  %
  if n_fVal == 3
    stat.f.f.thin1.m   = f_f1;   stat.f.f.thin0.m   = f_f0;  
    stat.r.f.thin1.m   = r_f1;   stat.r.f.thin0.m   = r_f0;   
    stat.t2.f.thin1.m  = t2_f1;  stat.t2.f.thin0.m  = t2_f0;   
    stat.S_b.f.thin1.m = S_b_f1; stat.S_b.f.thin0.m = S_b_f0; 
    stat.S_p.f.thin1.m = S_p_f1m; stat.S_p.f.thin0.m = S_p_f0m; 
    stat.a_b.f.thin1.m = a_b_f1m; stat.a_b.f.thin0.m = a_b_f0m; 
    stat.t_p.f.thin1.m = t_p_f1m; stat.t_p.f.thin0.m = t_p_f0m; 
    stat.theta_jn.f.thin1.m = theta_jn_f1m; stat.theta_jn.f.thin0.m = theta_jn_f0m; 
    stat.theta_e.f.thin1.m = theta_e_f1; stat.theta_e.f.thin0.m = theta_e_f0; 
    stat.del_ea.f.thin1.m  = del_ea_f1; stat.del_ea.f.thin0.m  = del_ea_f0;  
    stat.ER.f.thin1.m  = [];  stat.ER.f.thin0.m  = [];  
    stat.EL_n.f.thin1.m   = EL_f1m;   stat.EL_n.f.thin0.m   = EL_f0m;   
    stat.EL2_n.f.thin1.m  = EL2_f1m;  stat.EL2_n.f.thin0.m  = EL2_f0m;  
    stat.EL3_n.f.thin1.m  = EL3_f1m;  stat.EL3_n.f.thin0.m  = EL3_f0m;  
    stat.EL_a.f.thin1.m   = EL_a_f1m;   stat.EL_a.f.thin0.m   = EL_a_f0m;   
    stat.EL2_a.f.thin1.m  = EL2_a_f1m;  stat.EL2_a.f.thin0.m  = EL2_a_f0m;  
    stat.EL3_a.f.thin1.m  = EL3_a_f1m;  stat.EL3_a.f.thin0.m  = EL3_a_f0m;  
    stat.EWw_n.f.thin1.m  = EWw_n_f1m;  stat.EWw_n.f.thin0.m  = EWw_n_f0m;
    stat.EWw_a.f.thin1.m  = EWw_a_f1m;  stat.EWw_a.f.thin0.m  = EWw_a_f0m;
    stat.hWw_n.f.thin1.m  = hWw_n_f1m;  stat.hWw_n.f.thin0.m  = hWw_n_f0m;
    stat.Ep_A.f.thin1.m = Ep_A_f1m; stat.Ep_A.f.thin0.m = Ep_A_f0m;
    stat.EJ_X.f.thin1.m = EJ_X_f1m; stat.EJ_X.f.thin0.m = EJ_X_f0m;  
    stat.EJ_P.f.thin1.m = EJ_P_f1m; stat.EJ_P.f.thin0.m = EJ_P_f0m;  
  end
  %
  stat.f.f1.thin1.m   = 1;      stat.f.f1.thin0.m   = 1;  
  stat.r.f1.thin1.m   = r_11;   stat.r.f1.thin0.m   = r_10;     
  stat.t2.f1.thin1.m  = t2_11;  stat.t2.f1.thin0.m  = t2_10;     
  stat.S_b.f1.thin1.m = S_b_11; stat.S_b.f1.thin0.m = S_b_10; 
  stat.S_p.f1.thin1.m = S_p_11m; stat.S_p.f1.thin0.m = S_p_10m; 
  stat.a_b.f1.thin1.m = a_b_11m; stat.a_b.f1.thin0.m = a_b_10m; 
  stat.t_p.f1.thin1.m = t_p_11m; stat.t_p.f1.thin0.m = t_p_10m; 
  stat.theta_jn.f1.thin1.m = theta_jn_11m; stat.theta_jn.f1.thin0.m = theta_jn_10m; 
  stat.theta_e.f1.thin1.m = theta_e_11; stat.theta_e.f1.thin0.m = theta_e_10; 
  stat.del_ea.f1.thin1.m  = del_ea_11; stat.del_ea.f1.thin0.m  = del_ea_10;  
  stat.ER.f1.thin1.m  = [];  stat.ER.f1.thin0.m  = [];  
  stat.EL_n.f1.thin1.m   = EL_11m;   stat.EL_n.f1.thin0.m   = EL_10m;   
  stat.EL2_n.f1.thin1.m  = EL2_11m;  stat.EL2_n.f1.thin0.m  = EL2_10m;  
  stat.EL3_n.f1.thin1.m  = EL3_11m;  stat.EL3_n.f1.thin0.m  = EL3_10m;  
  stat.EL_a.f1.thin1.m   = EL_a_11m;   stat.EL_a.f1.thin0.m   = EL_a_10m;   
  stat.EL2_a.f1.thin1.m  = EL2_a_11m;  stat.EL2_a.f1.thin0.m  = EL2_a_10m;  
  stat.EL3_a.f1.thin1.m  = EL3_a_11m;  stat.EL3_a.f1.thin0.m  = EL3_a_10m;  
  stat.EWw_n.f1.thin1.m  = EWw_n_11m;  stat.EWw_n.f1.thin0.m  = EWw_n_10m;
  stat.EWw_a.f1.thin1.m  = EWw_a_11m;  stat.EWw_a.f1.thin0.m  = EWw_a_10m;
  stat.hWw_n.f1.thin1.m  = hWw_n_11m;  stat.hWw_n.f1.thin0.m  = hWw_n_10m;
  stat.Ep_A.f1.thin1.m = Ep_A_11m; stat.Ep_A.f1.thin0.m = Ep_A_10m;
  stat.EJ_X.f1.thin1.m = EJ_X_11m; stat.EJ_X.f1.thin0.m = EJ_X_10m;  
  stat.EJ_P.f1.thin1.m = EJ_P_11m; stat.EJ_P.f1.thin0.m = EJ_P_10m;  
  end

  % packing to output
  txtStat.units = units;
  txtStat.label = label;

  % graphics
 
  Hfig_surv = figure(1); % survivor prob
  if n_fVal == 2
    plot(tS_10(:,1), log(tS_10(:,2)), 'r', ...
         tS_00(:,1), log(tS_00(:,2)), 'b', ...
         tS_11(:,1), log(tS_11(:,2)), '-.r',  ...
         tS_01(:,1), log(tS_01(:,2)), '-.b', ...
         'Linewidth', 2)
  else % n_fVal == 3
    plot(tS_10(:,1), log(tS_10(:,2)), 'r', ...
         tS_f0(:,1), log(tS_f0(:,2)), 'm', ...
         tS_00(:,1), log(tS_00(:,2)), 'b', ...
         tS_11(:,1), log(tS_11(:,2)), '-.r',  ...
         tS_f1(:,1), log(tS_f1(:,2)), '-.m',  ...
         tS_01(:,1), log(tS_01(:,2)), '-.b', ...
         'Linewidth', 2)
  end
  xlabel('age, d'); ylabel('ln survival probability');
  set(gca, 'FontSize', 15, 'Box', 'on');

  Hfig_stab = figure(2); % stable age distribution
  if n_fVal == 2
    plot(tS_10(:,1), log(tSs_10(:,2)), 'r', ...
         tS_00(:,1), log(tSs_00(:,2)), 'b', ...
         tS_11(:,1), log(tSs_11(:,2)), '-.r',  ...
         tS_01(:,1), log(tSs_01(:,2)), '-.b', ...
         'Linewidth', 2)
  else % n_fVal == 3
    plot(tS_10(:,1), log(tSs_10(:,2)), 'r', ...
         tS_f0(:,1), log(tSs_f0(:,2)), 'm', ...
         tS_00(:,1), log(tSs_00(:,2)), 'b', ...
         tS_11(:,1), log(tSs_11(:,2)), '-.r',  ...
         tS_f1(:,1), log(tSs_f1(:,2)), '-.m',  ...
         tS_01(:,1), log(tSs_01(:,2)), '-.b', ...
         'Linewidth', 2)
  end
  xlabel('age, d'); ylabel('ln survivor fn of stable age distr');
  set(gca, 'FontSize', 15, 'Box', 'on');


