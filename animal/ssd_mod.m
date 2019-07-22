%% ssd_mod
% statistics for stable size distribution and statistics

%%
function stat = ssd_mod(stat, code, model, par, T_pop, f_pop, sgr)
  % created 2019/07/21 by Bas Kooijman
  
  %% Syntax
  % stat = <../ssd_mod.m *ssd_mod*> (model, stat, code, par, T_pop, f_pop, sgr)
  
  %% Description
  % Shell around ssd_std, ssd_stf, etc. For explanation see there

  switch model
    case {'std','stx'}
      stat = ssd_std(stat, code, par, T_pop, f_pop, sgr);
  end