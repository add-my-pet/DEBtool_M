function shtime8 (j)
  %% created: 2002/04/04 by Bas Kooijman; modified 2009/09/29
  %% time_plots for 'endosym'
  %% Single species, 1 structure, 1 reserve, 2 substrates, 2 products
  %% State vector:
  %% (1-2)substrates S (3-4)products P
  %% (5-6)structure V, reserve density m of species

  global istate8; % initial values of state variables (set in 'pars')
  
  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end
  
  tmax = 200; nt = 100; t = linspace(0, tmax, nt); % set time points
  [t, X_t]  = ode23s ('dstate8', t, istate8); % integrate dynamic system

  if exist('j','var')==1 % single plot mode
    clf;
    switch j
	
      case 1
        plot (t, X_t(:,1), 'b', t, X_t(:,2), 'r');
        xlabel('time'); ylabel('substrates'); 

      case 2
        plot (t, X_t(:,3), 'b', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('products');

      case 3
        plot (t, X_t(:,5), 'b');
        xlabel('time'); ylabel('structure');

      case 4
        plot (t, X_t(:,6), 'b');
        xlabel('time'); ylabel('reserve density');

      otherwise
	return;

    end
  else % multiple plot mode
    %% multiplot(2, 2);
    
        subplot (2, 2, 1);
	plot (t, X_t(:,1), 'b', t, X_t(:,2), 'r');
        xlabel('time'); ylabel('substrates');

        subplot (2, 2, 2);
        plot (t, X_t(:,3), 'b', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('products');

        subplot (2, 2, 3);
        plot (t, X_t(:,5), 'b');
        xlabel('time'); ylabel('structure');

        subplot (2, 2, 4);
        plot (t, X_t(:,6), 'b');
        xlabel('time'); ylabel('reserve density');

    %% multiplot (0, 0);
  end
