function shtime6a (j)
  %% created: 2001/09/10 by Bas Kooijman; modified 2009/09/29
  %% time_plots for 'endosym'
  %% State vector:
  %% (1,2)structure V, reserve density m of species 1
  %% (3,4)structure V, reserve density m of species 2 internal

  global h1_V h2_V ...  % hazard rates
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P ... % binding probabilities
      y1_EV y2_EV ... % costs for structure
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global m1 m2 V1 V2 r1 r2;
  
  opt=optimset('display','off');

  tmax = 100; % set time max
  pars6a; % set parameter values
  V1 = 1; V2 = 0.1;
  [j_E, val, info] = fsolve('findj_epi6a',[k1 k2],opt);
  m1 = j_E(1)/k1_E; m2 = j_E(2)/k2_E;
  %% m1=m2=.1;
  istate = [V1, m1, V2, m2];
  
  [t, X_t]  = ode23s ('dstate6a', [0, tmax]', istate);
  R1 = (k1_E*X_t(:,2) - k1_M*y1_EV)./(X_t(:,2) + y1_EV); % spec growth rate
  R2 = (k2_E*X_t(:,4) - k2_M*y2_EV)./(X_t(:,4) + y2_EV); % spec growth rate

  V1 = 1; V2 = 1;
  [j_E, val, info] = fsolve('findj_epi6a',[k1 k2],opt);
  m1 = j_E(1)/k1_E; m2 = j_E(2)/k2_E;
  %% m1=m2=.1;
  istate = [V1, m1, V2, m2];
  
  [t, X1_t]  = ode23s ('dstate6a', [0, tmax]', istate);
  R11 = (k1_E*X1_t(:,2) - k1_M*y1_EV)./(X1_t(:,2) + y1_EV); % spec growth rate
  R21 = (k2_E*X1_t(:,4) - k2_M*y2_EV)./(X1_t(:,4) + y2_EV); % spec growth rate

  V1 = 1; V2 = 10;
  [j_E, val, info] = fsolve('findj_epi6a',[k1 k2],opt);
  m1 = j_E(1)/k1_E; m2 = j_E(2)/k2_E;
  %% m1=m2=.1;
  istate = [V1, m1, V2, m2];
  
  [t, X2_t]  = ode23s ('dstate6a', [0, tmax]', istate);
  R12 = (k1_E*X2_t(:,2) - k1_M*y1_EV)./(X2_t(:,2) + y1_EV); % spec growth rate
  R22 = (k2_E*X2_t(:,4) - k2_M*y2_EV)./(X2_t(:,4) + y2_EV); % spec growth rate
  rmin=min([R1 R2 R11 R21 R12 R22]); rmax=max([R1 R2 R11 R21 R12 R22]);
   
  if exist('j','var')==1 % single plot mode
   clf;
   switch j
	
      case 1
        plot (t, log(X_t(:,1)), 'g', t, log(X_t(:,3)), 'g', ...
	      t, log(X1_t(:,1)), 'r', t, log(X1_t(:,3)), 'r', ...
	      t, log(X2_t(:,1)), 'b', t, log(X2_t(:,3)), 'b');
        xlabel('time'); ylabel('ln structures'); 

      case 2
        plot (t, X_t(:,2), 'g', t, X_t(:,4), 'g', ...
	      t, X1_t(:,2), 'r', t, X1_t(:,4), 'r', ...
	      t, X2_t(:,2), 'b', t, X2_t(:,4), 'b');
        xlabel('time'); ylabel('reserves'); 
	
      case 3
        plot (t, X_t(:,3)./X_t(:,1), 'g', ...
	      t, X1_t(:,3)./X1_t(:,1), 'r', ...
	      t, X2_t(:,3)./X2_t(:,1), 'b');
        xlabel('time'); ylabel('ratio');

      case 4
        plot (R1, R2, 'g', R11, R21, 'r', R12, R22, 'b', ...
	      [rmin rmax], [rmin rmax], 'r');
        xlabel('spec growth rate 1'); ylabel('spec growth rate 2');
	
      otherwise
	return;

    end
  else % multiple plot mode
    %% multiplot(2, 2);
    
        subplot (2, 2, 1);
        plot (t, log(X_t(:,1)), 'g', t, log(X_t(:,3)), 'r');
        xlabel('time'); ylabel('ln structures'); 

        subplot (2, 2, 2);
        plot (t, X_t(:,2), 'g', t, X_t(:,4), 'r');
        xlabel('time'); ylabel('reserves'); 

        subplot (2, 2, 3);
        plot (t, X_t(:,3)./X_t(:,1), 'g');
        xlabel('time'); ylabel('ratio');

        subplot (2, 2, 4);
        plot (r1, r2, 'g', [0 0.4], [0 0.4], 'r');
        xlabel('spec growth rate 1'); ylabel('spec growth rate 2');

    %% multiplot (0, 0);
  end