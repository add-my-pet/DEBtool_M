function shmcn_lm(j)
  %  created: 2007/01/19 by Bas Kooijman, modified 2009/09/21
  %
  %% Description
  %  Sets parameters and produces plots; mcn does the computation
  %  V1-morphs with 1 structure and C and N reserves
  %  Light, DIC and DIN are specified as forcing spline functions (plot 1)
  %  reserve densities for C and N are obtained by integration    (plot 2)
  %  excreted reserve fluxes are obtained from reserve densities  (plot 3)
  %  specific growth rates are obtained from reserve densities    (plot 4)
  %  notice that apart from excreted reserves, other products are produced
  %    as overheads of assimilation, maintenance and growth
  %    in case of shrinking other products might be produced as well
  % 
  %% Input
  %  j: optional scalar with plot number
  %  if specified, other plots will be suppresssed
  %
  %% Output
  %  plots
  %
  %% Remarks
  %  like shmcn, but extended with the leak and Morel model,
  %    which has 2 max assimilation pars for each nutrient
  %
  %% Example of use
  %  shmcn_lm

  %% Code
  
  %  set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  p = [0.2; % -, z_C weight coefficient for DIC relative to light
       0.5; % mol/mol.h, j_EC_Am max spec C-assimilation
       1.5; % mol/mol.h, j_EC_AM max spec C-assimilation
       0.1; % mol/mol.h, j_EN_Am max spec N-assimilation
       0.3; % mol/mol.h, j_EN_AM max spec N-assimilation
       1.2; % mol/mol, y_EC_V yield of C-reserve on structure
       0.2; % mol/mol, y_EN_V yield of N-reserve on structure
       0.01;% mol/mol.h, j_EC_M spec maint flux paid from C-reserve
       0.002;% mol/mol.h, j_EN_M spec maint flux paid from N-reserve
       0.1; % 1/h, k_E reserve turnover rate
       0.8; % -, kap_EC fraction of rejected C-reserve to C-reserve
       0.9];% -, kap_EN fraction of rejected N-reserve to N-reserve
  t = (0:96)'; % h, time points for evaluation
  te = 12 * (0:8)'; % h, time-knots for splines
  tLCN = [te, wrap([5 .2],9,1), ...  % light as multiple of half sat flux
	  wrap([8 7 6 4 4 3 .2 4 6],9,1), ... % DIC as multiple of half sat conc 
	  wrap([.1 3 .3 1],9,1)];          % DIN as multiple of half sat conc
  tLCN = [te, wrap([.1],9,1), ...  % light as multiple of half sat flux
	  wrap([.1],9,1), ... % DIC as multiple of half sat conc 
	  wrap([10],9,1)];          % DIN as multiple of half sat conc
  %% in this schedule the algae migrate to the deep at night to get N
  mcn0 = [2.5;0.5]; % mol/mol, initial reserve densities for C and N
    
  tmrj = mcn_lm(t,p,tLCN,mcn0); % get time trajectories %%%%%%%%%%%%%%%%%%%%

  clf; %% start plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (exist('j','var') == 1) % single-plot mode
    switch j  

    case 1; clf;
    tL = [t, spline(t,tLCN(:,[1 2]))];
    tC = [t, spline(t,tLCN(:,[1 3]))];
    tN = [t, spline(t,tLCN(:,[1 4]))];
    plot (tL(:,1), tL(:,2), '-g', ...
	  tC(:,1), tC(:,2), '-r', ...
	  tN(:,1), tN(:,2), '-b');
    legend('light', 'DIC', 'DIN');
    xlabel('time, h');
    ylabel('scaled conc,flux')
  
    case 2; clf;
    plot(tmrj(:,1), tmrj(:,2), '-r', ...
	 tmrj(:,1), tmrj(:,3), '-b', ...
	 tmrj(:,1), tmrj(:,7), '-m', ...
	 tmrj(:,1), tmrj(:,12), '-y', ...
	 tmrj(:,1), tmrj(:,8), '-m', ...
	 tmrj(:,1), tmrj(:,13), '-y');
    legend('C-reserve', 'N-reserve', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('reserve density, mol/mol')
  
    case 3; clf; 
    plot(tmrj(:,1), tmrj(:,5), '-r', ...
	 tmrj(:,1), tmrj(:,6), '-b', ...
	 tmrj(:,1), tmrj(:,10), '-m', ...
	 tmrj(:,1), tmrj(:,15), '-y', ...
	 tmrj(:,1), tmrj(:,11), '-m', ...
	 tmrj(:,1), tmrj(:,16), '-y');
    legend('C-reserve', 'N-reserve', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('excretion, mol/mol.h')

    case 4; clf;
    plot(tmrj(:,1),tmrj(:,4),'-g', ...
         tmrj(:,1),tmrj(:,9),'-m', ...
	 tmrj(:,1),tmrj(:,14),'-y');
    legend('standard', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('spec growth rate, 1/h')

    otherwise
    return;
    end
  
  else % multi-plot mode
  
    subplot(2,2,1);
    tL = [t, spline(t,tLCN(:,[1 2]))];
    tC = [t, spline(t,tLCN(:,[1 3]))];
    tN = [t, spline(t,tLCN(:,[1 4]))];
    plot (tL(:,1), tL(:,2), '-g', ...
	  tC(:,1), tC(:,2), '-r', ...
	  tN(:,1), tN(:,2), '-b');
    legend('light', 'DIC', 'DIN');
    xlabel('time, h');
    ylabel('scaled conc,flux')
  
    subplot(2,2,2);
    plot(tmrj(:,1), tmrj(:,2), '-r', ...
	 tmrj(:,1), tmrj(:,3), '-b', ...
	 tmrj(:,1), tmrj(:,7), '-m', ...
	 tmrj(:,1), tmrj(:,12), '-y', ...
	 tmrj(:,1), tmrj(:,8), '-m', ...
	 tmrj(:,1), tmrj(:,13), '-y');
    legend('C-reserve', 'N-reserve', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('reserve density, mol/mol')
 
    subplot(2,2,3);
    plot(tmrj(:,1), tmrj(:,5), '-r', ...
	 tmrj(:,1), tmrj(:,6), '-b', ...
	 tmrj(:,1), tmrj(:,10), '-m', ...
	 tmrj(:,1), tmrj(:,15), '-y', ...
	 tmrj(:,1), tmrj(:,11), '-m', ...
	 tmrj(:,1), tmrj(:,16), '-y');
    legend('C-reserve', 'N-reserve', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('excretion, mol/mol.h')

    subplot(2,2,4);
    plot(tmrj(:,1),tmrj(:,4),'-g', ...
         tmrj(:,1),tmrj(:,9),'-m', ...
	 tmrj(:,1),tmrj(:,14),'-y');
    legend('standard', 'leak-model', 'Morel-model');
    xlabel('time, h');
    ylabel('spec growth rate, 1/h')
 
  end
