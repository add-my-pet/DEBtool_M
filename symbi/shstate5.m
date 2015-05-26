function shstate5 (j)
  %% created: 2002/02/27 by Bas Kooijman, modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% Internal population of species 2 only; no mantle space
  %% State vector:
  %% (1-3) substr 1 (free), 2 (free and internal)
  %% (4-7) product 1 (free and internal), 2 (free and internal)
  %% (8-9) struct and res dens species 1
  %% (10-11) struct and res dens species 2 (internal) 

  global h1_V h2_V h1_S h2_S h1_P h2_P h ... % reactor drain controls
      J1_Sr J2_Sr S1_r S2_r ... % reactor feeding controls
      k1_E k2_E k1 k2 ... % max spec assimilation
      y1_EV y2_EV; % costs for structure, reserves
  global istate5;

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  tmax = 10000; nt = 3; t = linspace(0, tmax, nt); % set time points
  %% Set nt=200 if time-potting is activated 

  hm = min([k1_E, k2_E, k1/y1_EV, k2/y2_EV])-1e-6; % initial estimate h-max
  
  nh = 1000; % number of throughput rates
  H = linspace(1e-4,hm,nh); % set thoughput rates
  X = zeros(nh,11); % initiate state matrix
  
  i = 10; % set initial counter
  %% set throughput rate
  h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, X_t]  = ode45 ('dstate5', t, istate5);
  %% plot (t, X_t(:,8), 'b', t, X_t(:,10), 'r'); pause(1);  
  %% ttext = ['initial h = ', num2str(h)]; title(ttext);
  [x, val, err] = fsolve('dstat5',X_t(nt,:)',opt); X(i,:) = x';
  if err ~= 1
    fprintf(['Convergence problems for initial h = ', num2str(h),'\n']);
    return;
  end

  for k = 1:(i-1) % from initial throughput down to zero
    %% set throughput rate
    h = H(i-k); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [x, val, err] = fsolve('dstat5',X(i-k+1,:)',opt); X(i-k,:) = x';
    if err ~= 1 || sum(x>0) < length(x)
      %% second try in case of trouble
      x = X(i-k+1,:)'; % start from previous state-values
      [t, x] = ode45('dstate5', t, x); % first integrate
      %% plot(t, x(:,8), 'b', t, x(:,10), 'r'); pause(1); % plot structures
      %% ttext = ['down h = ', num2str(h)]; title(ttext);
      [x, val, err] = fsolve('dstat5',x(nt,:)',opt); X(i-k,:) = x';
    end
    if err ~= 1 && sum(x>0) < length(x) % if still trouble, report
      fprintf(['Convergence problems for h = ', num2str(h),'\n']);      
    end
  end

  x = X(i,:)'; % make sure that branch up is entered
  while prod(x>1e-7)==1 && i<nh % from initial up to max throughput
    i = i+1;
    %% set throughput rate
    h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [x, val, err] = fsolve('dstat5',X(i-1,:)); X(i,:) = x';
    if err ~= 1 || prod(x>0) == 0
      %% second try in case of trouble
      x = X(i-1,:); % start from previous state-values
      [t, x] = ode45('dstate5', x, t); % first integrate
      %% ttext = ['up h = ', num2str(h)]; title(ttext);
      %% plot(t, x(:,8), 'b', t, x(:,10), 'r'); pause(1); % plot structures
      [x, val, err] = fsolve('dstat5',x(nt,:)',opt); X(i,:) = x';
    end
    if err ~= 1 && sum(x>0) < length(x) % if still trouble, report
      fprintf(['Convergence problems for h = ', num2str(h),'\n']);      
    end
  end
  X = X(1:(i-1),:); % remove throughput rates with washout
  H = H(1:(i-1))';

  clf;  
  if exist('j','var')==1 % single plot mode
    switch j
	
      case 1
        plot (H, X(:,1), 'b', H, X(:,2), 'r', X(:,3), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

      case 4
        plot (H, X(:,4), 'b', H, X(:,5), 'b', ...
	      H, X(:,6), 'r', H, X(:,7), 'r');
        xlabel('throughput rate'); ylabel('products');

      case 2
        plot (H, X(:,8), 'b', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('structures');

      case 3
        plot (H, X(:,9), 'b', H, X(:,11), 'r');
        xlabel('throughput rate'); ylabel('res densities');

      case 5
        plot (H, X(:,10)./X(:,8), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');


      case 6
        plot (H, X(:,11)./X(:,9), 'g');
	xlabel('throughput rate'); ylabel('ratio res density 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 3, 1);
        plot (H, X(:,1), 'b', H, X(:,2), 'r', X(:,3), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

        subplot (2, 3, 4);
        plot (H, X(:,4), 'b', H, X(:,5), 'b',...
	      H, X(:,6), 'r', H, X(:,7), 'r');
        xlabel('throughput rate'); ylabel('products'); 

        subplot (2, 3, 2);
        plot (H, X(:,8), 'b', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('structures');

        subplot (2, 3, 3);
        plot (H, X(:,9), 'b', H, X(:,11), 'r');
        xlabel('throughput rate'); ylabel('res densities');

        subplot (2, 3, 5);
        plot (H, X(:,10)./X(:,8), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');

        subplot (2, 3, 6);
        plot (H, X(:,11)./X(:,9), 'g');
	xlabel('throughput rate'); ylabel('ratio res density 2/1');
  end
