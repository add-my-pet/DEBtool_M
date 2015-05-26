%% shlength2res_time
% Plots mean residence times of molecules in reserve

%%
function shlength2res_time
  % created 2009/01/15 by Bas Kooijman, modified 2009/09/29
  
  %% Description
  % Plots the mean residence times of molecules in the reserve  at scaled functional responses f = 1, 0.8, 0.6, .. as functions of scaled lengths: 
  % This time equals the ratio of mobilisation power and reserve energy.
  % See <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf *Comments for section 2.3*>

  %% Example of use
  % clear; pars_animal; shlength2res_time


  global kT_M g l_T 
  
  hold on
  
  for f = 0.2:0.2:1

    l = linspace(1e-4, f, 50 * f)';
    t_E = res_time(l, f, [kT_M; g; l_T]);

    plot(l, t_E, 'r')
  end
  title('f = 1, .8, ., .2')
  xlabel('scaled length')
  ylabel('reserve residence time, d')