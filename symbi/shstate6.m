function shstate6 (j)
  %% created: 2002/02/27 by Bas Kooijman; modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-2)substrates S (3-4)products P
  %% (5,6)structure V, reserve density m of species 1
  %% (7,8)structure V, reserve density m of species 2 internal

  global h S1_r S2_r J1_Sr J2_Sr ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_EV y2_EV y1_es y2_es y12_PE y21_PE ... % yield coefficients
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG;
 
  opt = optimset('display', 'off');
      
  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  hm = min([k1_E, k2_E, k1/y1_EV, k2/y2_EV])-1e-6; % initial estimate h-max
  [vh, val, info] = fsolve('findvh6',[.2 hm],opt);
                                             % get V2/V1 and max throughput
  v = vh(1); hm = vh(2); nh = 100;
  H = [linspace(1e-3, hm - 1e-3, nh), hm];      % set throughput rates
  X = zeros(nh+1,8);               % initiate state matrix

  %% fill states at max throughput rate (last row of X)
  m1 = y1_EV*(k1_M+hm)/(k1_E-hm);
  m2 = y2_EV*(k2_M+hm)/(k2_E-hm);
  X(nh+1,:) = [S1_r S2_r 0 0 1e-8 m1 v*1e-8 m2];
  
  %% fill states, starting from max throughput rate, working backwards
  for i = 2:nh
    h = H(nh-i+1);
    X(nh-i+1,:) = gstate6(max(5e-3,X(nh+2-i,:)))';
    %% J1_Sr = h*S1_r; J2_Sr = h*S2_r;
    %% h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h;
    %% d = dstate6(X(nh-i,:)); (d'*d) % must be very small
  end  

  h = H(nh); X(nh,:) = gstate6(max(5e-3,X(nh-1,:)))';
  %% redo second last point
  
  clf;

  if exist('j','var')==1 % single plot mode

    switch j
	
      case 1
        plot (H, X(:,1), 'b', H, X(:,2), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

      case 4
        plot (H, X(:,3), 'b', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('products');

      case 2
        plot (H, X(:,5), 'b', H, X(:,7), 'r');
        xlabel('throughput rate'); ylabel('structures');

      case 3
        plot (H, X(:,6), 'b', H, X(:,8), 'r');
        xlabel('throughput rate'); ylabel('res densities');

      case 5
        plot (H, X(:,7)./X(:,5), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');


      case 6
        plot (H, X(:,8)./X(:,6), 'g');
	    xlabel('throughput rate'); ylabel('ratio res density 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 3, 1);
        plot (H, X(:,1), 'b', H, X(:,2), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

        subplot (2, 3, 4);
        plot (H, X(:,3), 'b', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('products'); 

        subplot (2, 3, 2);
        plot (H, X(:,5), 'b', H, X(:,7), 'r');
        xlabel('throughput rate'); ylabel('structures');

        subplot (2, 3, 3);
        plot (H, X(:,6), 'b', H, X(:,8), 'r');
        xlabel('throughput rate'); ylabel('res densities');

        subplot (2, 3, 5);
        plot (H, X(:,7)./X(:,5), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');

        subplot (2, 3, 6);
        plot (H, X(:,8)./X(:,6), 'g');
	    xlabel('throughput rate'); ylabel('ratio res density 2/1');

  end
