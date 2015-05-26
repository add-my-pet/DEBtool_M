function shtime0 (j)
  %% created: 2002/02/27 by Bas Kooijman; modified 2009/09/29
  %% time_plots for 'endosym'
  %% 
  %% State vector:
  %% (1,2)substrates S (3,4)products P
  %% (5,6)structure V, reserve density m of species 1
  %% (7,8)structure V, reserve density m of species 2

  global istate0; % initial states set in 'pars'
  
  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  tmax = 100; nt = 100; t = linspace(0, tmax, nt); % set time points
  [t, X_t]  = ode23s ('dstate0', t, istate0);

  if exist('j','var')==1 % single plot mode
    clf;
    switch j
	
      case 1
        plot (t, X_t(:,1), 'g', t, X_t(:,2), 'r');
        xlabel('time'); ylabel('substrate'); 

      case 2
        plot (t, t, X_t(:,3), 'g', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('product');

      case 3
        plot (t, t, X_t(:,5), 'g', t, X_t(:,7), 'r');
        xlabel('time'); ylabel('structure');

      case 4
        plot (t, X_t(:,6), 'g', t, X_t(:,8), 'r');
        xlabel('time'); ylabel('reserve density');

      case 5
        plot (t, X_t(:,7)./X_t(:,5), 'g');
        xlabel('time'); ylabel('ratio of structure 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    %% multiplot(2, 2);
    
        subplot (2, 2, 1);
	    plot (t, X_t(:,1), 'g', t, X_t(:,2), 'r');
        xlabel('time'); ylabel('substrate');

        subplot (2, 2, 2);
        plot (t, X_t(:,3), 'g', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('product');

        subplot (2, 2, 3);
        plot (t, X_t(:,5), 'g', t, X_t(:,7), 'r');
        xlabel('time'); ylabel('structure');

        subplot (2, 2, 4);
        plot (t, X_t(:,6), 'g', t, X_t(:,8), 'r');
        xlabel('time'); ylabel('reserve density');

    %% multiplot (0, 0);
  end
