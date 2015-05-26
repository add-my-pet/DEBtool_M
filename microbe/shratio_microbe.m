function shratio_microbe (j)
  %% created 2000/10/20 by Bas Kooijman, modified 2009/08/03
  %% plots of ratio's of mineral fluxes for 'microbe';
  %% page 138, 146 of DEB book

  global r_m K; 

  n_h = 100; h  = linspace(1e-3, r_m-1e-10, n_h)'; % 1/d, throughput rates
  [Xh, ph, J_O, J_M] = chemostat (h, K*1e8);       % get fluxes

  RQ = J_M(:,1)./J_M(:,3);
  WQ = J_M(:,2)./J_M(:,3);
  UQ = J_M(:,4)./J_M(:,3);
  
  clf;
  
  if exist('j') == 1 % single-plot mode

    switch j
      case 1
        plot(h, RQ, 'k');
       	ylabel('Respiration Quotient'); xlabel('spec growth rate, 1/d');

      case 2
        plot(h, WQ, 'b');
	      ylabel('Watering Quotient'); xlabel('spec growth rate, 1/d');

      case 3
        plot(h, UQ, 'r');
        ylabel('Urination Quotient'); xlabel('spec growth rate, 1/d');
    
      otherwise
        return;
        
    end
  
    
  else % multiple plot-mode
    
    subplot (1, 3, 1)
    plot(h, RQ, 'k');
    ylabel('Respiration Quotient'); xlabel('spec growth rate, 1/d');

    subplot (1, 3, 2)
    plot(h, WQ, 'b');
    ylabel('Watering Quotient'); xlabel('spec growth rate, 1/d');

    subplot (1, 3, 3)
    plot(h, UQ, 'r');
    ylabel('Urination Quotient'); xlabel('spec growth rate, 1/d');
    

  end





