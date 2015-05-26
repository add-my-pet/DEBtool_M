%% warning_std
% warns if parameter values are in the reasonable part of the parameter space of standard DEB model without acceleration

%%
function warning_std(par, chem)
% created 2015/02/09 by Goncalo Marques; modified 2015/02/26 by Goncalo Marques

%% Syntax
% <../warning_abj.m *warning_abj*> (par, chem)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of standard DEB model without acceleration.
% Meant to be run after the estimation procedure
%
% Input
%
% * par: structure with parameters (see below)
% * chem: structure with biochemical parameters


  % unpack par, chem
  v2struct(par); v2struct(chem);

  cpar = parscomp_st(par, chem);
  v2struct(cpar);

  if kap_G >= mu_V / mu_E; % can only occur if y_VE > 1, meaning that CO2 is consumed
    fprintf('kap_G >= mu_V / mu_E, which is not allowed if CO2 production occurs in association with growth. \n');
  end

  if kap_X >= mu_X / mu_E; % can only occur if y_XE > 1, meaning that CO2 is consumed
    fprintf('kap_X >= mu_X / mu_E, which is not allowed if CO2 production occurs in association with assimilation. \n');
  end

  if exist('kap_P', 'var')
    if kap_P >= mu_X / mu_P; % can only occur if y_XE > 1, meaning that CO2 is consumed
      fprintf('kap_P >= mu_X / mu_P, which is not allowed if CO2 production occurs in association with assimilation. \n');
    end
  end
  
  pars_tp = [g; k; l_T; v_Hb; v_Hp]; % compose parameter vector for get_tp
  [t_p t_b l_p l_b] = get_tp(pars_tp, 1);
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];     % compose parameter vector
  t_m = get_tm_s(pars_tm, 1);              % -, scaled mean life span

  if t_m < t_p
    fprintf('Ageing is too fast for the organism to be able to reproduce if death occurs at (mean) life span. \n');
  end
