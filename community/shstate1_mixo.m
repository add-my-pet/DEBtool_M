function shstate1_mixo (j)
  %  created: 2001/09/03 by Bas Kooijman
  %  equilibrium_plots for 'mixo'
  %  Calls for state1, gstate1

  %  State vector:
  %  (1) C DIC (2) N DIN (3) DV V-Detritus (4) DE E-Detritus
  %  (5) V structure (6) E reserve

  global n_NV n_NE;

  pars1_mixo; % set parameter values
  LTOT = j_L_F; CTOT = Ctot; NTOT = Ntot;

  %  Ntot fixed, Ctot from CTOT to zero
  nC = 100; C = linspace(0, CTOT, nC);
  x = state1_mixo(CTOT, NTOT); xx = gstate1_mixo(x); x = xx;
  XC = zeros(nC, 6); XC(nC, :) = x'; i = nC;

  while (length(x) == sum(x > 0)) && (i > 1) % as long as all compounds positive
    i = i - 1; Ctot = C(i);
    x = gstate1_mixo(x);			  
    XC(i,:) = x';
  end
  %  remove all-zero values and first one
  i = i+1;
  XC = XC(i:nC,:); C = C(i:nC); 
  
  DN = [XC(:,2), XC(:,2) + n_NV*XC(:,3)];
  DN = [DN, DN(:,2) + n_NE*XC(:,4)];
  DN = [DN, DN(:,3) + n_NV*XC(:,5)];
  DN = [DN, DN(:,4) + n_NE*XC(:,6)];

  %  Ctot fixed, Ntot from NTOT to zero
  nN = 200; N = linspace(0, NTOT, nN);
  Ctot = CTOT; x = xx; i = nN;
  XN = zeros(nN, 6); XN(nN, :) = x';

  while (length(x) ==  sum(x> 0)) && (i > 1)  % as long as all compounds positive
    i = i - 1; Ntot = N(i);
    x = gstate1_mixo(x);
    XN(i,:) = x';
  end
  %  remove all-zero values and first one
  i = i+1;
  XN = XN(i:nN,:); N = N(i:nN); 

  DC = [XN(:,1), XN(:,1) + XN(:,3)];
  DC = [DC, DC(:,2) + XN(:,4)];
  DC = [DC, DC(:,3) + XN(:,5)];
  DC = [DC, DC(:,4) + XN(:,6)];

  %  Ctot and Ntot fixed, light from j_L_F to zero
  nL = 100; L = linspace(0, LTOT, nL); % set light values
  Ctot = CTOT; Ntot = NTOT; x = xx;
  XL = zeros(nL, 6); XL(nL,:) = x'; i = nL; % initiate state matrix

  while ( length(x) ==  sum(x > 0)) && (i > 1) % as long as all compounds positive
    i = i - 1; j_L_F = L(i);
    x = gstate1_mixo(x);
    XL(i,:) = x';
  end
  %  remove all-zero values and first one
  i = i+1;
  XL = XL(i:nL,:); L = L(i:nL); 

  %  cumulative nitrogen
  DLN = [XL(:,2), XL(:,2) + n_NV*XL(:,3)];
  DLN = [DLN, DLN(:,2) + n_NE*XL(:,4)];
  DLN = [DLN, DLN(:,3) + n_NV*XL(:,5)];
  DLN = [DLN, DLN(:,4) + n_NE*XL(:,6)];

  %  cumulative carbon
  DLC = [XL(:,1), XL(:,1) + XL(:,3)];
  DLC = [DLC, DLC(:,2) + XL(:,4)];
  DLC = [DLC, DLC(:,3) + XL(:,5)];
  DLC = [DLC, DLC(:,4) + XL(:,6)];

  % plotting
  
  if exist('j', 'var') == 1 % single plot mode
    clf;
    switch j
	
      case 1
        plot (C, DN(:,1), 'b', C, DN(:,2), 'b.', ...
              C, DN(:,3), 'b', C, DN(:,4), 'b.', ...
	          C, DN(:,5), 'b');
        xlabel('carbon, muM'); ylabel('nitrogen, muM'); 

      case 2
        plot (N, DC(:,1), 'k', N, DC(:,2), 'k.', ...
              N, DC(:,3), 'k', N, DC(:,4), 'k.', ...
	          N, DC(:,5), 'k');
        xlabel('nitrogen, muM'); ylabel('carbon, muM'); 

      case 3
        plot (- L, DLN(:,1), 'b', - L, DLN(:,2), 'b.', ...
              - L, DLN(:,3), 'b', - L, DLN(:,4), 'b.', ...
	          - L, DLN(:,5), 'b');
        xlabel('light, mol/d'); ylabel('nitrogen, muM');

      case 4
        plot (- L, DLC(:,1), 'k', - L, DLC(:,2), 'k.', ...
              - L, DLC(:,3), 'k', - L, DLC(:,4), 'k.', ...
	          - L, DLC(:,5), 'k');
        xlabel('light, mol/d'); ylabel('carbon, muM');

      otherwise
	return;

    end
  else % multiple plot mode
    %% multiplot(2, 2);
    
        subplot (2, 2, 1);
        plot (C, DN(:,1), 'b', C, DN(:,2), 'b.', ...
              C, DN(:,3), 'b', C, DN(:,4), 'b.', ...
	          C, DN(:,5), 'b');
        xlabel('carbon, muM'); ylabel('nitrogen, muM'); 

        subplot (2, 2, 2);
        plot (N, DC(:,1), 'k', N, DC(:,2), 'k.', ...
              N, DC(:,3), 'k', N, DC(:,4), 'k.', ...
	          N, DC(:,5), 'k');
        xlabel('nitrogen, muM'); ylabel('carbon, muM'); 
	
        subplot (2, 2, 3);
        plot (- L, DLN(:,1), 'b', - L, DLN(:,2), 'b.', ...
              - L, DLN(:,3), 'b', - L, DLN(:,4), 'b.', ...
	          - L, DLN(:,5), 'b');
        xlabel('light, mol/d'); ylabel('nitrogen, muM');

        subplot (2, 2, 4);
        plot (- L, DLC(:,1), 'k', - L, DLC(:,2), 'k.', ...
              - L, DLC(:,3), 'k', - L, DLC(:,4), 'k.', ...
	          - L, DLC(:,5), 'k');
        xlabel('light, mol/d'); ylabel('carbon, muM');

    %% multiplot (0, 0);
  end
