function shstate0a (j)
  %% created: 2002/02/11 by Bas Kooijman, modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-2)substrates S (3-4)products P
  %% (5,6)structure V, reserve density m of species 1
  %% (7,8)structure V, reserve density m of species 2 (external)

  global h S1_r S2_r ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance rate coeff
      k1_S k2_S k1_P k2_P ... % dissociation rates
      b1_S b2_S b1_P b2_P ... % association rates
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % res, substr, prod costs
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG % product yields
  global istate0

  pars; % set parameter values

  %% first find max growth rate for both species
  j1_E = y1_ES*k1; % max assim 
  m1 = j1_E/k1_E; % max res density 1
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % max spec growth rate

  j2_E = y2_ES*k2; % max assim 
  m2 = j2_E/k2_E; % max res density 2
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % max spec growth rate

  r = min(r1,r2); % max spec growth rate
  nh = 100; % number of throughput rates
  dh = r/nh; % increment in throughput rates
  H = linspace(1e-4,r,nh); % set thoughput rates
  X = zeros(nh,8); % initiate state matrix
  
  i = 20; % set initial counter
  h = H(i); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t X_t]  = ode23 ('dstate0', [0;300], istate0);
  X(i,:) = fsolve('dstat0',X_t(end,:)')';

  for k = 1:(i-1) % from initial throughput down to zero
    h = H(i-k); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h; 
   J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    X(i-k,:) = fsolve('dstat0',X(i-k+1,:)')';
  end
  while X(i,8) > 0 && i < nh % from initial throughput up to max throughput
    i = i+1;
    h = H(i); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    X(i,:) = fsolve('dstat0',X(i-1,:)')';
  end
  X = X(1:(i-1),:); % remove throughput rates with washout
  H = H(1:(i-1))';
  
  clf
  
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
        plot (H, X(:,6), 'b',H, X(:,8), 'r');
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