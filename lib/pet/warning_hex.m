%% warning_hex
% warns if parameter values are in the reasonable part of the parameter space of holometabolous insect model 

%%
function warning_hex(p)
% created 2015/06/05 by Goncalo Marques; modified 2015/07/29 by Goncalo Marques
% 2015/08/03 by starrlight
%% Syntax
% <../warning_hex.m *warning_hex*> (p)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of the holometabolous insect model.
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
  
