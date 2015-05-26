%% shphase_memv
% Shows phase diagram of reserve and structural mass 

%%
function shphase_memv(F,d)
  % created 2000/09/05 by Bas Kooijman, modified 2009/09/30
  
  %% Syntax
  % <../shphase_memv.m *shphase_memv*> (F,d)
  
  %% Description
  % The routine plots the phase diagram of reserve mass M_E and structural mass M_V (in C-moles). 
  % The direction field is given with arrows, the null-isoclines in red curves. 
  % The green curves represent stage transitions: 
  % embryo to juvenile (where feeding is switched on), and where the mobilisation flux equals the somatic maintenance costs. 
  % If the organism could shrink, it would die at this border. 
  % The magenta box gives the border of possible values.
  %
  % Input
  %
  % * F: scalar with functional response
  % * d: scalar with multiplier for directionfield
  
  %% Remarks
  % Shrinking should be faster than indicated here cf {231}
  %   run pars_animal before running this function
  % See <shphase_el.html *shphase_el*> for phase diagram of scaled reserve density e and scaled lenth l.
  
  %% Example of use
  % pars_animal; shphase_memv(1,5)

  global JT_X_Am y_E_X jT_E_M kap m_Em M_Em M_Vm M_Vb l_T L_m g f

  if exist('d','var') == 0
    d = .01;
  end
  if exist('F','var') == 0
    F = .7;
  end
  
  f = F; % make func response available for fnmemv

  M_E = linspace(0, M_Em, 30)';  
  M_V = linspace(1e-4, M_Vm, 30)';
  dirf_memv = dirfield('fnmemv', M_E, M_V, d); % direction field
  
  M_V = linspace(1e-4, M_Vm, 100)'; l = (M_V/ M_Vm) .^ (1/3); % scaled length
  j_E_Am = y_E_X * (JT_X_Am * (l * L_m) .^ 2) ./ M_V;
  EV = [M_Em 0; M_Em M_Vm; 0 M_Vm];    % border
  E0 = [f* M_V * m_Em, M_V];  % isocline d/dt M_E = 0
  V0 = [M_V * m_Em .* (l_T + jT_E_M ./ (kap * j_E_Am)), M_V]; % d/dt M_V = 0
  Mb = [0, M_Vb; M_Em, M_Vb];            % embryo/juvenile transition
  E = kap * g * l ./ (g + (1 - kap) * l + l_T); % e at d/l transition
  Md = [E .* M_V * m_Em, M_V]; % death/alive transition
  
  hold on;
 
  plot(EV(:,1), EV(:,2), '-m') % border of phase diagram
  plot(E0(:,1), E0(:,2), '-r', V0(:,1), V0(:,2), '-r') % isoclines
  plot(Mb(:,1), Mb(:,2), '-g', Md(:,1), Md(:,2), '-g') % embryo/juvenile, death/alive transition
  plot_vector(dirf_memv, '-k') % attemps specification of linetype gives crashes
  plot(dirf_memv(:,1), dirf_memv(:,2), '.b') % points of departure
  title(['phase diagram for f = ', num2str(f)])
  xlabel('reserve mass, M_E')
  ylabel('structural mass, M_V')
