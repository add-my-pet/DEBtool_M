%% shtime_plant
% time_plots for 'plant'

%%
function shtime_plant(j)
  % created: 2000/09/26 by Bas Kooijman, modified 2009/01/05
  
  %% Syntax
  % <../shtime_plant.m *shtime_plant*> (j) 

  %% Description
  % time_plots for 'plant'
  %
  % Input:
  %
  % * j: optional scalar with plot number (default all)
  
  %% Remark
  % First run pars_plant; See <plant.hmtl *plant*>;
  
  global X T_1 T_A T_L T_H T_AL T_AH n_N_ENR n_N_ER;
  global M_VSd M_VSm M_VRd M_VRm M_VSb M_VRb M_VSp M_ER0;
  global k_C k_O k_ECS k_ENS k_ES k_ECR k_ENR k_ER rho_NO;
  global J_L_K K_C K_O K_NH K_NO K_H;
  global j_L_Am j_C_Am j_O_Am j_NH_Am j_NO_Am;
  global y_ES_CH_NO y_CH_ES_NO y_ER_CH_NO y_CH_ER_NO y_ER_CH_NH;
  global y_VS_ES y_ES_VS y_VR_ER y_ER_VR y_ES_ER y_ER_ES;
  global y_ES_ENS y_ENS_ES y_ER_ENR y_ENR_ER y_ENS_ENR y_ECR_ECS;
  global kap_ECS kap_ECR kap_ENS kap_ENR kap_SS;
  global kap_SR kap_RS kap_TS kap_TR;
  global j_ES_MS j_ER_MR j_ES_JS j_PS_MS j_PR_MR y_PS_VS y_PR_VR;
 
  tmax = 500; % select time period
  
% State vector:
%   M = [M_PS, M_VS, M_ECS, M_ENS, M_ES, M_PR, M_VR, M_ECR, M_ENR, M_ER]
  M0 = [0; 1e-4; 1e-4; 1e-4; 1e-4; 0; 1e-4; 1e-4; 1e-4; 10]; % initial value
  
  [t Mt]  = ode45(@flux_plant, [0; tmax], M0); % integrate
  
  if ~exist ('j','var') % single plot mode
     switch j
      case 1
        plot (t, Mt(:,2), 'g', t, -Mt(:,7), 'r', [0, tmax], [0, 0], 'k');
        xlabel('time, d'); ylabel('structures, mol'); 
      case 2
        plot (t, Mt(:,1), 'g', t, -Mt(:,6), 'r', [0, tmax], [0, 0], 'k');
        xlabel('time, d'); ylabel('products, mol');
      case 3
        plot (t, Mt(:,3), 'k', t, Mt(:,4), 'b', t, Mt(:,5), 'r', ...
	       t,-Mt(:,8), 'k', t,-Mt(:,9), 'b', t,-Mt(:,10), 'r', ...
	      [0, tmax], [0, 0], 'k');
        xlabel('time, d'); ylabel('reserves, mol');
      case 4
        m_ECR = Mt(:,8)./Mt(:,7); m_ENR = Mt(:,9)./Mt(:,7);
        m_ER = Mt(:,10)./Mt(:,7); m_ERm = max([m_ECR',m_ENR']);
    
        plot (t, Mt(:,3)./Mt(:,2), 'k', t, Mt(:,4)./Mt(:,2), 'b', ...
          t, Mt(:,5)./Mt(:,2), 'r', t, -m_ECR, 'k', t, -m_ENR, 'b', ... 
          t,-min(m_ER,m_ERm), 'r', ...
	       [0, tmax], [0, 0], 'k');
        xlabel('time'); ylabel('reserve densities, mol/mol');
      otherwise
        return;
    end
   
  else % multiple plot mode
    % multiplot (2, 2);
    subplot (2, 2, 1);
    plot (t, Mt(:,2), 'g', t, -Mt(:,7), 'r', [0, tmax], [0, 0], 'k');
    xlabel('time, d'); ylabel('structures, mol'); 

    subplot (2, 2, 2);
    plot (t, Mt(:,1), 'g', t, -Mt(:,6), 'r', [0, tmax], [0, 0], 'k');
    xlabel('time, d'); ylabel('products, mol');

    subplot (2, 2, 3);
    plot (t, Mt(:,3), 'k', t, Mt(:,4), 'b', t, Mt(:,5), 'r', ...
   	t,-Mt(:,8), 'k', t,-Mt(:,9), 'b', t,-Mt(:,10), 'r', ...
	  [0, tmax], [0, 0], 'k');
    xlabel('time, d'); ylabel('reserves, mol');

    subplot (2, 2, 4);
    m_ECR = Mt(:,8)./Mt(:,7); m_ENR = Mt(:,9)./Mt(:,7);
    m_ER = Mt(:,10)./Mt(:,7); m_ERm = max([m_ECR',m_ENR']);
    
    plot (t, Mt(:,3)./Mt(:,2), 'k', t, Mt(:,4)./Mt(:,2), 'b', ...
       t, Mt(:,5)./Mt(:,2), 'r', t, -m_ECR, 'k', t, -m_ENR, 'b', ... 
       t,-min(m_ER,m_ERm), 'r', ...
	  [0, tmax], [0, 0], 'k');
    xlabel('time'); ylabel('reserve densities, mol/mol');
     
    % multiplot(0,0);
  end