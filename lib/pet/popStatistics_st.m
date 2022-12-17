%% popStatistics_st
% Computes implied population properties of DEB models

function [stat, Hfig_surv, Hfig_stab] = popStatistics_st(model, par, T, F) 
% created 2019/07/08 by Bas Kooijman, modified 2020/02/21

%% Syntax
% [stat, Hfig_surv, Hfig_stab] = <../popStatistics_st.m *popStatistics_st*>(model, par, T, f)

%% Description
% Computes quantities that depend on parameters, temperature and food level at population level.
% First-level field is scaled func resp (f0, ff, f1, where ff is optional), second thinning (thin0, thin1), third gender(f,m, where m is optional)
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
%     - theta_e: fraction of individuals that is embryo
%     - theta_j: fraction of individuals that is juvenile
%     - theta_s: fraction of individuals that is adult
%     - L_bi: mean structural length of post-natals
%     - L2_bi: mean squared structural length of post-natals
%     - L3_bi: mean cubed structural length of post-natals
%     - Ww_bi: mean wet weight of post-natals
%     - L_pi: mean structural length of adults
%     - L2_pi: mean squared structural length of adults
%     - L3_pi: mean cubed structural length of adults
%     - Ww_pi: mean wet weight of adults
%     - Y_PX: yield of faeces on food
%     - Y_VX: yield of living structure on food
%     - Y_VX_d: yield of dead structure on food
%     - Y_EP: yield of living reserve on food
%     - Y_EP_d: yield of dead reserve on food
%     - mu_hx: yield of heat on food
%     - Y_CX: yield of CO2 on food
%     - Y_HX: yield of H2O on food
%     - Y_OX: yield of O2 on food
%     - Y_NX: yield of N-waste on food
%     - R: mean reproduction rate of adults
%     - J_X: mean ingestion rate of wet food by post-natals
%
% * Hfig_surv: figure handle for survivor probabilities
% * Hfig_stab: figure handle for atable age distributions

%% Remarks
% Assumes that parameters are given in standard units (d, cm, mol, J, K); this is not checked!
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
% The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref
% The labels and units are avilable in the (static) structures AmPdata/allUnits.mat and allLabel.mat
%
% For required model-specific fields, see <get_parfields.html *get_parfields*>.

%% Example of use
% load('results_species.mat'); [stat, txtStat] = popStatistics_st(metaPar.model, par); printstat_st(stat, txtStat)

  choices = {'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hax', 'hex'};
  if ~any(strcmp(model,choices))
    fprintf('warning from statistics_st: invalid model key \n')
    stat = []; 
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
  if ~isfield(par, 'h_Bbx')
    par.h_Bbx = 0;
  end
  if ~isfield(par, 'h_Bbs')
    par.h_Bbs = 0;
  end
  if ~isfield(par, 'h_Bbj')
    par.h_Bbj = 0;
  end
  if ~isfield(par, 'h_Bbp')
    par.h_Bbp = 0;
  end
  if ~isfield(par, 'h_Bpj')
    par.h_Bpj = 0;
  end
  if ~isfield(par, 'h_Bsj')
    par.h_Bsj = 0;
  end
  if ~isfield(par, 'h_Bxp')
    par.h_Bxp = 0;
  end
  if ~isfield(par, 'h_Bsp')
    par.h_Bsp = 0;
  end
  if ~isfield(par, 'h_Bjp')
    par.h_Bjp = 0;
  end
  if ~isfield(par, 'h_Bpi')
    par.h_Bpi = 0;
  end
  if ~isfield(par, 'h_Bbj')
    par.h_Bbj = 0;
  end
  if ~isfield(par, 'h_Bje')
    par.h_Bje = 0;
  end
  if ~isfield(par, 'h_Bei')
    par.h_Bei = 0;
  end

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);  
  
  if any(ismember({'z_m','E_Hbm','E_Hsm','E_Hxm','E_Hjm','E_Hpm'},fieldnames(par)))
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
  TC = tempcorr(T, T_ref, pars_T); % -, Temperature Correction factor
  stat.T = K2C(T); stat.c_T = TC;  % add to stat, txtStat is updated below, since ssd_mod overwrites txtStat              
      
  % first females with and without thinning, possibly followed by males; 
  % for each thinning-setting: f_min, possibly f, and f_max (=1)
  par.thinning = 1;
  [f_01, info_01] = f_ris0_mod (model, par); % get f for r = 0
  stat.f0.thin1.f.f = f_01; r_01 = 0; stat.f0.thin1.f.r = r_01; stat.f0.thin1.f.t2 = NaN; 
  if info_01 == 0
    stat = ssd_mod(model, stat, '01f', NaN); f_01 = NaN; stat.f0.thin1.f.f = f_01;
  else % fill statistics
    stat = ssd_mod(model, stat, '01f', par, T, f_01, 0);
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
      stat = ssd_mod(model, stat, 'f1f', NaN); stat.ff.thin1.f.f = f_f1;
    else
      [r_f1, info_f1] = sgr_mod (model, par, T, f_f1); 
      stat.ff.thin1.f.f = f_f1; stat.ff.thin1.f.r = r_f1; stat.ff.thin1.f.t2 = (log(2))/ r_f1;
    end
    if ~exist('info_f1', 'var') || info_f1 == 0
      stat = ssd_mod(model, stat, 'f1f', NaN); 
      stat.ff.thin1.f.r = NaN; stat.ff.thin1.f.t2 = NaN;
    else
      stat = ssd_mod(model, stat, 'f1f', par, T, f_f1, r_f1);
    end
  end
  [r_11, info_11] = sgr_mod (model, par, T, 1);
  stat.f1.thin1.f.f = 1; stat.f1.thin1.f.r = r_11; stat.f1.thin1.f.t2 = (log(2))/ r_11; 
  if info_11 == 0
    stat = ssd_mod(model, stat, '11f', NaN); 
    stat.f1.thin1.f.r = NaN; stat.f1.thin1.f.t2 = NaN;
  else
    stat = ssd_mod(model, stat, '11f', par, T, 1, r_11);
  end
            
  par.thinning = 0;
  [f_00, info_00] = f_ris0_mod (model, par); % get f for r = 0
  stat.f0.thin0.f.f = f_00; r_00 = 0; stat.f0.thin0.f.r = r_00; stat.f0.thin0.f.t2 = NaN; 
  if info_00 == 0
    stat = ssd_mod(model, stat, '00f', NaN); f_00 = NaN; stat.f0.thin0.f.f = f_00;
  else
    stat = ssd_mod(model, stat, '00f', par, T, f_00, 0);
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
      stat = ssd_mod(model, stat, 'f0f', NaN); stat.ff.thin0.f.f = f_f0;
    else
      [r_f0, info_f0] = sgr_mod (model, par, T, f_f0);
      stat.ff.thin0.f.f = f_f0; stat.ff.thin0.f.r = r_f0; stat.ff.thin0.f.t2 = (log(2))/ r_f0;
    end
    if ~exist('info_f0', 'var') || info_f0 == 0
      stat = ssd_mod(model, stat, 'f0f', NaN);
      stat.ff.thin0.f.r = NaN; stat.ff.thin0.f.t2 = NaN;
    else
      stat = ssd_mod(model, stat, 'f0f', par, T, f_f0, r_f0);
    end
  end
  [r_10, info_10] = sgr_mod (model, par, T, 1); 
  stat.f1.thin0.f.f = 1; stat.f1.thin0.f.r = r_10; stat.f1.thin0.f.t2 = (log(2))/ r_10;
  if info_10 == 0
    [stat, txtStat] = ssd_mod(model, stat, '10f', NaN); 
    stat.f1.thin0.f.r = NaN; stat.f1.thin0.f.t2 = NaN;
  else
    [stat, txtStat] = ssd_mod(model, stat, '10f', par, T, 1, r_10);
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
    stat.f0.thin1.m.f = stat.f0.thin1.f.f; stat.f0.thin1.m.r = stat.f0.thin1.f.r; stat.f0.thin1.m.t2 = stat.f0.thin1.f.t2; stat.f0.thin1.m.ER = [];
    if isnan(stat.f0.thin1.f.f) 
      stat = ssd_mod(model, stat, '01m', NaN); 
      stat.f0.thin1.m.r = r_01; stat.f0.thin1.m.t2 = stat.f0.thin1.f.t2; stat.f0.thin1.m.ER = [];
    else
      stat = ssd_mod(model, stat, '01m', par, T, f_01, 0); stat.f0.thin1.m.ER = [];
    end
    if n_fVal == 3
      stat.ff.thin1.m.f = stat.ff.thin1.f.f; stat.ff.thin1.m.r = stat.ff.thin1.f.r; stat.ff.thin1.m.t2 = stat.ff.thin1.f.t2; stat.ff.thin1.m.ER = [];
      if isnan(stat.ff.thin1.f.f)
        stat = ssd_mod(model, stat, 'f1m', NaN); stat.ff.thin1.m.f = NaN; stat.ff.thin1.m.ER = [];
      else
        stat = ssd_mod(model, stat, 'f1m', par, T, f_f1, r_f1); stat.ff.thin1.m.ER = [];
      end
    end
    stat.f1.thin1.m.f = stat.f1.thin1.f.f; stat.f1.thin1.m.r = stat.f1.thin1.f.r; stat.f1.thin1.m.t2 = stat.f1.thin1.f.t2;
    stat = ssd_mod(model, stat, '11m', par, T, 1, r_11); stat.f1.thin1.m.ER = [];
            
    par.thinning = 0;
    stat.f0.thin0.m.f = stat.f0.thin0.f.f; stat.f0.thin0.m.r = stat.f0.thin0.f.r; stat.f0.thin0.m.t2 = stat.f0.thin0.f.t2;
    if isnan(stat.f0.thin0.f.f) 
      stat = ssd_mod(model, stat, '00m', NaN); stat.f0.thin0.m.f = NaN; stat.f0.thin0.m.ER = [];
    else
      stat = ssd_mod(model, stat, '00m', par, T, f_00, 0); stat.f0.thin0.m.ER = [];
    end
    if n_fVal == 3
      stat.ff.thin0.m.f = stat.ff.thin0.f.f; stat.ff.thin0.m.r = stat.ff.thin0.f.r; stat.ff.thin0.m.t2 = stat.ff.thin0.f.t2;
      if isnan(stat.ff.thin0.f.f)
        stat = ssd_mod(model, stat, 'f0m', NaN); stat.ff.thin0.m.f = NaN; stat.ff.thin0.m.ER = [];
      else
        stat = ssd_mod(model, stat, 'f0m', par, T, f_f0, r_f0); stat.ff.thin0.m.ER = [];
      end
    end
    stat.f1.thin0.m.f = stat.f1.thin0.f.f; stat.f1.thin0.m.r = stat.f1.thin0.f.r; stat.f1.thin0.m.t2 = stat.f1.thin0.f.t2; 
    stat = ssd_mod(model, stat, '10m', par, T, 1, r_10); stat.f1.thin0.m.ER = [];   
  end
  
  % return % 2022/12/14 added in repair action of Y_VX
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


