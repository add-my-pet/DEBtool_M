function shstate1 (j)
  %% created: 2002/04/04 by Bas Kooijman; modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-2)substrates S (3-4)products P
  %% (5,6)structure V, reserve density m of species 1
  %% (7,8)structure V, reserve density m of species 2 (external)

  global h1_S h2_S h1_P h2_P h1_V h2_V ...        % hazard rates,
      J1_Sr J2_Sr S1_r S2_r;                      % substrate input
  global y1_ES y2_ES y1_EV y2_EV k1 k2 k1_E k2_E; % DEB parameters
  global istate1;

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  %% make sure that hmax exceeds actual max throughput rate
  hmax = 1.0; nh = 500; H = linspace(1e-4, hmax, nh); % set throughput rates
  X = zeros(nh,8); % initiate state matrix

  %% set nt = 200 if you want time-plots for each h-value
  tmax = 200; nt = 3; t = linspace(0,tmax,nt); % set time points

  i = 20; % set initial counter
  h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, X0]  = ode23s ('dstate1', t, istate1);
  %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r');
  %% ttext = [' initial h = ', num2str(h)]; title(ttext);
  %% xlabel('time'); ylabel('structures');
  [Xt, val, err] = fsolve('dstat1',X0(nt,:)', opt);
  X(i,:) = Xt';

  for k = 1:(i-1) % from initial throughput down to zero
    h = H(i-k); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [t, X0] = ode23s ('dstate1', t, X(i-k+1,:)');
    %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r');
    %% ttext = [' down h = ', num2str(h)]; title(ttext);
    %% xlabel('time'); ylabel('structures');
    [Xt, val, err] = fsolve('dstat1',X0(nt,:)', opt);
    X(i-k,:) = Xt';
  end
  while X(i,5)>1e-4 && X(i,7)>1e-4 && i<nh
                     % from initial throughput up to max throughput
    i = i+1;
    h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [t, X0] = ode23 ('dstate1', t, X(i-1,:)');
    %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r');
    %% ttext = ['up h = ', num2str(h)]; title(ttext);
    %% xlabel('time'); ylabel('structures');
    [Xt, val, err] = fsolve('dstat1', X0(nt,:)', opt);
    X(i,:) = Xt';
  end
  X = X(1:(i-1),:); % remove throughput rates with washout
  H = H(1:(i-1))';
  
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
