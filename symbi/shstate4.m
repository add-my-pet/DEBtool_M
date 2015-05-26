function shstate4 (j)
  %% created: 2002/04/04 by Bas Kooijman; modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-4) substrates S1, S2, S2m, S2s
  %% (5-10) products P1, P1m, P1s, P2, P2m, P2s
  %% (11,12) structure V, reserve density m of species 1
  %% (13,14) structure V, reserve density m of species 2 (internal)

  global h h1S h2S h1P h2P h1V h2V ...            % hazard rates,
      J1_Sr J2_Sr S1_r S2_r;                      % substrate input
  global y1_ES y2_ES y1_EV y2_EV ...
      k1 k2 k1_E k2_E k1_M k2_M; % DEB parameters
  global istate4;

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  %% first find max growth rate for both species
  j1_E = y1_ES*k1; % max assim 
  m1 = j1_E/k1_E; % max res density 1
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % max spec growth rate

  j2_E = y2_ES*k2; % max assim 
  m2 = j2_E/k2_E; % max res density 2
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % max spec growth rate

  r = min(r1,r2); % max spec growth rate
  nh = 1000; % number of throughput rates
  dh = r/nh; % increment in throughput rates
  H = linspace(1e-4,r,nh); % set thoughput rates
  X = zeros(nh,14); % initiate state matrix
  
  tmax = 10000; nt = 3; t = linspace(0, tmax, nt); % set time points
  %% Set nt=200 if time-potting is activated 

  i = 10; % set initial counter
  h = H(i); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, X_t]  = ode45 ('dstate4', t, istate4);
  %% plot (t, X_t(:,11), 'b', t, X_t(:,13), 'r'); pause(1);  
  %% ttext = ['initial h = ', num2str(h)]; title(ttext);
  %% xlabel('time'); ylabel('structures');
  [x, val, err] = fsolve('dstat4',X_t(nt,:)', opt);
  X(i,:) = x';
  if err ~= 1
    fprintf(['Convergence problems for initial h = ', num2str(h),'\n']);
    return;
  end


  for k = 1:(i-1) % from initial throughput down to zero
    h = H(i-k); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [Xt, val, err] = fsolve('dstat4',X(i-k+1,:)', opt);
    X(i-k,:) = Xt';
    if err ~= 1 || prod(x>0) == 0
      %% second try in case of trouble
      x = X(i-k+1,:)'; % start from previous state-values
      [t, x] = ode23('dstate4', t, x); % first integrate
      %% plot(t, x(:,11), 'b', t, x(:,13), 'r'); pause(1); % plot structures
      %% ttext = ['down h = ', num2str(h)]; title(ttext);
      %% xlabel('time'); ylabel('structures');
      [x, err] = fsolve('dstat4',x(nt,:)',opt); X(i-k,:) = x';
    end
    if err ~= 1 && prod(x>0) ~= 1 % if still trouble, report
      fprintf(['Convergence problems for h = ', num2str(h),'\n']);      
    end
  end
  
  x = X(i,:)'; % make sure that branch up is entered
  while prod(x>0)==1 && i<nh % from initial throughput up to max throughput
    i = i+1;
    h = H(i); h1S = h; h2S = h; h1P = h; h2P = h; h1V = h; h2V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    [x, val, err] = fsolve('dstat4',X(i-1,:)', opt);
    X(i,:) = x';
    if err ~= 1 || prod(x>0) == 0
      %% second try in case of trouble
      x = X(i-1,:); % start from previous state-values
      [t, x] = ode45('dstate4', t, x); % first integrate
      %% plot(t, x(:,11), 'b', t, x(:,13), 'r'); pause(1); % plot structures
      %% xlabel('time'); ylabel('structures');
      %% ttext = ['up h = ', num2str(h)]; title(ttext);
      [x, val, err] = fsolve('dstat4',x(nt,:)',opt); X(i,:) = x';
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
        plot (H, X(:,1), 'b', ...
	      H, X(:,2), 'r', H, X(:,3), 'r', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

      case 3
        plot (H, X(:,5), 'b', H, X(:,6), 'b', H, X(:,7), 'b', ...
	      H, X(:,8), 'r', H, X(:,9), 'r', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('products');

      case 2
        plot (H, X(:,11), 'b', H, X(:,13), 'r');
        xlabel('throughput rate'); ylabel('structures');

      case 4
        plot (H, X(:,12), 'b', H, X(:,14), 'r');
        xlabel('throughput rate'); ylabel('res densities');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 2, 1);
        plot (H, X(:,1), 'b', ...
	      H, X(:,2), 'r', H, X(:,3), 'r', H, X(:,4), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

        subplot (2, 2, 3);
        plot (H, X(:,5), 'b', H, X(:,6), 'b', H, X(:,7), 'b', ...
	      H, X(:,8), 'r', H, X(:,9), 'r', H, X(:,10), 'r');
        xlabel('throughput rate'); ylabel('products'); 

        subplot (2, 2, 2);
        plot (H, X(:,11), 'b', H, X(:,13), 'r');
        xlabel('throughput rate'); ylabel('structures');

        subplot (2, 2, 4);
        plot (H, X(:,12), 'b', H, X(:,14), 'r');
        xlabel('throughput rate'); ylabel('res densities');

  end
