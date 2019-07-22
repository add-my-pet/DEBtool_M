%% popStatistics_st
% Computes implied population properties of DEB models
%%
function [stat, txtStat, Hfig_surv, Hfig_stab] = popStatistics_st(model, par, T, F) 
% created 2019/07/08 by Bas Kooijman

%% Syntax
% [stat txtStat] = <../popStatistics_st.m *popStatistics_st*>(model, par, T, f)

%% Description
% Computes quantities that depend on parameters, temperature and food level at population level.
% Field-level field is scaled func resp (f0, ff, f1, where ff is optional), second thinning (thin0, thin1), third gender(f,m, where m is optional)
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
    fprintf('warning from statistics_st: invalid model key \n')
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
  
  if any(ismember({'z_m','E_Hbm','E_Hjm','E_Hpm'},fieldnames(par)))
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

  % initiate output with T, TC
  stat.T = K2C(T);        units.T = 'C';       label.T = 'body temperature'; 
  stat.c_T = TC;          units.c_T = '-';     label.c_T = 'temperature correction factor'; 
      
  % first females with thinning 1 and 0, possibly followed by males with thinning 1 and 0

  par.thinning = 1; 
  [f_01, info_01] = f_ris0_mod (model, par, T); % get f for r = 0
  stat.f0.thin1.f.f = f_01; stat.f0.thin1.f.r = 0; stat.f0.thin1.f.t2 = NaN; 
  if info_01 == 0
    stat = ssd_mod(stat, '01f', model, NaN); stat.f0.thin1.f = NaN;
  else % fill statistics
    stat = ssd_mod(stat, '01f', model, par, T, f_01, 0);
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
      stat = []; txtStat = []; Hfig_surv = []; Hfig_stab = [];
      return
    end
    if isnan(f_f1)
      stat = ssd_mod(stat, 'f1f', model, NaN); stat.ff.thin1.f.f = NaN;
    else
      [r_f1, info_f1] = sgr_mod (model, par, T, f_f1); 
      stat.ff.thin1.f.f = f_f1; stat.ff.thin1.f.r = r_f1; stat.ff.thin1.f.t2 = (log(2))/ r_f1;
    end
    if info_f1 == 0
      stat = ssd_mod(stat, 'f1f', model, NaN); 
      stat.ff.thin1.f.f = NaN; stat.ff.thin1.f.r = NaN; stat.ff.thin1.f.t2 = NaN;
    else
      stat = ssd_mod(stat, 'f1f', model, par, T, f_f1, r_f1);
    end
  end
  [r_11, info_11] = sgr_mod (model, par, T, 1);
  stat.f1.thin1.f.f = 1; stat.f1.thin1.f.r = r_11; stat.f1.thin1.f.t2 = (log(2))/ r_11; 
  if info_11 == 0
    stat = ssd_mod(stat, '11f', model, NaN); 
    stat.f1.thin1.f.r = NaN; stat.f1.thin1.f.t2 = NaN;
  else
    stat = ssd_mod(stat, '11f', model, par, T, 1, r_11);
  end
            
  par.thinning = 0;
  [f_00, info_00] = f_ris0_mod (model, par, T); % get f for r = 0
  stat.f0.thin0.f.f = f_01; stat.f0.thin0.f.r = 0; stat.f0.thin0.f.t2 = NaN; 
  if info_00 == 0
    stat = ssd_mod(stat, '00f', model, NaN); stat.f0.thin0.f.f = NaN;
  else
    stat = ssd_mod(stat, '00f', model, par, T, f_00, 0);
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
      stat = ssd_mod(stat, 'f0f', model, NaN); stat.ff.thin0.f.f = NaN;
    else
      [r_f0, info_f0] = sgr_mod (model, par, T, f_f0);
      stat.ff.thin0.f.f = f_f0; stat.ff.thin0.f.r = r_f0; stat.ff.thin0.f.t2 = (log(2))/ r_f0;
    end
    if info_f0 == 0
      stat = ssd_mod(stat, 'f0f', model, NaN); stat.ff.thin0.f.f = NaN;
      stat.ff.thin0.f.f = NaN; stat.ff.thin0.f.r = NaN; stat.ff.thin0.f.t2 = NaN;
    else
      stat = ssd_mod(stat, 'f0f', model, par, T, f_f0, r_f0);
    end
  end
  [r_10, info_10] = sgr_mod (model, par, T, 1); 
  stat.f1.thin0.f.f = 1; stat.f1.thin0.f.r = r_10; stat.f1.thin0.f.t2 = (log(2))/ r_10;
  if info_10 == 0
    stat = ssd_mod(stat, '10f', model, NaN); 
    stat.f1.thin0.f.r = NaN; stat.f1.thin0.f.t2 = NaN;
  else
    stat = ssd_mod(stat, '10f', model, par, T, 1, r_10);
  end
            
  if male % overwrite of par!!!! parameters become male parameters
    if isfield(par,'z_m')
      par.z = par.z_m;
    end
    if isfield(par,'E_Hbm')
      par.E_Hb = par.E_Hbm;
    end
    if isfield(par,'E_Hjm')
      par.E_Hj = par.E_Hjm;
    end
    if isfield(par,'E_Hpm')
      par.E_Hp = par.E_Hpm;
    end
    
    par.thinning = 1; 
    stat.f0.thin1.m.r = stat.f0.thin1.f.r; stat.f0.thin1.m.t2 = stat.f0.thin1.f.t2; stat.f0.thin1.m.ER = [];
    if isnan(stat.f0.thin1.f.f)
      stat = ssd_mod(stat, '01m', model, NaN); 
      stat.f0.thin1.m.f = NaN; stat.f0.thin1.m.r = r_01; stat.f0.thin1.m.t2 = stat.f0.thin1.f.t2; stat.f0.thin1.m.ER = [];
    else
      stat = ssd_mod(stat, '01m', model, par, T, f_01, 0); stat.f0.thin1.m.ER = [];
    end
    if n_fVal == 3
      stat.ff.thin1.m.r = stat.ff.thin1.f.r; stat.ff.thin1.m.t2 = stat.ff.thin1.f.t2; stat.ff.thin1.m.ER = [];
      if isnan(stat.ff.thin1.f.f)
        stat = ssd_mod(stat, 'f1m', model, NaN); stat.ff.thin1.m.f = NaN; stat.ff.thin1.m.ER = [];
      else
        stat = ssd_mod(stat, 'f1m', model, par, T, f_f1, r_f1); stat.ff.thin1.m.ER = [];
      end
    end
    stat.f1.thin1.m.r = stat.f1.thin1.f.r; stat.f1.thin1.m.t2 = stat.f1.thin1.f.t2;
    stat = ssd_mod(stat, '11m', model, par, T, 1, r_11); stat.f1.thin1.m.ER = [];
            
    par.thinning = 0;
    stat.f0.thin0.m.r = stat.f0.thin0.f.r; stat.f0.thin0.m.t2 = stat.f0.thin0.f.t2;
    if isnan(stat.f0.thin0.f.f)
      stat = ssd_mod(stat, '00m', model, NaN); stat.f0.thin0.m.f = NaN; stat.f0.thin0.m.ER = [];
    else
      stat = ssd_mod(stat, '00m', model, par, T, f_00, 0); stat.f0.thin0.m.ER = [];
    end
    if n_fVal == 3
      stat.ff.thin0.m.r = stat.ff.thin0.f.r; stat.ff.thin0.m.t2 = stat.ff.thin0.f.t2;
      if isnan(stat.ff.thin0.f.f)
        stat = ssd_mod(stat, 'f0m', model, NaN); stat.ff.thin0.m.f = NaN; stat.ff.thin0.m.ER = [];
      else
        stat = ssd_mod(stat, 'f0m', model, par, T, f_f0, r_f0); stat.ff.thin0.m.ER = [];
      end
    end
    stat = ssd_mod(stat, '10m', model, par, T, 1, r_10);    
    stat.f1.thin0.m.r = stat.f1.thin0.f.r; stat.f1.thin0.m.t2 = stat.f1.thin0.f.t2; stat.f1.thin0.m.ER = [];
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
  
  % packing to output
  txtStat.units = units;
  txtStat.label = label;

  % graphics
 
  Hfig_surv = figure(1); % survivor prob
  if n_fVal == 2
    plot(stat.f1.thin0.f.tS(:,1), log(stat.f1.thin0.f.tS(:,2)), 'r', ...
         stat.f0.thin0.f.tS(:,1), log(stat.f0.thin0.f.tS(:,2)), 'b', ...
         stat.f1.thin1.f.tS(:,1), log(stat.f1.thin1.f.tS(:,2)), '-.r',  ...
         stat.f0.thin1.f.tS(:,1), log(stat.f0.thin1.f.tS(:,2)), '-.b', ...
         'Linewidth', 2)
  else % n_fVal == 3
    plot(stat.f1.thin0.f.tS(:,1), log(stat.f1.thin0.f.tS(:,2)), 'r', ...
         stat.ff.thin0.f.tS(:,1), log(stat.ff.thin0.f.tS(:,2)), 'm', ...
         stat.f0.thin0.f.tS(:,1), log(stat.f0.thin0.f.tS(:,2)), 'b', ...
         stat.f1.thin1.f.tS(:,1), log(stat.f1.thin1.f.tS(:,2)), '-.r',  ...
         stat.ff.thin1.f.tS(:,1), log(stat.ff.thin1.f.tS(:,2)), '-.m',  ...
         stat.f0.thin1.f.tS(:,1), log(stat.f0.thin1.f.tS(:,2)), '-.b', ...
         'Linewidth', 2)
  end
  xlabel('age, d'); ylabel('ln survival probability');
  set(gca, 'FontSize', 15, 'Box', 'on');

  Hfig_stab = figure(2); % stable age distribution
  if n_fVal == 2
    plot(stat.f1.thin0.f.tSs(:,1), log(stat.f1.thin0.f.tSs(:,2)), 'r', ...
         stat.f0.thin0.f.tSs(:,1), log(stat.f0.thin0.f.tSs(:,2)), 'b', ...
         stat.f1.thin1.f.tSs(:,1), log(stat.f1.thin1.f.tSs(:,2)), '-.r',  ...
         stat.f0.thin1.f.tSs(:,1), log(stat.f0.thin1.f.tSs(:,2)), '-.b', ...
         'Linewidth', 2)
  else % n_fVal == 3
    plot(stat.f1.thin0.f.tSs(:,1), log(stat.f1.thin0.f.tSs(:,2)), 'r', ...
         stat.ff.thin0.f.tSs(:,1), log(stat.ff.thin0.f.tSs(:,2)), 'm', ...
         stat.f0.thin0.f.tSs(:,1), log(stat.f0.thin0.f.tSs(:,2)), 'b', ...
         stat.f1.thin1.f.tSs(:,1), log(stat.f1.thin1.f.tSs(:,2)), '-.r',  ...
         stat.ff.thin1.f.tSs(:,1), log(stat.ff.thin1.f.tSs(:,2)), '-.m',  ...
         stat.f0.thin1.f.tSs(:,1), log(stat.f0.thin1.f.tSs(:,2)), '-.b', ...
         'Linewidth', 2)
  end
  xlabel('age, d'); ylabel('ln survivor fn of stable age distr');
  set(gca, 'FontSize', 15, 'Box', 'on');


