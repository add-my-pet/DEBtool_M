function Xinf = shgrad3_mixo (j)
  %% created: 2002/03/16 by Bas Kooijman
  %% time_plots for 'mixo' in vertical gradients: 3 reserves
  %% Xinf: (nL,nX) matrix with values of state variables (in columns)
  %%   as function of depth (in rows) at last integration point (t = tmax)
  %%   first row corresponds with surface layer
  %%   no downward transport from bottum layer (closed stack)
  %%   light reduction factor constant per layer

  global istate; % initial states 
  global nL nX j_l_F J_L_F;

  pars3; % set parameter values
  J_L_F = j_L_F; % copy light intensity into dummy
  nL = 50; L = linspace(0, -nL, nL); %% number of layers, depth
  nX = max(size(istate)); % number of state variables per layer
  X0 = zeros(nL*nX,1);    % initiate initial state
  
  %% start with homogeneous gradient at time = 0
  %% catenate state variables in all layers
  for i = 1:nL
    X0((i-1)*nX + (1:nX)) = istate;
  end
  
  
  tmax = 50; nt = 100; t = linspace (0, tmax, nt); % set time points
  [t, X_t]  = ode23 ('dgrad3_mixo', t, X0);

  Xinf = reshape(X_t(nt,:), nX, nL)'; % set last time point in output
  Xm =  reshape(max(X_t), nX, nL)'; Xm = max(Xm); % maximum value
  
  fprintf(stderr, 'hit a key to proceed \n');
  pause;
  clf;

  if exist('j') == 1 % single plot mode
    %% movie of gradients
    switch j
	
      case 1
        for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
	  plot ([0;Xm(1)], [L(nL);0], '8.', X(:,1), L, '8');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('DIC, muM'); 
	

      case 2
	for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
          plot ([0;Xm(2)], [L(nL);0], 'b.', X(:,2), L, 'b');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('DIN, muM');

      case 3
	for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
          plot ([0;Xm(3)], [L(nL);0], '6.', X(:,3), L, '6');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('struc-detritus, muM');

      case 4
	for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
          plot ([0;Xm(4)], [L(nL);0], '6.', X(:,4), L, '6');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('res-detritus, muM');

      case 5
	for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
          plot ([0;Xm(5)], [L(nL);0], 'g.', X(:,5), L, 'g');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('structure, muM');

      case 6
	for i = 1:nt
	  X = reshape(X_t(i,:), nX, nL)';
          plot ([0;Xm(6)], [L(nL);0], 'r.', X(:,6), L, 'r', ...
		[0;Xm(7)], [L(nL);0], '8.', X(:,7), L, '8', ...
		[0;Xm(8)], [L(nL);0], 'b.', X(:,8), L, 'b');
	  pause (0.5);
	end
        ylabel('depth, m'); xlabel('reserves, muM');

      otherwise
	return;

    end
  else % multiple plot mode
    %% last time point only
    
        subplot (2, 3, 1); 
	plot (Xinf(:,1), L, 'k', 0, 0, 'k.');
        ylabel('depth, m'); xlabel('DIC, muM');

        subplot (2, 3, 2);
        plot (Xinf(:,2), L, 'b', 0, 0, 'b.');
        ylabel('depth, m'); xlabel('DIN, muM');

        subplot (2, 3, 3);
        plot (Xinf(:,3), L, 'k', 0, 0, 'k.');
        ylabel('depth, m'); xlabel('struc-detritus, muM');

        subplot (2, 3, 4);
        plot (Xinf(:,4), L, 'k', 0, 0, 'k.');
        ylabel('depth, m'); xlabel('res-detritus, muM');

        subplot (2, 3, 5);
        plot (Xinf(:,5), L, 'g', 0, 0, 'g.');
        ylabel('depth, m'); xlabel('structure, muM');

        subplot (2, 3, 6);
        plot (Xinf(:,6), L, 'r', 0, 0, 'r.', ...
	      Xinf(:,7), L, 'k', 0, 0, 'k.', ...
	      Xinf(:,8), L, 'b', 0, 0, 'b.');
        ylabel('depth, m'); xlabel('reserves, muM');

  end





