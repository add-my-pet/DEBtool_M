function shchemostat (j)
%% created at 2000/10/20 by Bas Kooijman
%% calculates equilibria for a chemostat at a range of throughput rates
%%  and a fixed concentration of stubstrate in the feed

  global w_O m_Em X_r jT_X_Am j_E_M j_E_J K kT_M kT_E g hT_a;
  global zeta h_m mu_O mu_M eta_O y_E_X y_E_V kap n_M n_O;
  
  n_h = 100; h  = linspace(1e-4,h_m,n_h)';    % 1/d, throughput rates
  
  [Xh, ph] = chemostat (h, X_r);              % get states
  %%   Xh = [X, X_V, X_E, X_P, X_DV, X_DE, X_W, X_DW]
  %%   ph = [p_T, p_A, p_D, p_G]
  
 
  if exist('j')== 1 % single-plot mode
    switch j
      case 1
        plot(h, Xh(:,2), 'g', h, Xh(:,5), '.g', ...
             h, Xh(:,3), 'r', h, Xh(:,6), '.r');
        title ('living & dead structure & reserve');
        xlabel('throughput rate, 1/d'); ylabel('mass, M');

      case 2
        plot(h, Xh(:,7) + Xh(:,8),'k', h, Xh(:,8), '.k');
        title ('total and dead biomass');
        xlabel('throughput rate, 1/d'); ylabel('weight, g/l');

      case 3
        plot(h, Xh(:,5)./(Xh(:,2) + Xh(:,5)), 'g', ...
          h, Xh(:,8)./(Xh(:,7) + Xh(:,8)), 'k');
        title ('fraction of dead structure, biomass');
        xlabel('throughput rate, 1/d'); ylabel('fraction');

      case 4
        plot(h, Xh(:,1), 'g');
        xlabel('throughput rate, 1/d'); ylabel('substrate, M');

      case 5
        plot(h, Xh(:,4), 'k');
        xlabel('throughput rate, 1/d'); ylabel('product, M');

      case 6
        plot(h, ph(:,1), 'r');
        xlabel('throughput rate, 1/d'); ylabel('heat production, kJ/d');

      otherwise
        return;
    end
      
  else % multi-plot mode
    %% top_title ('Chemostat culture'); %% does not seem to work
    
    subplot(2, 3, 1);
    plot(h, Xh(:,2), 'g', h, Xh(:,5), '.g', ...
         h, Xh(:,3), 'r', h, Xh(:,6), '.r');
    title ('living & dead structure & reserve');
    xlabel('throughput rate, 1/d'); ylabel('mass, M');

    subplot(2, 3, 2);
    plot(h, Xh(:,7) + Xh(:,8),'k', h, Xh(:,8), '.k');
    title ('total and dead biomass');
    xlabel('throughput rate, 1/d'); ylabel('weight, g/l');

    subplot(2, 3, 3);
    plot(h, Xh(:,5)./(Xh(:,2) + Xh(:,5)), 'g', ...
      h, Xh(:,8)./(Xh(:,7) + Xh(:,8)), 'k');
    title ('fraction of dead structure, biomass');
    xlabel('throughput rate, 1/d'); ylabel('fraction');

    subplot(2, 3, 4);
    plot(h, Xh(:,1), 'g');
    xlabel('throughput rate, 1/d'); ylabel('substrate, M');

    subplot(2, 3, 5);
    plot(h, Xh(:,4), 'k');
    xlabel('throughput rate, 1/d'); ylabel('product, M');

    subplot(2, 3, 6);
    plot(h, ph(:,1), 'r');
    xlabel('throughput rate, 1/d'); ylabel('heat production, kJ/d');

  end