%% popStatistics_st
% Computes implied properties of DEB models at population level

%%
function [stat, txtStat, Hfig_surv, Hfig_stab] = popStatistics_st(model, par, T, F) 
% created 2019/07/08 by Bas Kooijman

%% Syntax
% [stat txtStat] = <../popStatistics_st.m *popStatistics_st*>(model, par, T, f)

%% Description
% Computes quantites that depend on parameters, temperature and food level at population level.
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
% Buffer handling rules are species-specific, so ultimate reproduction rate Ri not always makes sense.
% Fermentation is supposed not to occur and dioxygen availability is assumed to be unlimiting.
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
% The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref
% The output values are for females; males might have deviating parameters, which are frequently also available.
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
  
  if ~isfield('par', 'h_B0b')
    par.h_B0b = 0;
  end
  if ~isfield('par', 'h_Bbp')
    par.h_Bbp = 0;
  end
  if ~isfield('par', 'h_Bpi')
    par.h_Bpi = 0;
  end

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);  


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
  stat.h_B0b = par.h_B0b; units.h_B0b = '1/d'; label.h_B0b = 'background hazard for embryo'; 
  stat.h_Bbp = par.h_Bbp; units.h_Bbp = '1/d'; label.h_Bbp = 'background hazard for juvenile'; 
  stat.h_Bpi = par.h_Bpi; units.h_Bpi = '1/d'; label.h_Bpi = 'background hazard for adult';    

  txtStat.units = units; % just for exist of function before the end is reached
  txtStat.label = label; % just for exist of function before the end is reached

  switch model
    % var_00 means var for f=f_min and thinning=0; var_11 means var for f=f_max and thinning=1
    case {'std','stx'}
      % r and f_0
      par.thinning = 1; 
      [f_01, S_b_01, S_p_01, info] = f_ris0_std_r (par); t2_01 = NaN;        
      [EL_01, EL2_01, EL3_01, EL_a_01, EL2_a_01, EL3_a_01, EWw_n_01, EWw_a_01, hWw_n_01, theta_jn_01, tS_01, tSs_01] = ssd_std(par, [], f_01, 0);
      if ~(n_fVal == 2)
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
        [r_f1, S_b_f1, S_p_f1] = sgr_std (par, T, f_f1); t2_f1 = (log(2))/ r_f1;
        [EL_f1, EL2_f1, EL3_f1, EL_a_f1, EL2_a_f1, EL3_a_f1, EWw_n_f1, EWw_a_f1, hWw_n_f1, theta_jn_f1, tS_f1, tSs_f1] = ssd_std(par, [], f_f1, r_f1);
      end
      [r_11, S_b_11, S_p_11] = sgr_std (par, T, 1); t2_11 = (log(2))/ r_11;
      [EL_11, EL2_11, EL3_11, EL_a_11, EL2_a_11, EL3_a_11, EWw_n_11, EWw_a_11, hWw_n_11, theta_jn_11, tS_11, tSs_11] = ssd_std(par, [], 1, r_11);
      
      % reproduction
      p_C = f_01 * g/ (f_01 + g) * E_m * (vT * EL2_a_01 + kT_M * (EL3_a_01 + L_T * EL2_a_01)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(f_01, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_01 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
      aT_b = get_tb([g, k, v_Hb], f_01)/ kT_M; del_ea_01 = ER_01 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
      theta_e_01 = del_ea_01/ (del_ea_01 + 1/ (1 - theta_jn_01)); % -, fraction of individuals that is embryo
      if ~(n_fVal == 2)
        p_C = f_f1 * g/ (f_f1 + g) * E_m * (vT * EL2_a_f1 + kT_M * (EL3_a_f1 + L_T * EL2_a_f1)); % J/d, mean mobilisation of adults
        p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
        E_0 = p_Am * initial_scaled_reserve(f_f1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
        ER_f1 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
        aT_b = get_tb([g, k, v_Hb], f_f1)/ kT_M; del_ea_f1 = ER_f1 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
        theta_e_f1 = del_ea_f1/ (del_ea_f1 + 1/ (1 - theta_jn_f1)); % -, fraction of individuals that is embryo
      end
      p_C = g/ (1 + g) * E_m * (vT * EL2_a_11 + kT_M * (EL3_a_11 + L_T * EL2_a_11)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_11 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
      aT_b = get_tb([g, k, v_Hb], 1)/ kT_M; del_ea_11 = ER_11 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
      theta_e_11 = del_ea_11/ (del_ea_11 + 1/ (1 - theta_jn_11)); % -, fraction of individuals that is embryo

      % assimilation power
      Ep_A_01 = EL2_01 * pT_Am * f_01; EJ_X_01 = Ep_A_01/ kap_X/ mu_X * w_X/ d_X; EJ_P_01 = Ep_A_01/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if ~(n_fVal == 2)
        Ep_A_f1 = EL2_f1 * pT_Am * f_f1; EJ_X_f1 = Ep_A_f1/ kap_X/ mu_X * w_X/ d_X; EJ_P_f1 = Ep_A_f1/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_11 = EL2_11 * pT_Am; EJ_X_11 = Ep_A_11/ kap_X/ mu_X * w_X/ d_X; EJ_P_11 = Ep_A_11/ kap_X * kap_P/ mu_P * w_P/ d_P;
      
      par.thinning = 0;
      [f_00, S_b_00, S_p_00] = f_ris0_std_r (par); t2_00 = NaN;
      [EL_00, EL2_00, EL3_00, EL_a_00, EL2_a_00, EL3_a_00, EWw_n_00, EWw_a_00, hWw_n_00, theta_jn_00, tS_00, tSs_00] = ssd_std(par, [], f_00, 0);
      if ~(n_fVal == 2)
        if ischar(F)
          f_f0 = f_f1; % f_00 + str2double(F) * (1 - f_00); % -, scaled function response
        else
          f_f0 = F;
        end
        [r_f0, S_b_f0, S_p_f0] = sgr_std (par, T, f_f0); t2_f0 = (log(2))/ r_f0;
        [EL_f0, EL2_f0, EL3_f0, EL_a_f0, EL2_a_f0, EL3_a_f0, EWw_n_f0, EWw_a_f0, hWw_n_f0, theta_jn_f0, tS_f0, tSs_f0] = ssd_std(par, [], f_f0, r_f0);
      end
      [r_10, S_b_10, S_p_10] = sgr_std (par, T, 1); t2_10 = (log(2))/ r_10;
      [EL_10, EL2_10, EL3_10, EL_a_10, EL2_a_10, EL3_a_10, EWw_n_10, EWw_a_10, hWw_n_10, theta_jn_10, tS_10, tSs_10] = ssd_std(par, [], 1, r_10);
      
      % reproduction
      p_C = f_00 * g/ (f_00 + g) * E_m * (vT * EL2_a_00 + kT_M * (EL3_a_00 + L_T * EL2_a_00)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(f_00, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_00 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
      aT_b = get_tb([g, k, v_Hb], f_00)/ kT_M; del_ea_00 = ER_00 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
      theta_e_00 = del_ea_00/ (del_ea_00 + 1/ (1 - theta_jn_00)); % -, fraction of individuals that is embryo
      if ~(n_fVal == 2)
        p_C = f_f0 * g/ (f_f0 + g) * E_m * (vT * EL2_a_f0 + kT_M * (EL3_a_f0 + L_T * EL2_a_f0)); % J/d, mean mobilisation of adults
        p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
        E_0 = p_Am * initial_scaled_reserve(f_f0, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
        ER_f0 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
        aT_b = get_tb([g, k, v_Hb], f_f0)/ kT_M; del_ea_f0 = ER_f0 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
        theta_e_f0 = del_ea_f0/ (del_ea_f0 + 1/ (1 - theta_jn_f0));
      end
      p_C = g/ (1 + g) * E_m * (vT * EL2_a_10 + kT_M * (EL3_a_10 + L_T * EL2_a_10)); % J/d, mean mobilisation of adults
      p_R = (1 - kap) * p_C - kT_J * E_Hp; % J/d, mean allocation to reproduction of adults
      E_0 = p_Am * initial_scaled_reserve(1, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
      ER_10 = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adults
      aT_b = get_tb([g, k, v_Hb], 1)/ kT_M; del_ea_10 = ER_10 * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
      theta_e_10 = del_ea_10/ (del_ea_10 + 1/ (1 - theta_jn_10)); % -, fraction of individuals that is embryo

      % powers
      Ep_A_00 = EL2_00 * pT_Am * f_00; EJ_X_00 = Ep_A_00/ kap_X/ mu_X * w_X/ d_X; EJ_P_00 = Ep_A_00/ kap_X * kap_P/ mu_P * w_P/ d_P;
      if ~(n_fVal == 2)
        Ep_A_f0 = EL2_f0 * pT_Am * f_f0; EJ_X_f0 = Ep_A_f0/ kap_X/ mu_X * w_X/ d_X; EJ_P_f0 = Ep_A_f0/ kap_X * kap_P/ mu_P * w_P/ d_P;
      end
      Ep_A_10 = EL2_10 * pT_Am; EJ_X_10 = Ep_A_10/ kap_X/ mu_X * w_X/ d_X; EJ_P_10 = Ep_A_10/ kap_X * kap_P/ mu_P * w_P/ d_P;

    otherwise
      return
            
  end
  
  % fill units, label
  units.f    = '-';      label.f   = 'scaled functional response';
  units.r    = '1/d';    label.r   = 'spec pop growth rate';
  units.t2   = 'd';      label.t2  = 'population doubling time';
  units.S_b  = '-';      label.S_b = 'survival probability at birth';
  units.S_p  = '-';      label.S_p = 'survival probability at puberty';
  units.theta_jn = '-';  label.theta_jn = 'fraction of post-natals that is juvenile';
  units.theta_e = '-';   label.theta_e = 'fraction of individuals that is embryo';
  units.del_ea = '-';    label.del_ea = 'number of embryos per adult';
  units.ER = '1/d';      label.ER  = 'mean reproduction rate of adults';
  units.EL_n   = 'cm';   label.EL_n   = 'mean structural length of post-natals';
  units.EL2_n  = 'cm^2'; label.EL2_n  = 'mean squared structural length of post-natals';
  units.EL3_n  = 'cm^3'; label.EL3_n  = 'mean cubed structural length of post-natals';
  units.EL_a   = 'cm';   label.EL_a   = 'mean structural length of adults';
  units.EL2_a  = 'cm^2'; label.EL2_a  = 'mean squared structural length of adults';
  units.EL3_a  = 'cm^3'; label.EL3_a  = 'mean cubed structural length of adults';
  units.EWw_n  = 'g';    label.EWw_n     = 'mean wet weight of post-natals';
  units.EWw_a  = 'g';    label.EWw_a  = 'mean wet weight of adults';
  units.hWw_n = 'g/d';     label.hWw_n  = 'post-natal spec production of dead post-natals';
  units.Ep_A = 'J/d';    label.Ep_A = 'mean assimilation energy of post-natals';
  units.EJ_X = 'g/d';    label.EJ_X = 'mean ingestion rate of wet food by post-natals';
  units.EJ_P = 'g/d';    label.EJ_P = 'mean production rate of wet feces by post-natals';
  
  % fill stat for thinning false, true and f = f_min, f, f_max
  stat.f.f0.thin1   = f_01;   stat.f.f0.thin0   = f_00;   
  stat.r.f0.thin1   = 0;       stat.r.f0.thin0   = 0;       
  stat.t2.f0.thin1  = t2_01;  stat.t2.f0.thin0  = t2_00;  
  stat.S_b.f0.thin1 = S_b_01; stat.S_b.f0.thin0 = S_b_00; 
  stat.S_p.f0.thin1 = S_p_01; stat.S_p.f0.thin0 = S_p_00; 
  stat.theta_jn.f0.thin1 = theta_jn_01; stat.theta_jn.f0.thin0 = theta_jn_00; 
  stat.theta_e.f0.thin1 = theta_e_01; stat.theta_e.f0.thin0 = theta_e_00; 
  stat.del_ea.f0.thin1  = del_ea_01; stat.del_ea.f0.thin0  = del_ea_00;  
  stat.ER.f0.thin1     = ER_01;  stat.ER.f0.thin0  = ER_00;  
  stat.EL_n.f0.thin1   = EL_01;   stat.EL_n.f0.thin0   = EL_00;   
  stat.EL2_n.f0.thin1  = EL2_01;  stat.EL2_n.f0.thin0  = EL2_00;  
  stat.EL3_n.f0.thin1  = EL3_01;  stat.EL3_n.f0.thin0  = EL3_00;  
  stat.EL_a.f0.thin1   = EL_a_01;   stat.EL_a.f0.thin0   = EL_a_00;   
  stat.EL2_a.f0.thin1  = EL2_a_01;  stat.EL2_a.f0.thin0  = EL2_a_00;  
  stat.EL3_a.f0.thin1  = EL3_a_01;  stat.EL3_a.f0.thin0  = EL3_a_00;  
  stat.EWw_n.f0.thin1  = EWw_n_01;  stat.EWw_n.f0.thin0  = EWw_n_00;  
  stat.EWw_a.f0.thin1  = EWw_a_01;  stat.EWw_a.f0.thin0  = EWw_a_00;  
  stat.hWw_n.f0.thin1    = hWw_n_01;  stat.hWw_n.f0.thin0  = hWw_n_00;  
  stat.Ep_A.f0.thin1   = Ep_A_01; stat.Ep_A.f0.thin0 = Ep_A_00;  
  stat.EJ_X.f0.thin1   = EJ_X_01; stat.EJ_X.f0.thin0 = EJ_X_00;  
  stat.EJ_P.f0.thin1   = EJ_P_01; stat.EJ_P.f0.thin0 = EJ_P_00;  
  %
  if ~(n_fVal == 2)
    stat.f.f.thin1   = f_f1;   stat.f.f.thin0   = f_f0;  
    stat.r.f.thin1   = r_f1;   stat.r.f.thin0   = r_f0;   
    stat.t2.f.thin1  = t2_f1;  stat.t2.f.thin0  = t2_f0;   
    stat.S_b.f.thin1 = S_b_f1; stat.S_b.f.thin0 = S_b_f0; 
    stat.S_p.f.thin1 = S_p_f1; stat.S_p.f.thin0 = S_p_f0; 
    stat.theta_jn.f.thin1 = theta_jn_f1; stat.theta_jn.f.thin0 = theta_jn_f0; 
    stat.theta_e.f.thin1 = theta_e_f1; stat.theta_e.f.thin0 = theta_e_f0; 
    stat.del_ea.f.thin1  = del_ea_f1; stat.del_ea.f.thin0  = del_ea_f0;  
    stat.ER.f.thin1  = ER_f1;  stat.ER.f.thin0  = ER_f0;  
    stat.EL_n.f.thin1   = EL_f1;   stat.EL_n.f.thin0   = EL_f0;   
    stat.EL2_n.f.thin1  = EL2_f1;  stat.EL2_n.f.thin0  = EL2_f0;  
    stat.EL3_n.f.thin1  = EL3_f1;  stat.EL3_n.f.thin0  = EL3_f0;  
    stat.EL_a.f.thin1   = EL_a_f1;   stat.EL_a.f.thin0   = EL_a_f0;   
    stat.EL2_a.f.thin1  = EL2_a_f1;  stat.EL2_a.f.thin0  = EL2_a_f0;  
    stat.EL3_a.f.thin1  = EL3_a_f1;  stat.EL3_a.f.thin0  = EL3_a_f0;  
    stat.EWw_n.f.thin1  = EWw_n_f1;  stat.EWw_n.f.thin0  = EWw_n_f0;
    stat.EWw_a.f.thin1  = EWw_a_f1;  stat.EWw_a.f.thin0  = EWw_a_f0;
    stat.hWw_n.f.thin1  = hWw_n_f1;  stat.hWw_n.f.thin0  = hWw_n_f0;
    stat.Ep_A.f.thin1 = Ep_A_f1; stat.Ep_A.f.thin0 = Ep_A_f0;
    stat.EJ_X.f.thin1 = EJ_X_f1; stat.EJ_X.f.thin0 = EJ_X_f0;  
    stat.EJ_P.f.thin1 = EJ_P_f1; stat.EJ_P.f.thin0 = EJ_P_f0;  
  end
  %
  stat.f.f1.thin1   = 1;      stat.f.f1.thin0   = 1;  
  stat.r.f1.thin1   = r_11;   stat.r.f1.thin0   = r_10;     
  stat.t2.f1.thin1  = t2_11;  stat.t2.f1.thin0  = t2_10;     
  stat.S_b.f1.thin1 = S_b_11; stat.S_b.f1.thin0 = S_b_10; 
  stat.S_p.f1.thin1 = S_p_11; stat.S_p.f1.thin0 = S_p_10; 
  stat.theta_jn.f1.thin1 = theta_jn_11; stat.theta_jn.f1.thin0 = theta_jn_10; 
  stat.theta_e.f1.thin1 = theta_e_11; stat.theta_e.f1.thin0 = theta_e_10; 
  stat.del_ea.f1.thin1  = del_ea_11; stat.del_ea.f1.thin0  = del_ea_10;  
  stat.ER.f1.thin1  = ER_11;  stat.ER.f1.thin0  = ER_10;  
  stat.EL_n.f1.thin1   = EL_11;   stat.EL_n.f1.thin0   = EL_10;   
  stat.EL2_n.f1.thin1  = EL2_11;  stat.EL2_n.f1.thin0  = EL2_10;  
  stat.EL3_n.f1.thin1  = EL3_11;  stat.EL3_n.f1.thin0  = EL3_10;  
  stat.EL_a.f1.thin1   = EL_a_11;   stat.EL_a.f1.thin0   = EL_a_10;   
  stat.EL2_a.f1.thin1  = EL2_a_11;  stat.EL2_a.f1.thin0  = EL2_a_10;  
  stat.EL3_a.f1.thin1  = EL3_a_11;  stat.EL3_a.f1.thin0  = EL3_a_10;  
  stat.EWw_n.f1.thin1  = EWw_n_11;  stat.EWw_n.f1.thin0  = EWw_n_10;
  stat.EWw_a.f1.thin1  = EWw_a_11;  stat.EWw_a.f1.thin0  = EWw_a_10;
  stat.hWw_n.f1.thin1  = hWw_n_11;  stat.hWw_n.f1.thin0  = hWw_n_10;
  stat.Ep_A.f1.thin1 = Ep_A_11; stat.Ep_A.f1.thin0 = Ep_A_10;
  stat.EJ_X.f1.thin1 = EJ_X_11; stat.EJ_X.f1.thin0 = EJ_X_10;  
  stat.EJ_P.f1.thin1 = EJ_P_11; stat.EJ_P.f1.thin0 = EJ_P_10;  

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


