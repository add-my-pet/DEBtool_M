function shbatch (j)
%% created at 2000/10/20 by Bas Kooijman
%% calculates state variables in a fed batch culture
%% X   = Xt(1);  X_V = Xt(2);  e_  = Xt(3);
  %% X_DV = Xt(4); X_DE = Xt(5); X_P = Xt(6);

  global w_O m_Em h h_X h_V h_P X_r;
  
  h_P = 0; h_V = 0; h_X = 0;   % set removal rates to zero
  h = 0.1;                     % set supply rate of substrate
  X0 = [X_r; 1e-3; 1; 0; 0; 0];% set initial conditions
  t_max = 500;                 % set time period for integration
  [t Xt] = ode23s ('dchem', [0 t_max], X0);
  X_E = Xt(:,3).*Xt(:,2)*m_Em;
  X_W =  w_O(2)*Xt(:,2) + w_O(3)*X_E;
  X_DW = w_O(2)*Xt(:,4) + w_O(3)*Xt(:,5);
  
  if exist('j') == 1 % single-plot mode
     switch j
        
     case 1
       plot(t, Xt(:,2), 'g', t, Xt(:,4), '.g', ...
         t, X_E, 'r', t, Xt(:,5), '.r');
       title ('living & dead structure & reserve');
       xlabel('time, d'); ylabel('mass, M');

     case 2
       plot(t, (X_W + X_DW),'k', t, X_DW, '.k');
       title ('total and dead biomass');
       xlabel('time, d'); ylabel('weight, g/l');

     case 3
       plot(t, Xt(:,1), 'g');
       xlabel('time, d'); ylabel('substrate, M');

     case 4
       plot(t, Xt(:,6), 'r');
       xlabel('time, d'); ylabel('product, M');
       
     otherwise
       return;
     end
 
  else % multi-plot mode
    %% multiplot(2, 2); hold on; gset nokey;
    %% top_title ('Batch culture'); does not seem to work
 
    subplot(2, 2, 1);
    plot(t, Xt(:,2), 'g', t, Xt(:,4), '.g', ...
       t, X_E, 'r', t, Xt(:,5), '.r');
    title ('living & dead structure & reserve');
    xlabel('time, d'); ylabel('mass, M');

    subplot(2, 2, 2);
    plot(t, (X_W + X_DW),'k', t, X_DW, '.k');
    title ('total and dead biomass');
    xlabel('time, d'); ylabel('weight, g/l');

    subplot(2, 2, 3);
    plot(t, Xt(:,1), 'g');
    xlabel('time, d'); ylabel('substrate, M');

    subplot(2, 2, 4);
    plot(t, Xt(:,6), 'r');
    xlabel('time, d'); ylabel('product, M');

    %% multiplot(0,0);
  end