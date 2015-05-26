function shstate0 (j)
  %% created: 2002/04/03 by Bas Kooijman, modified 2009/09/29
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
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG; % product yields
  global r1 r2 m1 m2; % for use in 'findspv0'

  opt = optimset('display', 'off');

  err = testpars; % set and test parameter values on consistency
  if err ~= 0 % inconsistent parameter values
    return
  end
  nh = 500; % number of throughput rates

  %% first find max growth rate for both species
  j1_E = y1_ES*b1_S*S1_r/(1 + S1_r*b1_S/k1_S); % max assim with V2=0
  m1 = j1_E/k1_E; % max res density 1
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % max spec growth rate

  j2_E = y2_ES*b2_S*S2_r/(1 + S2_r*b2_S/k2_S); % max assim with V1=0
  m2 = j1_E/k1_E; % max res density 2
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % max spec growth rate
  
  %% fill states in throughput rate range where only 1 species survives
  if r1>r2 % species 2 is absent between r2 and r1
    %% recalculate r2, because species 1 produces product that 2 can use
    [r2n, val, err] = fsolve('findr20',r1, opt);
    if r2n>r1 || r2n<r2 % we must have r1> new r2 > old r2
      fprintf('inconsistent parameter setting \n');
      return;
    else
      r2 = r2n;
    end
    
    nh1 = max(2,min(nh-2,1 + floor(100*r2/r1))); nh2 = nh - nh1;
    H1 = linspace(1e-3, r2, nh1); H2 = linspace(r2, r1-1e-4, nh2);
    H = [H1 H2]; %set throughput
    X = zeros(nh,8); % initiate state variable output

    for i = 1:nh2
      h = H(nh + 1 - i);
      m1 = y1_EV*(k1_M + h)/(k1_E - h);
      j1_E = m1*k1_E;
      S1 = 1/(b1_S*(y1_ES/j1_E - 1/k1_S));
      j1_S = b1_S*S1/(1 + S1*b1_S/k1_S);
      V1 = (S1_r - S1)*h/j1_S;
      j1_P = y1_PS*j1_S + y1_PM*k1_M + y1_PG*h;
      P1 = V1*j1_P/h;
      X(nh + 1 - i,:) = [S1 S2_r P1 0 V1 m1 0 0];
    %% reserve density of non-existent species is set to zero
    end    
    %% set initial estimate for 2 species range
    m2 = y2_EV*(k2_M + r2)/(k2_E - r2);
    X(nh1,:) = [S1 S2_r P1 0 V1 m1 1e-8 m2];

  else % species 1 is absent between r1 and r2
    %% recalculate r1, because species 2 produces product that 1 can use
    [r1n, val, err] = fsolve('findr10',r2, opt);
    if r1n>r2 || r1n<r1 % we must have r2 > new r1 > old r1
      fprintf('inconsistent parameter setting \n');
      return;
    else
      r1 = r1n;
    end

    nh1 = max(2,min(nh-2,1 + floor(nh*r1/r2))); nh2 = nh - nh1;

    H1 = linspace(1e-3, r1, nh1); H2 = linspace(r1, r2, nh2);
    H = [H1 H2]; %set throughput
    X = zeros(nh,8);
    X(nh,:) = [S1_r S2_r 0 0 0 0 1e-8 m2];

    for i = 1:nh2
      h = H(nh + 1 - i);
      m2 = y2_EV*(k2_M + h)/(k2_E - h);
      j2_E = m2*k2_E;
      S2 = 1/(b2_S*(y2_ES/j2_E - 1/k2_S));
      j2_S = b2_S*S2/(1 + S2*b2_S/k2_S);
      V2 = (S2_r - S2)*h/j2_S;
      j2_P = y2_PS*j2_S + y2_PM*k2_M + y2_PG*h;
      P2 = V2*j2_P/h;
      X(nh + 1 - i,:) = [S1_r S2 0 P2 0 0  V2 m2];
      %% reserve density of non-existent species is set to zero
    end
    %% set initial estimate for 2 species range
    m1 = y1_EV*(k1_M + r1)/(k1_E - r1);
    X(nh1,:) = [S1_r S2 0 P2 1e-8 m1 V2 m2]; 
  end 

  tmax = 10000; nt = 3; t = linspace(0,tmax,nt); % set time points
  %% choose nt = 200 if time-plotting is activated
  clf; xlabel('time'); ylabel('structures');

  %% fill state at the highest rate for the slow species
  global h1_S h2_S h1_P h2_P h1_V h2_V J1_Sr J2_Sr istate0;
  h = H(nh1-1); h1_S = h; h2_S = h; h1_P = h; h2_P = h; h1_V = h; h2_V = h; 
  J1_Sr = S1_r*h; J2_Sr = S2_r*h;
  [t, x] = ode23s('dstate0', t, istate0);
  %% plot (t, x(:,5), 'b', t, x(:,7), 'r');  
  %% ttext = ['down h = ', num2str(h)]; title(ttext);
  %% xlabel('time'); ylabel('structures');
  [Xt, val, err] = fsolve('dstat0',max(.1,x(nt,:)'), opt);
  X(nh1-1,:) = Xt';
  
  %% fill states, starting from max throughput rate for 2 species
  %%  working backwards to zero
  ind = [1 2 3 4 5 7]; % indices for implicit variables
  for i = 2:(nh1-1)
    h = H(nh1-i); r2 = h; r1 = h;% set throughput range
    m1 = y1_EV*(k1_M + r1)/(k1_E - r1); % res density 1
    m2 = y2_EV*(k2_M + r2)/(k2_E - r2); % res density 2
    X(nh1-i,[6 8]) = [m1 m2]; 
    [x, val, err] = fsolve('findspv0',max(1,X(nh1-i+1,ind)), opt);
    if err ~= 1 || sum(x>0) < length(x)
      %% second try in case of trouble
      x = X(nh1-i+1,:); x([5 7]) = max(1,x([5 7])); % start away from
      [t, x] = ode45('dstate0', t, x); % first integrate
      %% ttext = ['down h = ', num2str(h)]; title(ttext);
      %% plot(t, x(:,5), 'b', t, x(:,7), 'r'); pause(1); % plot structures
      x = x(nt,:); x([5 7]) = max(0.1,x([5 7])); % structures away from 0 
      [x, val, err] = fsolve('findspv0', x(ind), opt);
    end
    if err == 1 && sum(x>0) == length(x) % only if solution is correct
      X(nh1-i,ind) = max(0,x');  % copy result in plot matrix, else 0
    end

  end
   
  if exist('j','var')==1 % single plot mode
    clf;
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
        plot (H1, X(1:nh1,7)./X(1:nh1,5), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');

      case 6
        plot (H1, X(1:nh1,8)./X(1:nh1,6), 'g');
	    xlabel('throughput rate'); ylabel('ratio res density 2/1');

      otherwise
	return;

    end
  else % multiple plot mode
    
        subplot (2, 3, 1);
        plot (H, X(:,1), 'b', H, X(:,2), 'r');
        xlabel('throughput rate'); ylabel('substrates'); 

        subplot (2, 3, 4);
        plot (H, X(:,3), 'b', H, X(:,4));
        xlabel('throughput rate'); ylabel('products'); 

        subplot (2, 3, 2);
        plot (H, X(:,5), 'b', H, X(:,7), 'r');
        xlabel('throughput rate'); ylabel('structures');

        subplot (2, 3, 3);
        plot (H, X(:,6), 'b', H, X(:,8), 'r');
        xlabel('throughput rate'); ylabel('res densities');

        subplot (2, 3, 5);
        plot (H1, X(1:nh1,7)./X(1:nh1,5), 'g');
        xlabel('throughput rate'); ylabel('ratio structure 2/1');

        subplot (2, 3, 6);
        plot (H1, X(1:nh1,8)./X(1:nh1,6), 'g');
	    xlabel('throughput rate'); ylabel('ratio res density 2/1');

  end
