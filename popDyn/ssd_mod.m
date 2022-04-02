%% ssd_mod
% statistics for stable size distribution

%%
function [stat, txtStat] = ssd_mod(model, stat, code, par, T_pop, f_pop, sgr)
  % created 2019/07/21 by Bas Kooijman
  
  %% Syntax
  % stat = <../ssd_mod.m *ssd_mod*> (model, stat, code, par, T_pop, f_pop, sgr)
  
  %% Description
  % Shell around ssd_std, ssd_stf, etc. For explanation see there

  if ~isstruct(par) % all statistics will be set NaN
    T_pop = []; f_pop = []; sgr = [];
  end

  switch model
    case 'std'
      [stat, txtStat] = ssd_std(stat, code, par, T_pop, f_pop, sgr);
    case 'stf'
      [stat, txtStat] = ssd_stf(stat, code, par, T_pop, f_pop, sgr);
    case 'stx'
      [stat, txtStat] = ssd_stx(stat, code, par, T_pop, f_pop, sgr);
    case 'ssj'
      [stat, txtStat] = ssd_ssj(stat, code, par, T_pop, f_pop, sgr);
    case 'sbp'
      [stat, txtStat] = ssd_sbp(stat, code, par, T_pop, f_pop, sgr);
    case 'abj'
      [stat, txtStat] = ssd_abj(stat, code, par, T_pop, f_pop, sgr);
    case 'asj'
      [stat, txtStat] = ssd_asj(stat, code, par, T_pop, f_pop, sgr);
    case 'abp'
      [stat, txtStat] = ssd_abp(stat, code, par, T_pop, f_pop, sgr);
    case 'hep'
      [stat, txtStat] = ssd_hep(stat, code, par, T_pop, f_pop, sgr);
    case 'hax'
      [stat, txtStat] = ssd_hax(stat, code, par, T_pop, f_pop, sgr);
    case 'hex'
      [stat, txtStat] = ssd_hex(stat, code, par, T_pop, f_pop, sgr);
  end
