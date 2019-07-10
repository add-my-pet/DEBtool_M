%% popStatistics_st
% Computes implied properties of DEB models at population level

%%
function [stat, txtStat] = popStatistics_st(model, par, T, F) 
% created 2019/07/08 by Bas Kooijman

%% Syntax
% [stat txtStat] = <../popStatistics_st.m *popStatistics_st*>(model, par, T, f)

%% Description
% Computes quantites that depend on parameters, temperature and food level at population level.
% The allowed models are: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hex.
% If 4th input is a character string, it should specify a fraction for f in the interval (f_min, 1)
%
% Input
%
% * model: string with name of model
% * par :  structure with primary parameters at reference temperature in time-length-energy frame
% * T:     optional scalar with temperature in Kelvin; default C2K(20)
% * F:     optional scalar scaled functional response (default 1), or character string
% 
% Output
% 
% * stat: structure with statistics (see under remarks) with fields, units and labels
%
%     - f: scaled function response (set by input F)
%     - T: absolute temperature (set by input)
%     - TC: temperature correction factor
%
%     - f_0:   scaled functional response such that r = 0  with and without thinning
%     - r_max: population growth rate at f = 1 with and without thinning
%     - S_b_1: survivor probability at birth at f = 1 with and without thinning
%     - S_p_1: survivor probability at puberty at f = 1 with and without thinning
%     - r_f:   population growth rate at f with and without thinning
%     - S_b_f: survivor probability at birth at f with and without thinning
%     - S_p_f: survivor probability at puberty at f with and without thinning
%     - S_b_0: survivor probability at birth at f_min with and without thinning
%     - S_p_0: survivor probability at puberty at f_min with and without thinning
%
% * txtStat: structure with temp, fresp, units, labels for stat

%% Remarks
% Assumes that parameters are given in standard units (d, cm, mol, J, K); this is not checked!
% Buffer handling rules are species-specific, so ultimate reproduction rate Ri not always makes sense.
% Fermentation is supposed not to occur and dioxygen availability is assumed to be unlimiting.
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
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
  
  % initiate output with f, T, TC, h_B0b, h_Bbp, h_Bpi
  stat.T = K2C(T);        units.T = 'C';       label.T = 'body temperature'; 
  stat.h_B0b = par.h_B0b; units.h_B0b = '1/d'; label.h_B0b = 'background hazard for embryo'; 
  stat.h_Bbp = par.h_Bbp; units.h_Bbp = '1/d'; label.h_Bbp = 'background hazard for juvenile'; 
  stat.h_Bpi = par.h_Bpi; units.h_Bpi = '1/d'; label.h_Bpi = 'background hazard for adult'; 
 
  txtStat.units = units; % just for exist of function before the end is reached
  txtStat.label = label; % just for exist of function before the end is reached

  switch model
    % var_0_0 means var for f=f_min and thinning=0; var_1_1 means var for f=f_max and thinning=1
    case 'std'
      % r and f_0
      par.thinning = 1;
      [f_0_1, S_b_0_1, S_p_0_1] = f_ris0_std_r (par);
      [EL_0_1, EL2_0_1, EL3_0_1, EWw_0_1, Prob_bp_0_1] = ssd_std(par, [], f_0_1, 0);
      if ~(n_fVal == 2)
        if ischar(F)
          f_1 = str2double(F);
          if f_1 < 0 || f_1 > 1
            fprintf(['Warning from popStatistics_st: specified f = ', num2str(f_1), ' is outside the interval (0,1)\n']);
            return
          end
          f_1 = f_0_1 + f_1 * (1 - f_0_1); % -, scaled function response
        else
          f_1 = F;
        end
        if f_1 < f_0_1
          fprintf(['Warning from popStatistics_st: specified f = ', num2str(f_1), ' is smaller than minimum value ', num2str(f_0_1), '\n']);
          return
        end
        [r_f_1, S_b_f_1, S_p_f_1] = sgr_std (par, T, f_1);
        [EL_f_1, EL2_f_1, EL3_f_1, EWw_f_1, Prob_bp_f_1] = ssd_std(par, [], f_1, r_f_1);
      end
      [r_1_1, S_b_1_1, S_p_1_1] = sgr_std (par, T, 1);
      [EL_1_1, EL2_1_1, EL3_1_1, EWw_1_1, Prob_bp_1_1] = ssd_std(par, [], 1, r_1_1);
      
      par.thinning = 0;
      [f_0_0, S_b_0_0, S_p_0_0] = f_ris0_std_r (par);
      [EL_0_0, EL2_0_0, EL3_0_0, EWw_0_0, Prob_bp_0_0] = ssd_std(par, [], f_0_0, 0);
      if ~(n_fVal == 2)
        if ischar(F)
          f_0 = str2double(F);
          f_0 = f_0_0 + f_0 * (1 - f_0_0); % -, scaled function response
        else
          f_0 = F;
        end
        [r_f_0, S_b_f_0, S_p_f_0] = sgr_std (par, T, f_0);
        [EL_f_0, EL2_f_0, EL3_f_0, EWw_f_0, Prob_bp_f_0] = ssd_std(par, [], f_0, r_f_0);
      end
      [r_1_0, S_b_1_0, S_p_1_0] = sgr_std (par, T, 1);
      [EL_1_0, EL2_1_0, EL3_1_0, EWw_1_0, Prob_bp_1_0] = ssd_std(par, [], 1, r_1_0);
    otherwise
      return
  end
  stat.f.f0.thin1   = f_0_1;   stat.f.f0.thin0   = f_0_0;   units.f   = '-'; label.f   = 'functional response';
  stat.r.f0.thin1   = 0;       stat.r.f0.thin0   = 0;       units.r = '1/d'; label.r = 'spec pop growth rate';
  stat.S_b.f0.thin1 = S_b_0_1; stat.S_b.f0.thin0 = S_b_0_0; units.S_b = '-'; label.S_b = 'survival probability at birth';
  stat.S_p.f0.thin1 = S_p_0_1; stat.S_p.f0.thin0 = S_p_0_0; units.S_p = '-'; label.S_p = 'survival probability at puberty';
  stat.Prob_bp.f0.thin1 = Prob_bp_0_1; stat.Prob_bp.f0.thin0 = Prob_bp_0_0; units.Prob_bp = '-'; label.Prob_bp = 'fraction of post-natals that is juvenile';
  stat.EL.f0.thin1   = EL_0_1;   stat.EL.f0.thin0   = EL_0_0;   units.EL   = 'cm'; label.EL   = 'mean structural length';
  stat.EL2.f0.thin1  = EL2_0_1;  stat.EL2.f0.thin0  = EL2_0_0;  units.EL2  = 'cm^2'; label.EL2  = 'mean squared structural length';
  stat.EL3.f0.thin1  = EL3_0_1;  stat.EL3.f0.thin0  = EL3_0_0;  units.EL3  = 'cm^3'; label.EL3  = 'mean cubed structural length';
  stat.EWw.f0.thin1  = EWw_0_1;  stat.EWw.f0.thin0  = EWw_0_0;  units.EWw  = 'g';  label.EWw  = 'mean wet weight';
  %
  if ~(n_fVal == 2)
    stat.f.f.thin1   = f_1;     stat.f.f.thin0   = f_0;  
    stat.r.f.thin1   = r_f_1;   stat.r.f.thin0   = r_f_0;   
    stat.S_b.f.thin1 = S_b_f_1; stat.S_b.f.thin0 = S_b_f_0; 
    stat.S_p.f.thin1 = S_p_f_1; stat.S_p.f.thin0 = S_p_f_0; 
    stat.Prob_bp.f.thin1 = Prob_bp_f_1; stat.Prob_bp.f.thin0 = Prob_bp_f_0; 
    stat.EL.f.thin1   = EL_f_1;   stat.EL.f.thin0   = EL_f_0;   
    stat.EL2.f.thin1  = EL2_f_1;  stat.EL2.f.thin0  = EL2_f_0;  
    stat.EL3.f.thin1  = EL3_f_1;  stat.EL3.f.thin0  = EL3_f_0;  
    stat.EWw.f.thin1  = EWw_f_1;  stat.EWw.f.thin0  = EWw_f_0;
  end
  %
  stat.f.f1.thin1   = 1;       stat.f.f1.thin0    = 1;  
  stat.r.f1.thin1   = r_1_1;   stat.r.f1.thin0   = r_1_0;     
  stat.S_b.f1.thin1 = S_b_1_1; stat.S_b.f1.thin0 = S_b_1_0; 
  stat.S_p.f1.thin1 = S_p_1_1; stat.S_p.f1.thin0 = S_p_1_0; 
  stat.Prob_bp.f1.thin1 = Prob_bp_1_1; stat.Prob_bp.f1.thin0 = Prob_bp_1_0; 
  stat.EL.f1.thin1   = EL_1_1;   stat.EL.f1.thin0   = EL_1_0;   
  stat.EL2.f1.thin1  = EL2_1_1;  stat.EL2.f1.thin0  = EL2_1_0;  
  stat.EL3.f1.thin1  = EL3_1_1;  stat.EL3.f1.thin0  = EL3_1_0;  
  stat.EWw.f1.thin1  = EWw_1_1;  stat.EWw.f1.thin0  = EWw_1_0;
  
  % packing
  txtStat.units = units;
  txtStat.label = label;


