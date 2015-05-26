function shtime5 (j)
  %% created: 2002/04/04 by Bas Kooijman; modified 2009/09/29
  %% time_plots for 'endosym'
  %% State vector:
  %% (1-3)substrates S (4-7)products P
  %% (8,9)structure V, reserve density m of species 1
  %% (10,11)structure V, reserve density m of species 2 internal

  global h istate5; % initial values of state variables set in 'pars'

  err = testpars; % set test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  tmax = 5; nt = 100; t = linspace(0, tmax, nt); % set time points
  [t, X_t]  = ode23s ('dstate5', t, istate5);
  ttext = ['h = ', num2str(h)];  title(ttext);

  if exist('j','var')==1 % single plot mode
    clf;
    switch j
	
      case 1
        plot (t, X_t(:,1), 'b');
        xlabel('time'); ylabel('substrate 1'); 

      case 2
        plot (t, X_t(:,2), 'r.', t, X_t(:,3), 'r');
        xlabel('time'); ylabel('substrate 2'); 

      case 3
        plot (t, X_t(:,4), 'b.', t, X_t(:,5), 'b');
        xlabel('time'); ylabel('product 1');

      case 4
        plot (t, X_t(:,6), 'r.', t, X_t(:,7), 'r');
        xlabel('time'); ylabel('product 2');

      case 5
        plot (t, X_t(:,8), 'b');
        xlabel('time'); ylabel('structure 1');

      case 6
        plot (t, X_t(:,10), 'r');
        xlabel('time'); ylabel('structure 2');

      case 7
        plot (t, X_t(:,9), 'b');
        xlabel('time'); ylabel('reserve density 1');

      case 8
        plot (t, X_t(:,11), 'r');
        xlabel('time'); ylabel('reserve density 2');

      case 9
        plot (t, X_t(:,10)./X_t(:,8), 'g');
        xlabel('time'); ylabel('ratio structure 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (4, 2, 1);
        plot (t, X_t(:,1), 'b');
        xlabel('time'); ylabel('substrate 1'); 

        subplot (4, 2, 2);
        plot (t, X_t(:,2), 'r.', t, X_t(:,3), 'r');
        xlabel('time'); ylabel('substrate 2'); 

        subplot (4, 2, 3);
        plot (t, X_t(:,4), 'b.', t, X_t(:,5), 'b');
        xlabel('time'); ylabel('product 1');

        subplot (4, 2, 4);
        plot (t, X_t(:,6), 'r.', t, X_t(:,7), 'r');
        xlabel('time'); ylabel('product 2');

        subplot (4, 2, 5);
        plot (t, X_t(:,8), 'b');
        xlabel('time'); ylabel('structure 1');

	    subplot (4, 2, 6);
        plot (t, X_t(:,10), 'r');
        xlabel('time'); ylabel('structure 2');

	    subplot (4, 2, 7);
        plot (t, X_t(:,9), 'b');
        xlabel('time'); ylabel('reserve density 1');

	    subplot (4, 2, 8);
        plot (t, X_t(:,11), 'r');
        xlabel('time'); ylabel('reserve density 2');

      end
