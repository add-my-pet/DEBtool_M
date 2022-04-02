%% f_ris0_mod
% Gets scaled functional response at with the specific population growth rate is zero

%%
function [f, info] = f_ris0_mod (model, par)
  % created 2019/07/21 by Bas Kooijman, modified 2022/03/17
  
  %% Syntax
  % [f, info] = <../f_ris0_mod.m *f_ris0_mod*> (model, par)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the standard DEB model equals zero, 
  %   by solving the characteristic equation with r=0, for a bisection method in f.  
  %
  % Input
  %
  % * model: character string with name of model
  % * par: structure parameter
  % * T: optional scalar for body temperature in Kelvin
  %
  % Output
  %
  % * f: scaled func response at which r = 0
  % * info: scalar with indicator for failure (0) or success (1)
  
  switch model
    case 'std'
      [f, info] = f_ris0_std (par);
    case 'stf'
      [f, info] = f_ris0_stf (par);
    case 'stx'
      [f, info] = f_ris0_stx (par);
    case 'ssj'
      [f, info] = f_ris0_ssj (par);
    case 'sbp'
      [f, info] = f_ris0_sbp (par);
    case 'abj'
      [f, info] = f_ris0_abj (par);
    case 'asj'
      [f, info] = f_ris0_asj (par);
    case 'abp'
      [f, info] = f_ris0_abp (par);
    case 'hep'
      [f, info] = f_ris0_hep (par);
    case 'hax'
      [f, info] = f_ris0_hax (par);
    case 'hex'
      [f, info] = f_ris0_hex (par);
  end
  
