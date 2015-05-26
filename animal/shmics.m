%% shmics
% demo that runs miscellaneous plots

%%
function shmics
  % created 2002/04/09 by Bas Kooijman
  
  %% Syntax 
  % <../shmics.m *shmics*>
  
  %% Description
  % miscellaneous plots 
  %
  % * <../../lib/misc/html/shtemp2corr.html *shtemp2corr*>:
  %   correction factor as function of temperature
  % * <shtime2eweight.html *shtime2eweight*>:
  %   weight of embryo as function of length
  % * <shlength2reprod.html *shlength2reprod*>:
  %   reproduction rate as function of length
  % * <shlength2res_time.html *shlength2res_time*>:
  %   residence time as function of length

  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values

  %% Example of use
  % clear all; pars_animal; shmics

  global T_ref pars_T
  
  subplot (2, 2, 1); shtemp2corr (T_ref, pars_T);
  subplot (2, 2, 2); shtime2eweight;
  subplot (2, 2, 3); shlength2reprod;
  subplot (2, 2, 4); shlength2res_time;