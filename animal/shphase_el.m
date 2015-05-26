%% shphase_el
% Shows phase diagram of scaled reserve density and scaled structural length

%%
function shphase_el(F,d)
  % created 2000/09/05 by Bas Kooijman, modified 2009/09/30
  
  %% Syntax
  % <../shphase_el.m *shphase_el*>(F,d)
  
  %% Description
  % The routine plots the phase diagram of scaled reserve density e and scaled length l. 
  % Embryos start at infinitely large scaled reserve density, but after birth, it is confined on the interval from 0 till 1. 
  % Scaled length is always between 0 and 1. 
  % The direction field is given with arrows, the null-isoclines in red curves. 
  % The green curves represent stage transitions: embryo to juvenile (where feeding is switched on), and where the mobilisation flux equals the somatic maintenance costs.  
  % If the organism could shrink, it would die at this border. 
  % The magenta box gives the border of possible values for juveniles and adults. 
  % Notice that the principle of weak homeostasis can be clearly seen from this direction field: 
  % any trajectory first bends to the null-isocline for e, than continue into the direction of the null-isocline for l, following the null-isocline for e.
  %
  % Input
  %
  % * F: optional scalar with functional response (a number between 0 and 1)
  % * d: optional scalar with multiplier for directionfield
  
  %% Remarks
  % Shrinking should be faster than indicated here cf {231};
  %   run pars_animal befor running this function.
  % See <shphase_memv.html *shphase_memv*> for phase diagram of reserve and structural mass.
  % The scaled reserve density e and the scaled length l relate to the reserve mass and the structural mass as e = M_E * M_Vm/ (M_V * M_Em) and l = (M_V/ M_Vm)^(1/3).

  %% Example of use
  % shphase_el(1,100)
  
  global g v_Hb k l_T kap f

  if exist('d','var') == 0
    d = .4;
  end
  if exist('F','var') == 0
    F = .7;
  end
  
  f = F; % % make func response available for fnel
  
  l_b = get_lb([g; k; v_Hb], f);
  
  l = linspace(.01, .99, 30)';
  %% truncate direction field to avoid problems with vector plotting
  dirf_el = max(-.1,dirfield('fnel', l, l, d)); % direction field

  el = [1 0; 1 1; 0 1];    % border
  e0 = [1e-4 0; 1e-4 l_b; f l_b;f 1];  % isocline d/dt e = 0
  l0 = [0, -l_T; 1, 1 - l_T];          % isocline d/dt l = 0
  lb = [0 l_b; 1 l_b];                 % embryo/juvenile transition
  
  l = linspace(0, 1, 100)';
  ld = [kap * g * l ./ (g + (1 - kap) * l + l_T), l]; % death/alive transition
  
  hold on;
  
  %% xrange [0:1]
  %% yrange [0:1]
  plot(el(:,1), el(:,2), '-m') % border
  plot(e0(:,1), e0(:,2), '-r', l0(:,1), l0(:,2), '-r') % isoclines
  plot(lb(:,1), lb(:,2), '-g', ld(:,1), ld(:,2), '-g') % embryo/juvenile, death/alive transition
  plot_vector(dirf_el, '-k') % attemps specification of linetype gives crashes
  plot(dirf_el(:,1), dirf_el(:,2), '.b') % points of departure
  title(['phase diagram for f = ', num2str(f)])
  ylabel('scaled length, l')
  xlabel('scaled res density, e')
