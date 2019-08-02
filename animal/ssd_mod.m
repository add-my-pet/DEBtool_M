%% ssd_mod
% statistics for stable size distribution

%%
function stat = ssd_mod(model, stat, code, par, T_pop, f_pop, sgr)
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
      stat = ssd_std(stat, code, par, T_pop, f_pop, sgr);
    case 'stf'
      stat = ssd_stf(stat, code, par, T_pop, f_pop, sgr);
    case 'stx'
      stat = ssd_stx(stat, code, par, T_pop, f_pop, sgr);
    case 'ssj'
      stat = ssd_ssj(stat, code, par, T_pop, f_pop, sgr);
    case 'sbp'
      stat = ssd_sbp(stat, code, par, T_pop, f_pop, sgr);
    case 'abj'
      stat = ssd_abj(stat, code, par, T_pop, f_pop, sgr);
    case 'asj'
      stat = ssd_asj(stat, code, par, T_pop, f_pop, sgr);
    case 'abp'
      stat = ssd_abp(stat, code, par, T_pop, f_pop, sgr);
    case 'hep'
      stat = ssd_hep(stat, code, par, T_pop, f_pop, sgr);
    case 'hex'
      stat = ssd_hex(stat, code, par, T_pop, f_pop, sgr);
  end
