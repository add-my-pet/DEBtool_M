function shstate3 (j)
  %% created: 2002/02/27 by Bas Kooijman; modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-4)substrates S1, S2, S2m S2s
  %% (5-10)products P1, P1m, P1s, P2, P2m, P2s
  %% (11,12)structure V, reserve density m of species 1
  %% (13,14)structure V, reserve density m of species 2 (external)
  %% (15,16)structure V, reserve density m of species 2 (mantle)
  %% (17,18)structure V, reserve density m of species 2 (internal) 

  global h h1_S h2_S h1_P h2_P h1_V h2_V ...      % hazard rates,
      J1_Sr J2_Sr S1_r S2_r;                      % substrate input
  global y1_es y2_es y1_EV y2_EV ...
      k1 k2 k1_E k2_E k1_M k2_M; % DEB parameters
  global istate3;

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  %% set nt = 200 if you want time-plots for each h-value
  tmax = 50000; nt = 3; t = linspace(0, tmax, nt); % set time points
  
  %% first find max growth rate for both species
  j1_E = y1_es*k1; % max assim 
  m1 = j1_E/k1_E; % max res density 1
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % max spec growth rate

  j2_E = y2_es*k2; % max assim 
  m2 = j2_E/k2_E; % max res density 2
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % max spec growth rate

  r = min(r1,r2); % max spec growth rate
  nh = 500; % number of throughput rates
  dh = r/nh; % increment in throughput rates
  H = linspace(1e-4,r,nh); % set thoughput rates
  X = zeros(nh,18); % initiate state matrix
  
  i = 10; % set initial counter
  h = H(i); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, X_t]  = ode45 ('dstate3', t, istate3);
  %% plot (t, X_t(:,11), 'b', ...  % plot structures
  %%	t, X_t(:,13), 'k', t, X_t(:,15), 'k', t, X_t(:,17), 'r');
  %% pause(1);
  %% ttext = ['initial h = ', num2str(h)]; title(ttext);
  %% xlabel('time'); ylabel('structures'); % label time plots
  [x, val, err] = fsolve('dstat3', X_t(nt,:)', opt);
  X(i,:) = x';

  for k = 1:(i-1) % from initial throughput down to zero
    h = H(i-k); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [x, val, err] = fsolve('dstat3',X(i-k+1,:)', opt);
    X(i-k,:) = x';
    if err ~= 1 || prod(x>0) == 0
      %% second try in case of trouble
      x = X(i-k+1,:)'; % start from previous state-values
      [t, x] = ode45('dstate3', t, x); % first integrate
      %% plot (t, X_t(:,11), 'b', ...  % plot structures
      %%    t, X_t(:,13), 'k', t, X_t(:,15), 'k', t, X_t(:,17), 'r');
      %% pause(1);
      %% ttext = ['down h = ', num2str(h)]; title(ttext);
      %% xlabel('time'); ylabel('structures'); % label time plots
      [x, val, err] = fsolve('dstat3',x(nt,:)',opt); X(nh-i,:) = x';
    end
    if err ~= 1 && prod(x>0) ~= 1 % if still trouble, report
      fprintf(['Convergence problems for h = ', num2str(h),'\n']);      
    end
  end
  
  x = X(i,:)'; % make sure that branch up is entered
  while prod(x(1:12)>0)==1 && i<nh % from initial up to max throughput
    i = i+1;
    h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [x, val, err] = fsolve('dstat3', X(i-1,:)', opt);
    X(i,:) = x';
    if err ~= 1 || prod(x>0) == 0
      %% second try in case of trouble
      x = X(i-1,:)'; % start from previous state-values
      [t, x] = ode45('dstate3', t, x); % first integrate
      %% plot (t, X_t(:,11), 'b', ...  % plot structures
      %%    t, X_t(:,13), 'k', t, X_t(:,15), 'k', t, X_t(:,17), 'r');
      %% pause(1);
      %% ttext = ['up h = ', num2str(h)]; title(ttext);
      %% xlabel('time'); ylabel('structures'); % label time plots
      [x, err] = fsolve('dstat3',x(nt,:)',opt); X(i,:) = x';
    end
    if err ~= 1 && prod(x>0) ~= 1 % if still trouble, report
      fprintf(['Convergence problems for h = ', num2str(h),'\n']);      
    end
  end
  X = X(1:(i-1),:); % remove throughput rates with washout
  H = H(1:(i-1))';
  
  clf;
  
  if exist('j','var')==1 % single plot mode
    switch j
	
      case 1
        plot (H, X(:,1), 'b', H, X(:,2), 'r', ...
	      H, X(:,3), 'r', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

      case 3
        plot (H, X(:,5), 'b', H, X(:,6), 'b', H, X(:,7), 'b', ...
	      H, X(:,8), 'r', H, X(:,9), 'r', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('products');

      case 2
        plot (H, X(:,11), 'b', ...
	      H, X(:,13), 'r', H, X(:,15), 'r', H, X(:,17), 'r');
        xlabel('throughput rate'); ylabel('structures');

      case 4
        plot (H, X(:,12), 'b', ...
	      H, X(:,14), 'r', H, X(:,16), 'r', H, X(:,18), 'r');
        xlabel('throughput rate'); ylabel('res densities');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 2, 1); 
        plot (H, X(:,1), 'b', H, X(:,2), 'r', ...
	      H, X(:,3), 'r', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

        subplot (2, 2, 3);
        plot (H, X(:,5), 'b', H, X(:,6), 'b', H, X(:,7), 'b', ...
	      H, X(:,8), 'r', H, X(:,9), 'r', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('products'); 

        subplot (2, 2, 2);
        plot (H, X(:,11), 'b', ...
	      H, X(:,13), 'r', H, X(:,15), 'r', H, X(:,17), 'r');
        xlabel('throughput rate'); ylabel('structures');

        subplot (2, 2, 4);
        plot (H, X(:,12), 'b', ...
	      H, X(:,14), 'r', H, X(:,16), 'r', H, X(:,18), 'r');
        xlabel('throughput rate'); ylabel('res densities');

  end
