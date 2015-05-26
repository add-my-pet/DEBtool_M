function shstate0_mixo (j)
  %% created: 2001/09/07 by Bas Kooijman, modified 2009/01/05
  %% equilibrium_plots for 'mixo'
  %% Calls for state0_mixo, gstate0_mixo, gstatec0_mixo, gstaten0_mixo,


  %% State vector:
  %% (1) C DIC (2) N DIN (3) D Detritus (4) V structure

  global j_L_F Ctot Ntot n_NV;

  %% LOADPATH = '../lib//:';
  %% fssolve_options('report',0);

  pars0_mixo; % set parameter values
  LTOT= j_L_F; CTOT = Ctot; NTOT = Ntot; % copy j_L_F, Ctot and Ntot values
  x = state0_mixo(CTOT, NTOT); % get first initial estimate
  [xx, infox] = gstate0_mixo(x); % get first data-point in L,C,N-diagrams

  %% Light and Ntot fixed, Ctot from CTOT to zero
  nC = 200; C = linspace(0, CTOT, nC); % set Ctot values
  x = xx; info = infox; % make copies of first data point
  XC = zeros(nC, 4); XC(nC, :) = x'; i = nC; % initiate state matrix

  while (info ~= 'E') && (i > 1)  && (sum(x>0) == length(x))
				% as long as all compounds positive
    i = i - 1; % loop backwards from high Ctot to zero
    Ctot = C(i);
    x = state0_mixo(Ctot,Ntot);
    [x, info] = gstate0_mixo(x);
    if info == 'B' % bifurcation point detected
      ii = i; % make copy of counter, we will need it twice
      xC = x(:,1); xN = x(:,2);
      XC(i,:) = xC';
      while (info ~= 'E') && (ii > 1) % complete C-limitation branch
	    ii = ii - 1;
        Ctot = C(ii);
	    [xC info] = gstatec0_mixo(xC);
	    XC(ii,:) = xC';
      end
      ii = i; nCC = ii; info = 'B';
      XCC = zeros(nCC+1,4); % initiate N-limitation branch
      XCC(nCC+1,:) = XC(i+1,:); % copy last point before branch
      XCC(nCC,:) = xN'; % paste first point on branch
      while (info ~= 'E') && (ii > 1) % follow N-limitation branch
	    ii = ii - 1;
        Ctot = C(ii);
	    [xN info] = gstaten0_mixo(xN);
	    XCC(ii,:) = xN';
      end
      break % no further Ctot reduction
    end
    XC(i,:) = x';
  end

  if exist('XCC') == 1
    %% remove all-zero values and first one
    ii = ii + 1;
    XCC = XCC(ii:(nCC+1),:); CC = C(ii:(nCC+1));

    %% cumulative nitrogen for C-lim branch    
    DNN = [XCC(:,2), XCC(:,2) + n_NV*XCC(:,3)];
    DNN = [DNN, DNN(:,2) + n_NV*XCC(:,4)];
  end

  %% remove all-zero values and first one
  i = i+1;
  XC = XC(i:nC,:); C = C(i:nC); 
  
  DN = [XC(:,2), XC(:,2) + n_NV*XC(:,3)];
  DN = [DN, DN(:,2) + n_NV*XC(:,4)];

  %% Light and Ctot fixed, Ntot from NTOT to zero
  nN = 200; N = linspace(0, NTOT, nN); % set Ntot values
  Ctot = CTOT; x = xx; i = nN; info = infox;
  XN = zeros(nN, 4); XN(nN, :) = x'; % initiate state matrix

  while (info ~= 'E') && (i > 1)  && (x(4) > 1e-4)
				% as long as all compounds positive
    i = i - 1;
    Ntot = N(i);
    [x info] = gstate0_mixo(x);
    if info == 'B' % bifurcation point detected
      ii = i;
      xC = x(:,1); xN = x(:,2);
      XN(i,:) = xN';
      while (info ~= 'E') && (ii > 1) % complete N-limitation branch
	    ii = ii - 1;
        Ntot = N(ii);
	    [xN info] = gstaten0_mixo(xN);
	    XN(ii,:) = xN';
      end
      nNN = i;
      ii = i; info = 'B';
      XNN = zeros(nNN + 1, 4); % initiate C-limitation branch
      XNN(nNN+1, :) = XN(i+1, :); % copy last point before branch
      XNN(nNN, :) = xC'; % paste first point on branch
      while (info ~= 'E') && (ii > 1) % follow C-limitation branch
	    ii = ii - 1;
	    Ntot = N(ii);
	    [xC info] = gstatec0_mixo(xC);
	    XNN(ii,:) = xC';
      end
      break % no further Ntot reduction
    end
    XN(i,:) = x';
  end

  if exist('XNN') == 1
    %% remove all-zero values and first one
    ii = ii+1;
    XNN = XNN(ii:(nNN+1),:); NN = N(ii:(nNN+1));

    %% cumulative carbon
    DCC = [XNN(:,1), XNN(:,1) + XNN(:,3)];
    DCC = [DCC, DCC(:,2) + XNN(:,4)];
  end

  %% remove all-zero values and first one
  i = i+1;
  XN = XN(i:nN,:); N = N(i:nN); 

  DC = [XN(:,1), XN(:,1) + XN(:,3)];
  DC = [DC, DC(:,2) + XN(:,4)];

  %% Ctot and Ntot fixed, light from j_L_F to zero
  nL = 100; L = linspace(1e-3, LTOT, nL); % set light values
  Ctot = CTOT; Ntot = NTOT; x = xx; info = infox;
  XL = zeros(nL, 4); XL(nL,:) = x'; i = nL; % initiate state matrix

  while (info ~= 'E') && (i > 1) && (x(4) > 1e-4)
				% as long as all compounds positive
    i = i - 1;
    j_L_F = L(i);
    [x info] = gstate0_mixo(x);
    if info == 'B' % bifurcation point detected
      ii = i;
      xC = x(:,1); xN = x(:,2);
      XL(i,:) = xC';
      while (info ~= 'E') && (ii > 1) && (sum(xC > 0) == length(xC)) % complete C-limitation branch
	    ii = ii - 1;
        j_L_F = L(ii);
	    [xC info] = gstatec0_mixo(xx);
	    XL(ii,:) = xC';
      end
      nLC = i;
      ii = i; info = 'B';
      XLC = zeros(nLC+1,4); % initiate N-limitation branch
      XLC(nLC+1,:) = XL(i+1,:); % copy last point before branch
      XLC(nLC,:) = xN'; % paste first point on branch
      while (info ~= 'E') && (ii > 1) && (sum(xN == length(xN)) > 0)% follow N-limitation branch
	    ii = ii - 1;
        j_L_F = L(ii);
	    [xN info] = gstaten0_mixo(xx);
	    XLC(ii,:) = xN';
      end
      break % no further Ctot reduction
    end
    XL(i,:) = x';
  end

  if exist('XLC') == 1
    %% remove all-zero values and first one
    ii = ii+1;
    XLC = XLC(ii:(nLC+1),:); LC = L(ii:(nLC+1));

    %% cumulative carbon for side branch    
    DLCN = [XLC(:,1), XLC(:,1) + XLC(:,3)];
    DLCN = [DLCN, DLCN(:,2) + XLC(:,4)];

    %% cumulative nitrogen for side branch    
    DLNC = [XLC(:,2), XLC(:,2) + n_NV*XLC(:,3)];
    DLNC = [DLNC, DLNC(:,2) + n_NV*XLC(:,4)];
  end

  %% remove all-zero values and first one
  i = i+1;
  XL = XL(i:nL,:); L = L(i:nL); 

  %% cumulative nitrogen
  DLN = [XL(:,2), XL(:,2) + n_NV*XL(:,3)];
  DLN = [DLN, DLN(:,2) + n_NV*XL(:,4)];

  %% cumulative carbon
  DLC = [XL(:,1), XL(:,1) + XL(:,3)];
  DLC = [DLC, DLC(:,2) + XL(:,4)];
  
  %% plotting
  
  if exist('j')==1 % single plot mode
    clf;
    hold on;
    switch j
	
      case 1
        plot (C, DN(:,1), 'b', C, DN(:,2), 'b', C, DN(:,3), 'b');
        xlabel('carbon, muM'); ylabel('nitrogen, muM'); 
    	if exist('DNN') == 1
          plot (CC, DNN(:,1), 'm', CC, DNN(:,2), 'm', ...
                CC, DNN(:,3), 'm');
	   end

      case 2
        plot (N, DC(:,1), 'k', N, DC(:,2), 'k', N, DC(:,3), 'k');
        xlabel('nitrogen, muM'); ylabel('carbon, muM'); 
	    if exist('DCC') == 1
          plot (NN, DCC(:,1), 'm', NN, DCC(:,2), 'm', ...
                NN, DCC(:,3), 'm');
	    end

      case 3
        plot (- L, DLN(:,1), 'b', - L, DLN(:,2), 'b', - L, DLN(:,3), 'b');
        xlabel('light, mol/d'); ylabel('nitrogen, muM');
	    if exist('XLC') == 1
	      plot (- LC, DLNC(:,1), 'm', - LC, DLNC(:,2), 'm', ...
                - LC, DLNC(:,3), 'm');
	    end

      case 4
        plot (- L, DLC(:,1), 'k', - L, DLC(:,2), 'k', - L, DLC(:,3), 'k');
        xlabel('light, mol/d'); ylabel('carbon, muM');
	    if exist('XLC') == 1
	      plot (- LC, DLCN(:,1), 'm', - LC, DLCN(:,2), 'm', ...
                - LC, DLCN(:,3), 'm');
	    end

      otherwise
	return;

    end
  else % multiple plot mode
    %% multiplot(2, 2);
    clf;
    
        subplot (2, 2, 1); hold on;
        plot (C, DN(:,1), 'b', C, DN(:,2), 'b', C, DN(:,3), 'b');
        xlabel('carbon, muM'); ylabel('nitrogen, muM'); 
	    if exist('DNN') == 1
          plot (CC, DNN(:,1), 'm', CC, DNN(:,2), 'm', ...
                CC, DNN(:,3), 'm');
        end

        subplot (2, 2, 2); hold on;
        plot (N, DC(:,1), 'k', N, DC(:,2), 'k', N, DC(:,3), 'k');
        xlabel('nitrogen, muM'); ylabel('carbon, muM'); 
	    if exist('DCC') == 1
          plot (NN, DCC(:,1), 'm', NN, DCC(:,2), 'm', ...
                NN, DCC(:,3), 'm');
	    end
	
        subplot (2, 2, 3); hold on;
        plot (- L, DLN(:,1), 'b', - L, DLN(:,2), 'b', - L, DLN(:,3), 'b');
        xlabel('light, mol/d'); ylabel('nitrogen, muM');
	    if exist('XLC') == 1
	      plot (- LC, DLNC(:,1), 'm', - LC, DLNC(:,2), 'm', ...
                - LC, DLNC(:,3), 'm');
	    end

        subplot (2, 2, 4); hold on;
        plot (- L, DLC(:,1), 'k', - L, DLC(:,2), 'k', - L, DLC(:,3), 'k');
        xlabel('light, mol/d'); ylabel('carbon, muM');
	    if exist('XLC') == 1
	      plot (- LC, DLCN(:,1), 'm', - LC, DLCN(:,2), 'm', ...
                - LC, DLCN(:,3), 'm');
	    end

    %% multiplot (0, 0);
  end
