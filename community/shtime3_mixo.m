function shtime3_mixo (j)
  %  created: 2001/09/07 by Bas Kooijman, modified 2009/01/05
  %  time_plots for 'mixo': 3-reserves
  
  %  State vector:
  %    (1) C DIC (2) N DIN (3) DV V-Detritus (4) DE E-Detritus
  %    (5) V structure (6) E reserve (7) EC C-reserve (8) EN N-reserve

  global istate; % initial states set in 'pars3'
  
  tmax = 500; % set time max 
  pars3_mixo; % set parameter values
  [t, X_t]  = ode23s ('dstate3_mixo', [0 tmax], istate);

  %  gset nokey;

  %  % check for conservation of carbon and nitrogen
  %  global n_NV n_NE n_NEN n_CEC; % for check on mass conservation
  %  C = X_t(:,1) + X_t(:,3) + X_t(:,4) + X_t(:,5) + X_t(:,6) + X_t(:,7);
  %  N = X_t(:,2) + n_NV * (X_t(:,3) + X_t(:,5)) + ...
  %  n_NE * (X_t(:,4) + X_t(:,6)) + n_NEN * X_t(:,8);
  %  multiplot(1,2)
  
  %  subplot(1,2,1)
  %  clg; xlabel('time, d'); ylabel('total carbon');
  %  plot (t, C, '8');

  %  subplot(1,2,2)
  %  clg; xlabel('time, d'); ylabel('total nitrogen');
  %  plot (t, N, 'b');

  %  multiplot(0,0)
  %  return
  
  if exist('j', 'var')==1 % single plot mode
    clf;
    switch j
	
      case 1
        plot (t, X_t(:,1), 'k');
        xlabel('time, d'); ylabel('DIC, muM'); 

      case 2
        plot (t, X_t(:,2), 'b');
        xlabel('time, d'); ylabel('DIN, muM');

      case 3
        plot (t, X_t(:,3), 'k');
        xlabel('time, d'); ylabel('struc-detritus, muM');

      case 4
        plot (t, X_t(:,4), 'k');
        xlabel('time, d'); ylabel('res-detritus, muM');

      case 5
        plot (t, X_t(:,5), 'g');
        xlabel('time, d'); ylabel('structure, muM');

      case 6
        plot (t, X_t(:,6), 'r', t, X_t(:,7), 'k', ...
	          t, X_t(:,8), 'b');
        xlabel('time, d'); ylabel('reserves, muM');

      otherwise
	return;

    end
  else % multiple plot mode
    % multiplot(2, 3);
    
        subplot (2, 3, 1);
	    plot (t, X_t(:,1), 'k');
        xlabel('time, d'); ylabel('DIC, muM');

        subplot (2, 3, 2);
        plot (t, X_t(:,2), 'b');
        xlabel('time, d'); ylabel('DIN, muM');

        subplot (2, 3, 3);
        plot (t, X_t(:,3), 'k');
        xlabel('time, d'); ylabel('V-detritus, muM');

        subplot (2, 3, 4);
        plot (t, X_t(:,4), 'k');
        xlabel('time, d'); ylabel('E-detritus, muM');

        subplot (2, 3, 5);
        plot (t, X_t(:,5), 'g');
        xlabel('time, d'); ylabel('structure, muM');

	    subplot (2, 3, 6); 
        plot (t, X_t(:,6), 'r', t, X_t(:,7), 'k', ...
	          t, X_t(:,8), 'b');
        xlabel('time, d'); ylabel('reserves, muM');

    % multiplot (0, 0);
  end