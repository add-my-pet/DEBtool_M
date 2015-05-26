function shcycle (j)
  %  created: 2002/03/03 by Bas Kooijman, modified 2009/09/21
  %  simultaneous growth limitation by nutrients N and P
  %  time-dependent nutrient concentrations are parameterized 
  %  plots are given for different reserve turnover rates
  %   large turnover rates imply small the reserve capacities

  global X0_N X1_N t0_N t1_N X0_P X1_P t0_P t1_P power r; % time-dep nutrients
  global k_E kT_E; % reserve turnover rate (vector and scalar)

  pars_cycle; % set parameter values

  X0 = [1 1 1e-4]; % set initial conditions: N- and P-reserve, structure

  tmax = 150; nt = 200; t = linspace (0, tmax, nt); % set time-points
  
  %  set nutrient concentrations
  %    here only for plotting; these functions also occur in dcycle
  X_N = X0_N + X1_N * (1 + sin((t-t0_N)/t1_N)).^power;
  X_P = X0_P + X1_P * (1 + sin((t-t0_P)/t1_P)).^power;

  clf; hold on;

  if (exist('j', 'var') == 1)
    if j == 1
      %% gset title 'Nutrients';
      xlabel('time, d'); ylabel('nutrient, M');
      plot(t, X_N, 'r', t, X_P, 'b');
      return;
    end
  else
    % multi-plot mode
    
    subplot(2, 2, 1);
    %% gset title 'Nutrients';
      plot(t, X_N, 'r', t, X_P, 'b');
      xlabel('time, d'); ylabel('nutrient, M');
  end

  nk = max(size(k_E)); Xt=zeros(nt,3*nk);
  for i = 1:nk  
    %% integrate state variables for different reserve turnover rates
    r = 0; % initiate spec growth rate for continuation
    kT_E = k_E(i); [t Xt(:,(i-1)*3 + (1:3))] = ode23s ('dcycle', t, X0); 
  end
  
    if exist('j', 'var') == 1 % single-plot mode
 
      switch j

      case 2
        %% gset title 'Reserves';
	    for i = 1:nk
          plot(t, Xt(:,(i-1)*3 + 1),'r', t, Xt(:,(i-1)*3 + 2), 'b');
        end
        xlabel('time, d'); ylabel('reserve density, mol/mol');

      case 3
        %% gset title 'Structure';
	    for i = 1:nk
          if i == 1
            plot(t, log(Xt(:,(i-1)*3 + 3)), 'b');
          elseif i == nk
	        plot(t, log(Xt(:,(i-1)*3 + 3)), 'r');
          else
	        plot(t, log(Xt(:,(i-1)*3 + 3)), 'g');
	      end
        xlabel('time, d'); ylabel('log structure, M');
      end
     
      otherwise
        return;
      end
    
    else % multi-plot mode 

      subplot(2, 2, 2); hold on
      %  gset title 'Reserves';
      for i = 1:nk
        plot(t, Xt(:,(i-1)*3 + 1),'r', t, Xt(:,(i-1)*3 + 2), 'b');
      end
      xlabel('time, d'); ylabel('reserve density, mol/mol');

      subplot(2, 2, 3); hold on 
      %  gset title 'Structure';
      for i = 1:nk
        if i == 1
          plot(t, log(Xt(:,(i-1)*3 + 3)), 'b');
        elseif i == nk
	      plot(t, log(Xt(:,(i-1)*3 + 3)), 'r');
        else
	      plot(t, log(Xt(:,(i-1)*3 + 3)), 'g');
        end
      end
      xlabel('time, d'); ylabel('log structure, M');
      
    end
