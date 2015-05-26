function shtime7 (j)
 %% created: 2002/04/04 by Bas Kooijman; modified 2009/09/29
  %% time_plots for 'endosym': One structure, 2 reserves
  %% State vector:
  %% (1-2)substrates S (3-4)products P (5-6) excreted reserves
  %% (7-9)structure V, reserve densities 1,2

  global istate7; % initial values of state variables (set in 'pars')

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  tmax = 200;  nt = 100; t = linspace(0, tmax, nt); % set time points
  [t, X_t]  = ode23s ('dstate7', t, istate7);

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
        plot (t, X_t(:,5), 'b', t, X_t(:,6), 'r');
        xlabel('time'); ylabel('excreted reserves');

      case 4
        plot (t, X_t(:,7), 'b');
        xlabel('time'); ylabel('structure');

      case 5
        plot (t, X_t(:,8), 'b',t, X_t(:,9), 'r');
        xlabel('time'); ylabel('res densities');
        
    case 6
        plot (t, X_t(:,9)./X_t(:,8), 'g');
        xlabel('time'); ylabel('ratio reserve 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 3, 1);
        plot (t, X_t(:,1), 'b', t, X_t(:,2), 'r');
        xlabel('time'); ylabel('substrates'); 

        subplot (2, 3, 2);
        plot (t, X_t(:,3), 'b', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('products'); 

        subplot (2, 3, 3); 
        plot (t, X_t(:,5), 'b', t, X_t(:,6), 'r');
        xlabel('time'); ylabel('excreted reserves');

        subplot (2, 3, 4);
        plot (t, X_t(:,7), 'b');
        xlabel('time'); ylabel('structure');

        subplot (2, 3, 5);
        plot (t, X_t(:,8), 'b', t, X_t(:,9), 'r');
        xlabel('time'); ylabel('res densities');

        subplot (2, 3, 6);
        plot (t, X_t(:,9)./X_t(:,8), 'g');
        xlabel('time'); ylabel('ratio reserve 2/1');

  end
