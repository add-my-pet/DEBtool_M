%% sgr_mod
% Gets specific population growth rate

%%
function [r, info] = sgr_mod (model, par, T_pop, f_pop)
  % created 2019/07/21 by Bas Kooijman
  
  %% Syntax
  % [r, info] = <../sgr_mod.m *sgr_mod*> (model, par, T_pop, f_pop)
  
  %% Description
  % Shell around sgr_std, sgr_stf, etc. For explanation see there

  switch model
    case 'std'
      [r, info] = sgr_std (par, T_pop, f_pop);
    case 'stf'
      [r, info] = sgr_stf (par, T_pop, f_pop);
    case 'stx'
      [r, info] = sgr_stx (par, T_pop, f_pop);
    case 'ssj'
      [r, info] = sgr_ssj (par, T_pop, f_pop);
    case 'sbp'
      [r, info] = sgr_sbp (par, T_pop, f_pop);
    case 'abj'
      [r, info] = sgr_abj (par, T_pop, f_pop);
    case 'asj'
      [r, info] = sgr_asj (par, T_pop, f_pop);
    case 'abp'
      [r, info] = sgr_abp (par, T_pop, f_pop);
    case 'hep'
      [r, info] = sgr_hep (par, T_pop, f_pop);
    case 'hax'
      [r, info] = sgr_hax (par, T_pop, f_pop);
    case 'hex'
      [r, info] = sgr_hex (par, T_pop, f_pop);
  end