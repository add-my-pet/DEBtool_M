function J = flux_plant (t, M)
  %% created: 2002/04/09 by Bas Kooijman
  %% subroutine for 'plant'; See: Kooijman 2000: page 181
  %% requires routine 'findr', using parameters par1, par2
  
  global par1 par2;
  global X T_1 Tpars n_N_ENR n_N_ER;
  global M_VSd M_VSm M_VRd M_VRm M_VSb M_VRb M_VSp;
  global k_C k_O k_ECS k_ENS k_ES k_ECR k_ENR k_ER rho_NO;
  global J_L_K K_C K_O K_NH K_NO K_H;
  global j_L_Am j_C_Am j_O_Am j_NH_Am j_NO_Am;
  global y_ES_CH_NO y_CH_ES_NO y_ER_CH_NO y_CH_ER_NO y_ER_CH_NH;
  global y_VS_ES y_ES_VS y_VR_ER y_ER_VR y_ES_ER y_ER_ES;
  global y_ES_ENS y_ENS_ES y_ER_ENR y_ENR_ER y_ENS_ENR y_ECR_ECS;
  global kap_ECS kap_ECR kap_ENS kap_ENR kap_SS;
  global kap_SR kap_RS kap_TS kap_TR;
  global j_ES_MS j_ER_MR j_ES_JS j_PS_MS j_PR_MR y_PS_VS y_PR_VR;

  %% unpack state vector; we do not want to remember the order 
  M_PS = M(1); M_VS = M(2); M_ECS = M(3); M_ENS = M(4); M_ES = M(5);
    M_PR = M(6); M_VR = M(7); M_ECR = M(8); M_ENR = M(9); M_ER = M(10);
  %% assign reserve densities to compact notation
  m_ECS = M_ECS/M_VS; m_ENS = M_ENS/M_VS; m_ES = M_ES/M_VS;
    m_ECR = M_ECR/M_VR; m_ENR = M_ENR/M_VR; m_ER = M_ER/M_VR;
    
  %% unpack environmental conditions; we do not want to remember the order 
  J_L_F = X(1); X_C = X(2); X_O = X(3); X_NH = X(4); X_NO = X(5);
    X_H = X(6); T = X(7);

  %% relationship between active surface area and structural mass
  A_S = (M_VS/M_VSd)^(-M_VS/M_VSm); % dimensionless shoots' surface area/mass
  A_R = (M_VR/M_VRd)^(-M_VR/M_VRm); % dimensionless roots'  surface area/mass
 
  %% temperature correction that affects all rates;
  TC = tempcorr(T, T_1, Tpars); % temperature correction factor
   
  %% we do not start with assimilation, because roots' assimilation
  %%   depends on shoots' catabolism and vice versa. Skew symmetry exists.
  
  %% shoots' growth and catabolism 
  par1 = [y_CH_ES_NO, y_VS_ES, y_ENS_ES, kap_SS, k_ES, k_ECS, k_ENS, j_ES_MS];
  par2 = [A_S, m_ECS, m_ENS, m_ES];
  r_S = fzero('findr', findr(0),[]);  % specific growth rate (1/time)
  J_VS_GS = r_S*M_VS;              % growth flux (mol/time)
  J_ES_C1S = (A_S*k_ES - r_S)*M_ES;% catabolic rate from reserve
  J1_ECS_CS = (A_S*k_ECS - r_S)*M_ECS; % catabolic rate from C-reserve
  J1_ENS_CS = (A_S*k_ENS - r_S)*M_ENS; % catabolic rate from N-reserve
  J_ES_C2S = 1/(1/(y_ES_ENS*J1_ENS_CS) + 1/(y_ES_CH_NO*J1_ECS_CS) - ...
		1/(y_ES_ENS*J1_ENS_CS + y_ES_CH_NO*J1_ECS_CS));
				   % catabolic rate derived from C,N-reserves
  J_ES_CS = J_ES_C1S + J_ES_C2S;   % total catabolic flux
  theta_ES = J_ES_C1S/J_ES_CS;     % fraction of reserves in catabolic rate
  J_ES_GS = -y_ES_VS*J_VS_GS*theta_ES;           %   reserve drain due to growth
  J_ECS_GS = y_CH_ES_NO*J_ES_GS*(1/theta_ES - 1);% C-reserve drain due to growth
  J_ENS_GS = y_ENS_ES  *J_ES_GS*(1/theta_ES - 1);% N-reserve drain due to growth
  J_ECS_RS = J1_ECS_CS - y_CH_ES_NO*J_ES_C2S;    % rejected catabolised C-reserve
  J_ENS_RS = J1_ENS_CS - y_ENS_ES*J_ES_C2S;      % rejected catabolised N-reserve

  %% shoots' maintenance and dissipation
  J_ES_MS = -j_ES_MS*M_VS;               % somatic  maintenance costs
  J_ES_JS = -j_ES_JS*min(M_VS, M_VSp);   % maturity maintenance costs
  J_ES_DS = theta_ES*(J_ES_MS + J_ES_JS);% drain from reserve due to maintenance
  J_ECS_DS = y_CH_ES_NO*J_ES_DS*(1/theta_ES - 1);
                                         % drain from C-reserve due to maintenance
  J_ENS_DS = y_ENS_ES*J_ES_DS*(1/theta_ES - 1) - (1 - kap_ENS)*J_ENS_RS;
                                         % drain from N-reserve due to maintenance

  %% development/reproduction (affects shoot)
  J_ES_R = -theta_ES*(kap_RS*J_ES_CS + J_ES_JS); % drain from   reserve
  J_ECS_R = y_CH_ES_NO*J_ES_R*(1/theta_ES - 1);  % drain from C-reserve
  J_ENS_R = y_ENS_ES*J_ES_R*(1/theta_ES - 1);    % drain from N-reserve

  %% roots' growth and catabolism
  par1 = [y_CH_ER_NO, y_VR_ER, y_ENR_ER, kap_SR, k_ER, k_ECR, k_ENR, j_ER_MR];
  par2 = [A_R, m_ECR, m_ENR, m_ER];
  r_R = fzero('findr', findr(0)); % specific growth rate (1/time)
  J_VR_GR = r_R*M_VR;              % growth flux (mol/time)
  J_ER_C1R = (A_R*k_ER - r_R)*M_ER;% catabolic rate from reserve
  J1_ECR_CR = (A_R*k_ECR - r_R)*M_ECR; % catabolic rate from C-reserve
  J1_ENR_CR = (A_R*k_ENR - r_R)*M_ENR; % catabolic rate from N-reserve
  J_ER_C2R = 1/(1/(y_ER_ENR*J1_ENR_CR) + 1/(y_ER_CH_NO*J1_ECR_CR) - ...
		1/(y_ER_ENR*J1_ENR_CR + y_ER_CH_NO*J1_ECR_CR)); 
				   % catabolic rate derived from C,N-reserves
  J_ER_CR = J_ER_C1R + J_ER_C2R;   % total catabolic rate
  theta_ER = J_ER_C1R/J_ER_CR;     % fraction of reserves in catabolic rate
  J_ER_GR = - y_ER_VR*J_VR_GR*theta_ER;          %   reserve drain due to growth
  J_ECR_GR = y_CH_ER_NO*J_ER_GR*(1/theta_ER - 1);% C-reserve drain due to growth
  J_ENR_GR = y_ENR_ER*J_ER_GR  *(1/theta_ER - 1);% N-reserve drain due to growth
  J_ECR_RR = J1_ECR_CR - y_CH_ER_NO*J_ER_C2R;    % rejected catabolised C-reserve
  J_ENR_RR = J1_ENR_CR - y_ENR_ER*J_ER_C2R;      % rejected catabolised N-reserve

  %% roots' maintenance and dissipation
  J_ER_MR = - j_ER_MR*M_VR;        % somatic maintenance costs
  J_ER_DR = theta_ER*J_ER_MR;      % drain from   reserve due to maintenance
  J_ECR_DR = y_CH_ER_NO*(1 - theta_ER)*J_ER_MR - (1 - kap_ECR)*J_ECR_RR;
                                   % drain from C-reserve due to maintenance
  J_ENR_DR = y_ENR_ER*(1 - theta_ER)*J_ER_MR;
                                   % drain from N-reserve due to maintenance

  %% translocation of reserves between root and shoot
  J_ECS_T = - kap_TS*y_CH_ES_NO*J_ES_C2S; % C-reserve from shoot to root
  J_ENS_T = - kap_TS*y_ENS_ES  *J_ES_C2S; % N-reserve from shoot to root
  J_ES_T  = - kap_TS*J_ES_C1S + y_ES_ER*kap_TR*J_ER_CR;
				% reserve from shoot to root
  J_ER_T  = - kap_TR*J_ER_C1R + y_ER_ES*kap_TS*J_ES_CS;
                                % reserve from root to shoot
  J_ECR_T = - kap_TR*y_CH_ER_NO*J_ER_C2R; % C-reserve from root to shoot
  J_ENR_T = - kap_TR*y_ENR_ER  *J_ER_C2R; % N-reserve form root to shoot

  %% production
  J_PS_GS = J_VS_GS*y_PS_VS; % production associated to shoots' growth
  J_PS_DS = M_VS*j_PS_MS;    % production associated to shoots' maintenance
  J_PR_GR = J_VR_GR*y_PR_VR; % production associated to roots' growth
  J_PR_DR = M_VR*j_PR_MR;    % production associated to roots' maintenance
  
  %% shoots' assimilation
  if M_VS>M_VSb
    j1_L = j_L_Am/(1 + J_L_K/J_L_F); % arriving useful photons
    j1_C = j_C_Am/(1 + K_C/X_C);     % arriving carbon dioxide
    j1_O = j_O_Am/(1 + K_O/X_O);     % arriving oxygen
    J1_ECS_AS = (j1_C - j1_O)*M_VS*A_S/(1 + j1_C/k_C + j1_O/k_O + ...
       (j1_C + j1_O)/j1_L - (j1_C + j1_O)/(j1_L + j1_C + j1_O));
				   % assimilated C-reserve 
    J_ENR_AS = (kap_ENR - 1)*J_ENR_RR;   % translocated roots' N-reserve from root
    J1_ENS_AS = - y_ENS_ENR*J_ENR_AS;    % arriving shoots' N-reserve from root
    J_ES_AS = 1/(1/(y_ES_ENS*J1_ENS_AS) + 1/(y_ES_CH_NO*J1_ECS_AS) - ...
	       1/(y_ES_ENS*J1_ENS_AS + y_ES_CH_NO*J1_ECS_AS));
                                             % assimilated   reserve
    J_ENS_AS = J1_ENS_AS - y_ENS_ES * J_ES_AS; % assimilated N-reserve 
    J_ECS_AS = J1_ECS_AS - y_CH_ES_NO*J_ES_AS; % assimilated C-reserve
  else
    J_ECS_AS = 0; J_ENS_AS = 0; J_ES_AS = 0; J_ENR_AS = 0;
  end
  
  %% roots' assimilation
  if M_VR > M_VRb
    K1_NH = K_NH/(1 + X_H*A_S/(K_H*A_R)); 
				% ammonia saturation as affected by water
    J1_NH_AR = M_VR*A_R*j_NH_Am/(1 + K1_NH/X_NH); 
				% arriving ammonia
    K1_NO = K_NO/(1 + X_H*A_S/(K_H*A_R));
 				% nitrate saturation as affected by water
    J_NO_AR  = M_VR*A_R*j_NO_Am/(1 + K1_NO/X_NO); 
				% arriving nitrate
    J_N_AR = J1_NH_AR + rho_NO*J_NO_AR; % total arriving N flux
    theta_NH = J1_NH_AR/(J1_NH_AR + rho_NO*J_NO_AR);
				% fraction of ammonia in arriving N-flux
    theta_NO = 1 - theta_NH;      % fraction of nitrate in arriving N-flux
    y_ER_CH = theta_NH*y_ER_CH_NH + theta_NO*y_ER_CH_NO; y_CH_ER = 1/y_ER_CH;
				% yield coefficient from C-reserve to reserve
    J_ECS_AR = (kap_ECS - 1)*J_ECS_RS; % translocated shoots' C-reserve from shoot
    J1_ECR_AR = - y_ECR_ECS*J_ECS_AR;  % arriving root's C-reserve from shoot
    J_ER_AR = 1/(n_N_ER/J_N_AR + 1/(y_ER_CH*J1_ECR_AR) - ...
	       1/(J_N_AR/n_N_ER + y_ER_CH*J1_ECR_AR));
                                  % assimilated reserve
    J_ECR_AR = J1_ECR_AR - y_CH_ER*J_ER_AR;                 % assimilated C-reserve
    J_ENR_AR = (J_NO_AR - n_N_ER*theta_NO*J_ER_AR)/n_N_ENR; % assimilated N-reserve
  else
    J_ECR_AR = 0; J_ENR_AR = 0; J_ER_AR = 0; J_ECS_AR = 0;
  end
  
  %% compose flux matrix J (all elements represent molar fluxes)
  %%   see p180 of DEB-book
  %%   rows: compounds (states)
  %%     PS, VS, ECS, ENS, ES, PR, VR, ECR, ENR, ER
  %%     shoots' product, structure, C-reserve, N-reserve, reserve
  %%     roots'  product, structure, C-reserve, N-reserve, reserve
  %%   columns: transformations
  %%     AS, GS, DS, R, T, AR, GR, DR
  %%     shoots' assimilation, growth, dissipation, development/reproduction
  %%     translocation, roots' assimilation, growth, dissipation
  J = zeros(10,8); 
  J(:,1) = [0;0;J_ECS_AS;J_ENS_AS;J_ES_AS;0;0;0;J_ENR_AS;0];        % S-assim
  J(:,2) = [J_PS_GS;J_VS_GS;J_ECS_GS;J_ENS_GS;J_ES_GS;0;0;0;0;0];   % S-growth
  J(:,3) = [J_PS_DS;0;J_ECS_DS;J_ENS_DS;J_ES_DS;0;0;0;0;0];         % S-dissip
  J(:,4) = [0;0;J_ECS_R;J_ENS_R;J_ES_R;0;0;0;0;0];                  % S-reprod
  J(:,5) = [0;0;J_ECS_T;J_ENS_T;J_ES_T;0;0;J_ECR_T;J_ENR_T;J_ER_T]; % transloc
  J(:,6) = [0;0;J_ECS_AR;0;0;0;0;J_ECR_AR;J_ENR_AR;J_ER_AR];        % R-assim
  J(:,7) = [0;0;0;0;0;J_PR_GR;J_VR_GR;J_ECR_GR;J_ENR_GR;J_ER_GR];   % R-growth
  J(:,8) = [0;0;0;0;0;J_PR_DR;0;J_ECR_DR;J_ENR_DR;J_ER_DR];         % R-dissip

  %% We sum here across transformations, and throw away information
  %%   that is required to evaluate mineral fluxes.
  %% Future implementations might use this information
  J = sum(J.').';