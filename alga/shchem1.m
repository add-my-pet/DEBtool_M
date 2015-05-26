function shchem (j)
  %  created: 2000/09/21 by Bas Kooijman, modified 2009/09/21
  global jT_EN_Am jT_EP_Am jT_EN_M jT_EP_M kT_E n_O y_N_EN y_P_EP
  global kap_EN kap_EP X_Nr X_N X_P X_Pr m_EN m_EP h y_EN_V y_EP_V


  %  set initial conditions
  X_N  = X_Nr; X_P = X_Pr;
  m_EN = (jT_EN_Am - kap_EN*jT_EN_M)/((1 - kap_EN)*kT_E);
  m_EP = (jT_EP_Am - kap_EP*jT_EP_M)/((1 - kap_EP)*kT_E);
  m = fminsearch('findm',[m_EN m_EP]); m_EN = m(1); m_EP = m(2);
  a = (m_EN * kT_E  - jT_EN_M)/ y_EN_V;
  b = (m_EP * kT_E  - jT_EP_M)/ y_EP_V;
  r = 1/ (1/ a + 1/ b - 1/ (a + b));
  r  = fminsearch('findrm',[r, m]);
  h = r(1); h_m = r(1); % 1/d, max throughput rate

  nh = 100; H = linspace(1e-6, h_m, nh);  % 1/d, throuphput rates
  X = zeros(nh,7);                        %  initialize plot data
  %  X: (1)=X_N, (2)=X_DN (3)=X_P (4)=X_DP (5)=m_EN (6)=m_EP (7)=X_V
  X0 = [X_N 0 X_P 0 r(2) r(3) 1e-8]';      % first guess at h_m
  X0 = newton('dchem1',X0,1000,0.01);      % we start at h = h_m
  X(nh,:) = X0'; X0(7)=0.01;           % increase X_V to help convergence
  
  for i= 1:(nh-1)                            % and work back to h = 0
    h = H(nh-i);                             % 1/d, throughput rate
    X0 = newton('dchem1',X0,1000,10);        % fill plot data
    X(nh-i,:) = X0';
  end
  
  %  clg; hold on; gset nokey;
 
  if exist('j','var') == 1 % single-plot mode
    %% multiplot(0,0); clg;
 
    switch j

      case 1         
        plot(H, X(:,1), 'b', H, X(:,2), '.b');
        title ('ammonia & excreted N-reserve');
        xlabel('throughput rate, 1/d'); ylabel('ammonia, M');

      case 2
        plot(H, X(:,3),'r', H, X(:,4), '.r');
        title ('phospate & excreted P-reserve');
        xlabel('throughput rate, 1/d'); ylabel('phosphate, M');

      case 3
	     plot(H, (X(:,1) + y_N_EN*X(:,2)), 'b', ...
	       H, (X(:,3) + y_P_EP*X(:,4)), 'r');
	     title ('total ammonia & phospate in medium');
	     xlabel('throughput rate, 1/d'); ylabel('amm & phos, M');

      case 4
        plot(H, X(:,7), 'g');
        title ('structure');
        xlabel('throughput rate, 1/d'); ylabel('structure, M');

      case 5
        plot(H, X(:,5), 'b', H, X(:,6), 'r');
        title ('N-, P-reserve density');
        xlabel('throughput rate, 1/d'); ylabel('res dens, mol/mol');

      case 6
	     plot(H, (n_O(4,1) + n_O(4,2)*X(:,5)), 'b', ...
	       H, (n_O(4,1) + n_O(4,2)*X(:,6)), 'r');
	     title ('N/C & P/C in biomass');
	     xlabel('throughput rate, 1/d'); ylabel('N/C & P/C, mol/mol');

      otherwise
        plot(H, X(:,7), 'g');
        title ('structure');
        xlabel('throughput rate, 1/d'); ylabel('structure, M');
    
    end

  else % multi-plot mode
    %% top_title ('Chemostat culture'); does not seem to work

    subplot(2, 3, 1);
    plot(H, X(:,1), 'b', H, X(:,2), '.b');
    title ('ammonia & excreted N-reserve');
    xlabel('throughput rate, 1/d'); ylabel('ammonia, M');

    subplot(2, 3, 2);
    plot(H, X(:,3),'r', H, X(:,4), '.r');
    title ('phospate & excreted P-reserve');
    xlabel('throughput rate, 1/d'); ylabel('phosphate, M');

    subplot(2, 3, 3);
    plot(H, (X(:,1) + y_N_EN*X(:,2)), 'b', ...
	    H, X(:,3) + y_P_EP*X(:,4), 'r');
    title ('total ammonia & phospate in medium');
    xlabel('throughput rate, 1/d'); ylabel('amm & phos, M');

    subplot(2, 3, 4);
    plot(H, X(:,7), 'g');
    title ('structure');
    xlabel('throughput rate, 1/d'); ylabel('structure, M');

    subplot(2, 3, 5);
    plot(H, X(:,5), 'b', H, X(:,6), 'r');
    title ('reserve density');
    xlabel('throughput rate, 1/d'); ylabel('res dens, mol/mol');

    subplot(2, 3, 6);
    plot(H, (n_O(4,1) + n_O(4,2)*X(:,5)), 'b', ...
	    H, (n_O(4,1) + n_O(4,2)*X(:,6)), 'r');
    title ('N/C & P/C in biomass');
    xlabel('throughput rate, 1/d'); ylabel('N/C & P/C, mol/mol');

  end
  
