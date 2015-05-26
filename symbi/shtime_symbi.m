function shtime_symbi (j)
  %% created: 2000/10/01 by Bas Kooijman, modified 2009/01/03
  %% time_plots for 'symbi'
  %% State vector:
  %%   X_t = [X; X_N; X_CH; X_VA; m_EC; m_EN; X_VH; m_E]
  %%   X: substrate        X_N: nitrogen      X_CH: carbo-hydrate
  %%   X_VA: struc autotr  m_EC: C-res dens   m_EN: N-res density
  %%   X_VH: struc hetero  m_E: res density

  global X_R X_RN n_N_X n_N_E n_N_VH n_N_VA
  
  tmax = 500; % set time period
  X_t = [X_R; X_RN; 0.00001; 0.00001; 1; 1; 0.00001; 1]; % initial state
  [t, X_t]  = ode23s ('dxt', [0, tmax], X_t);
  
  if exist('j')==1 % single plot mode
    switch j
	
      case 1
        plot (t, 100*X_t(:,5), 'b', t, X_t(:,k), '6', t, X_t(:,8), 'r');
        xlabel('time'); ylabel('reserves'); 

      case 2
        plot (t, X_t(:,1), 'r', t, X_t(:,2), 'b', t, X_t(:,3), 'k');
        xlabel('time'); ylabel('substrates');

      case 3
        plot (t, X_t(:,4), 'g', t, X_t(:,7), 'r');
        xlabel('time'); ylabel('structures');

      case 4
        Ntot = X_t(:,2) + n_N_X*X_t(:,1) + (n_N_VA + ...
         X_t(:,5)).*X_t(:,4) + (n_N_VH + n_N_E*X_t(:,8)).*X_t(:,7);

      	  Ctot = X_t(:,1) + X_t(:,3) + (1 + X_t(:,6)).*X_t(:,4) + ...
         (1+ X_t(:,8)).*X_t(:,7);
        plot (t, Ntot, 'b', t, Ctot, 'k');
        xlabel('time'); ylabel('total N, C');

      otherwise
	      return;

    end
  else % multiple plot mode
    
    subplot (2, 2, 1);
    plot (t, 100*X_t(:,5), 'b', t, X_t(:,6), 'k', t, X_t(:,8), 'r');
    xlabel('time'); ylabel('reserves'); 

    subplot (2, 2, 2);
    plot (t, X_t(:,1), 'r', t, X_t(:,2), 'b', t, X_t(:,3), 'k');
    xlabel('time'); ylabel('substrates');

    subplot (2, 2, 3);
    plot (t, X_t(:,4), 'g', t, X_t(:,7), 'r');
    xlabel('time'); ylabel('structures');

    subplot (2, 2, 4);
    Ntot = X_t(:,2) + n_N_X*X_t(:,1) + (n_N_VA + ...
         X_t(:,5)).*X_t(:,4) + (n_N_VH + n_N_E*X_t(:,8)).*X_t(:,7);
    Ctot = X_t(:,1) + X_t(:,3) + (1 + X_t(:,6)).*X_t(:,4) + ...
         (1+ X_t(:,8)).*X_t(:,7);
    plot (t, Ntot, 'b', t, Ctot, 'k');
    xlabel('time'); ylabel('total N, C');

  end

  