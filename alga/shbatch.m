function shbatch (j)
  %  created: 2000/09/21 by Bas Kooijman, modified 2009/09/21
  global jT_EN_Am jT_EP_Am jT_EN_M jT_EP_M kT_E r y_EN_V y_EP_V
  global kap_EN kap_EP X_Nr X_N X_P X_Pr h h_X h_V m_EN m_EP
  
  h_X = 0; h_V = 0; h = 0; % 1/d, batch culture

  %  set initial conditions
  X_N  = X_Nr; X_P = X_Pr;
  m_EN = (jT_EN_Am - kap_EN*jT_EN_M)/((1 - kap_EN)*kT_E);
  m_EP = (jT_EP_Am - kap_EP*jT_EP_M)/((1 - kap_EP)*kT_E);
  m = fminsearch('findm',[m_EN m_EP]); m_EN = m(1); m_EP = m(2);
  a = (m_EN * kT_E  - jT_EN_M)/ y_EN_V;
  b = (m_EP * kT_E  - jT_EP_M)/ y_EP_V;
  r = 1/ (1/ a + 1/ b - 1/ (a + b));
  r  = fminsearch('findrm',[r, m]);
  X0 = [X_N 0 X_P 0 r(2) r(3) 1e-4]';
  
  tmax = 150; % maximum time
  r = 0; % initiate spec growth rate for continuation
  [t, Xt] = ode23s ('dbatch', [0, tmax], X0); % integrate state variables

  clf
 
  if exist('j','var') == 1 % single-plot mode
 
 
    switch j

      case 1         
      plot(t, Xt(:,1), 'b', t, Xt(:,2), '.b');
      title ('ammonia & excreted N-reserve');
      xlabel('time, d'); ylabel('ammonia, M');

      case 2
      plot(t, Xt(:,3),'r', t, Xt(:,4), '.r');
      title ('phospate & excreted P-reserve');
      xlabel('time, d'); ylabel('phosphate, M');
      
      case 3
      plot(t, Xt(:,7), 'g');
      title ('structure density');
      xlabel('time, d'); ylabel('structure, M');

      case 4
      plot(t, Xt(:,5), 'b', t, Xt(:,6), 'r');
      title ('N-, P-reserve density');
      xlabel('time, d'); ylabel('res dens, mol/mol');

      otherwise
      plot(t, Xt(:,7), 'g');
      title ('structure density');
      xlabel('time, d'); ylabel('structure, M');
    
    end

  else % multi-plot mode
    %% top_title ('Batch culture'); does not seem to work

    subplot(2, 2, 1); 
    plot(t, Xt(:,1), 'b', t, Xt(:,2), '.b');
    title ('ammonia & excreted N-reserve');
    xlabel('time, d'); ylabel('ammonia, M');

    subplot(2, 2, 2); 
    plot(t, Xt(:,3),'r', t, Xt(:,4), '.r');
    title ('phospate & excreted P-reserve');
    xlabel('time, d'); ylabel('phosphate, M');

    subplot(2, 2, 3); 
    plot(t, Xt(:,7), 'g');
    title ('structure density');
    xlabel('time, d'); ylabel('structure, M');

    subplot(2, 2, 4); 
    plot(t, Xt(:,5), 'b', t, Xt(:,6), 'r');
    title ('reserve density');
    xlabel('time, d'); ylabel('res dens, mol/mol');

    %% multiplot(0,0);   
  end