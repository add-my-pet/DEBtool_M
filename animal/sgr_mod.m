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
    case {'std','stx'}
      [r, info] = sgr_std (par, T_pop, f_pop);
    otherwise
      r = []; info = 0;
  end