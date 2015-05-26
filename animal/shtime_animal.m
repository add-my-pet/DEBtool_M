%% shtime_animal
% Time plots for 'animal'

%%
function shtime_animal
  % created 2000/09/05 by Bas Kooijman, modified 2009/01/29
  
  %% Syntax
  % <../shtime_animal.m *shtime_animal*>
  
  %% Description
  % Time plots for 'animal'
  %
  % * <shtime2length.html *shtime2length*>:
  %   length as function of time
  % * <shtime2reprod.html *shtime2reprod*>:
  %   reproduction rate as function of time
  % * <shtime2weight.html *shtime2weight*>:
  %   weight as function of time
  % * <shtime2survival.html *shtime2survival*>:
  %   survival probability as function of time

  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values.
  % The time intervals that are shown correspond with lengths upto 0.99 times the ultimate length.

  
  %% Example of use
  % clear all; pars_animal; shtime_animal

  subplot (2, 2, 1); shtime2length;
  subplot (2, 2, 2); shtime2reprod;
  subplot (2, 2, 3); shtime2weight;
  subplot (2, 2, 4); shtime2survival;
