function shstate2 (j)
  %% created: 2002/04/04 by Bas Kooijman, modified 2009/09/29
  %% chemostat equilibrium plots for 'endosym'
  %% State vector:
  %% (1-2)substrates S (3-4)products P
  %% (5,6)structure V, reserve density m of species 1
  %% (7,8)structure V, reserve density m of species 2 (external)

  global h h1_S h2_S h1_P h2_P h1_V h2_V ...      % hazard rates,
      J1_Sr J2_Sr S1_r S2_r;                      % substrate input
  global istate2;

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end

  %% make sure that hmax exceeds actual max throughput rate
  hmax = 1.0; nh = 5000; H = linspace(1e-4,hmax,nh); % set throughput rates
  X = zeros(nh,8); % initiate state matrix
  
  %% set nt = 200 if you want time-plots for each h-value
  tmax = 10000; nt = 3; t = linspace(0,tmax,nt); % set time points

  i = 20; % set initial counter
  h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h;
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, X0]  = ode45 ('dstate2', t, istate2);
  %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r');
  %% ttext = ['initial h = ', num2str(h)]; title(ttext);
  %% xlabel('time'); ylabel('structures');
  [x, val, err] = fsolve('dstat2',X0(nt,:)', opt);
  X(i,:) = x';
  if err ~= 1 | sum(x>0) < length(x)
    fprintf(['convergence problems for initial h = ', num2str(h), '\n']);
    return; % hopeless if first throughput already failed
  end


  for k = 1:(i-1) % from initial throughput down to zero
    h = H(i-k); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    x0 =  X(i-k+1,:)'; % set start value for new state variables
    [x, err] = fsolve('dstat2', x0', opt); X(i-k,:) = x';
    if err ~= 1 | sum(x>0) < length(x) % if no convergence, then first integrate
      x0([5 7]) = max(1,x0([5 7])); [t X0]  = ode45 ('dstate2', t, x0);
      %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r'); pause(1);
      %% ttext = ['down h = ', num2str(h)]; title(ttext);
      %% xlabel('time'); ylabel('structures');
      [x, val, err] = fsolve('dstat2', max(0.5, X0(nt,:)'),opt);
      X(i-k,:) = x';
    end
    if err ~= 1 | sum(x>0) < length(x) % if still no convergence then report
      fprintf(['convergence problems for h = ', num2str(h), '\n']);
      %% X(i-k,:)=[]; H(i-k)=[]; i=i-1 # remove bad value 
    end

  end

  while X(i,:)>1e-4 & i<nh
                %% from initial throughput up to max throughput
    i = i+1;
    h = H(i); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
    J1_Sr = S1_r*h; J2_Sr = S2_r*h;
    x0 = X(i-1,:)'; % set start value for new state variables
    [x, val, err] = fsolve('dstat2', x0', opt); X(i,:) = x';
    if err ~= 1 | sum(x>0) < length(x) % if no convergence, then first integrate
      x0([5 7]) = max(1,x0([5 7])); [t, X0]  = ode45 ('dstate2', t, x0);
      %% plot (t, X0(:,5), 'b', t, X0(:,7), 'r'); pause(1);
      %% ttext = ['up h = ', num2str(h)]; title(ttext);
      %% xlabel('time'); ylabel('structures');
      [x, val, err] = fsolve('dstat2', max(0.5, X0(nt,:)'), opt);
      X(i,:) = x';    
    end
    if err ~= 1 | sum(x>0) < length(x)  % if still no convergence then report
      fprintf(['convergence problems for h = ', num2str(h), '\n']);
    end
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
