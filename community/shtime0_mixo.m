function shtime0_mixo (j)
  %  created: 2001/09/06 by Bas Kooijman; modified 2009/01/05
  %  time_plots for 'mixo': 0-reserves
  %  
  %  State vector:
  %  (1) C DIC (2) N DIN (3) D Detritus (4) V structure

  global istate; % initial states set in 'pars0'
  
  tmax = 100; % set  max time
  pars0_mixo; % set parameter values
  [t X_t]  = ode15s ('dstate0_mixo', [0 tmax], istate);

  %  gset nokey

  %  check for conservation of carbon and nitrogen
  %  global n_NV; % for check on mass conservation
  %  C = X_t(:,1) + X_t(:,3) + X_t(:,4);
  %  N = X_t(:,2) + n_NV * (X_t(:,3) + X_t(:,4));
  %  multiplot(1,2)
  
  %  subplot(1,2,1)
  %  clf; xlabel('time, d'); ylabel('total carbon');
  %  plot (t, C, '8');

  %  subplot(1,2,2)
  %  clf; xlabel('time, d'); ylabel('total nitrogen');
  %  plot (t, N, 'b');

  %  multiplot(0,0)
  %  return
  
  if exist('j', 'var') == 1 % single plot mode
    switch j
	
      case 1
	clf;
        plot (t, X_t(:,1), 'k');
        xlabel('time, d'); ylabel('DIC, muM'); 

      case 2
	clf;
        plot (t, X_t(:,2), 'b');
        xlabel('time, d'); ylabel('DIN, muM');

      case 3
	clf;
        plot (t, X_t(:,3), 'k');
        xlabel('time, d'); ylabel('detritus, muM');

      case 4
	clf;
        plot (t, X_t(:,4), 'g');
        xlabel('time, d'); ylabel('structure, muM');

      otherwise
	return;

    end
  else % multiple plot mode
    % multiplot(2, 2);
    
        subplot (2, 2, 1); 
	    plot (t, X_t(:,1), 'k');
        xlabel('time, d'); ylabel('DIC, muM');

        subplot (2, 2, 2); 
        plot (t, X_t(:,2), 'b');
        xlabel('time, d'); ylabel('DIN, muM');

        subplot (2, 2, 3); 
        plot (t, X_t(:,3), 'k');
        xlabel('time, d'); ylabel('detritus, muM');

        subplot (2, 2, 4); 
        plot (t, X_t(:,4), 'g');
        xlabel('time, d'); ylabel('structure, muM');

    % multiplot (0, 0);
  end
