function [X, info]= gstate3_mixo (X_t)
  %% created: 2001/09/07 by Bas Kooijman, modified 2009/01/05
  %% gets steady states from initial estimates for 3-reserve mixotrophs
  %% calls findstateC3_mixo findstateN3_mixo
  %% info =
  %%   'C' carbon limitation
  %%   'N' nitrogen limitation
  %%   'L' carbon and nitrogen limitation
  %%   'B' bifurcation: two solutions
  %%   'E' no positive equilibria
  %% if info == 'B', X has two columns
  opt = optimset('display','off');

  global j_L_F Ctot Ntot n_NV n_NE n_NEN;

  %% assume C limitation
  XC = zeros(8,1);
  [XC([1 3 4 6 7 8]), val, infC] = fsolve('findstatec3_mixo',X_t([1 3 4 6 7 8]),opt);
  C = XC(1); DV = XC(3); DE = XC(4); E = XC(6); EC = XC(7); EN = XC(8);
  
  V = Ctot - C - DV - DE - E - EC;
  XC(5) = V;
  XC(2) = Ntot - n_NV*DV - n_NE*DE - n_NV*V - n_NE*E - n_NEN*EN;
  
  %% assume N limitation
  XN = zeros(8,1);
  [XN([2 3 4 6 7 8]), val, infN] = fsolve('findstaten3_mixo',X_t([2 3 4 6 7 8]),opt);
  N = XN(2); DV = XN(3); DE = XN(4); E = XN(6); EC = XN(7); EN = XN(8);
  
  V = (Ntot - N - n_NV*DV - n_NE*DE - n_NE*E - n_NEN*EN)/n_NV;
  XC(5) = V;
  XN(1) = Ctot - DV - DE - V - E - EC;
  
  if (length(XC) == sum(XC > 0)) && (length(XN) == sum(XN > 0)) && ...
	(infN == 1) && (infC == 1) % two positive solutions
    if max(abs(XC - XN)) > 1e-3 % the solutions differ
      info = 'B'; % bifurcation
      fprintf (['2 equilibria for Light = ', num2str(j_L_F), ...
	       '; Ctot = ', num2str(Ctot), ...
	       '; Ntot = ', num2str(Ntot), '\n']);
      X = [XC, XN];
    else % the solutions are identical
      info = 'L'; % both C and N limitation
      X = XC;
    end	   
  elseif (length(XC) == sum(XC > 0)) && (infC == 1)
    X = XC; % C limitation
    info = 'C';
  elseif (length(XN) == sum(XN > 0)) && (infN == 1)
    X = XN; % N limitation
    info = 'N';
  else % no positive solutions
    fprintf (['No pos. equilibrium for Light = ', num2str(j_L_F), ...
	     '; Ctot = ', num2str(Ctot), ...
	     '; Ntot = ', num2str(Ntot), '\n']);
    X = [Ctot Ntot 0 0 0 0 0 0]'; % end of branch
    info = 'E';
  end

