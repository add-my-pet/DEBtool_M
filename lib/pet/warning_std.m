%% warning_std
% warns if parameter values are in the reasonable part of the parameter space of standard DEB model without acceleration

%%
function warning_std(p)
% created 2015/02/09 by Goncalo Marques; modified 2015/02/26, 2015/07/29 by Goncalo Marques
% 2015/08/03 by starrlight

%% Syntax
% <../warning_std.m *warning_std*> (p)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of standard DEB model without acceleration.
% Meant to be run after the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)

  c = parscomp_st(p);

  if isfield(p,'kap_P')
    if p.kap_X + p.kap_P >= 1
      fprintf('kap_X + kap_P > 1, which violates energy conservation. \n');
    end
  end
  
  if c.kap_G >= p.mu_V / p.mu_E; % can only occur if y_VE > 1, meaning that CO2 is consumed
    fprintf('kap_G >= mu_V / mu_E, which is not allowed if CO2 production occurs in association with growth. \n');
  end

  if p.kap_X >= p.mu_E / p.mu_X; % can only occur if y_XE > 1, meaning that CO2 is consumed
    fprintf('kap_X > mu_X / mu_E, which is not allowed if CO2 production occurs in association with assimilation. \n');
  end

  if isfield(p,'kap_P')
    if p.kap_X * p.mu_X / p.mu_E + p.kap_P * p.mu_X / p.mu_P >= 1 % can only occur if y_XE > 1, meaning that CO2 is consumed
      fprintf('kap_X * mu_X / mu_E + kap_P * mu_X / mu_P > 1, which is not allowed if CO2 production occurs in association with assimilation. \n');
    end
  end
  
  pars_tp = [c.g; c.k; c.l_T; c.v_Hb; c.v_Hp]; % compose parameter vector for get_tp
  t_p = get_tp(pars_tp, 1);
  pars_tm = [c.g; c.l_T; p.h_a/ c.k_M^2; p.s_G];     % compose parameter vector
  t_m = get_tm_s(pars_tm, 1);              % -, scaled mean life span

  if t_m < t_p
    fprintf('Ageing is too fast for the organism to be able to reproduce if death occurs at (mean) life span. \n');
  end
