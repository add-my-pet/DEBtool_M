function [X, info] = gstate0_mixo (X_t)
  %% created: 2001/09/07 by Bas Kooijman, modified 2009/01/05
  %% gets steady states from initial estimates for 0-reserve mixotrophs 
  %% calls findstatec0 findstaten0
  %% X and X_t: (1) C: DIC (2) N: DIN (3) D: Detritus (4) V: Structure
  %% info =
  %%   'C' carbon limitation
  %%   'N' nitrogen limitation
  %%   'L' carbon and nitrogen limitation
  %%   'B' bifurcation: two solutions
  %%   'E' no positive equilibria
  %% if info == 'B', X has two columns

  global j_L_F Ctot Ntot n_NV n_NE;

  %% analytic solution for small K_NV
  %% X = state0_mixo(Ctot,Ntot); info = 'C'; return
  %% [t X_t] = ode23('dstate0_mixo',[0;100],X_t);
  %% X_t = X_t(2,:)';

  %% find D,V
  %% XC = zeros(4,1);
  %% [XC([3 4]) infC] = fsolve('findstate0_mixo',X_t([3 4]));
  %% D = XC(1); V = XC(3);
  
  %% XC(1) = Ctot - D - V;
  %% XC(2) = Ntot - n_NV*D - n_NV*V;
  
  %% find C,D
  opt = optimset('display','off');

  XC = zeros(4,1);
  [XC([1 3]), val, infC] = fsolve('findstatec0_mixo', X_t([1 3]), opt);
  C = XC(1); D = XC(3);
  
  V = Ctot - C - D;
  XC(4) = V;
  XC(2) = Ntot - n_NV*D - n_NV*V;

  %% find N,D
  XN = zeros(4,1);
  [XN([2 3]), val, infN] = fsolve('findstaten0_mixo',X_t([2 3]), opt);
  N = XN(2); D = XN(3);
  
  V = (Ntot - N - n_NV*D)/n_NV;
  XN(4) = V;
  XN(1) = Ctot - D - V;
  
  if (length(XC) == sum(XC > 0)) && (length(XN) == sum(XN > 0)) && ...
	(infC > 0) && (infN > 0) % two positive solutions
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
  elseif (length(XC) == sum(XC > 0)) && (infC > 0)
    X = XC; % C limitation
    info = 'C';
  elseif (length(XN) == sum(XN > 0)) && (infN > 0)
    X = XN; % N limitation
    info = 'N';
  else % no positive solutions
    fprintf (['No pos. equilibrium for Light = ', num2str(j_L_F), ...
	     '; Ctot = ', num2str(Ctot), ...
	     '; Ntot = ', num2str(Ntot), '\n']);
    X = [Ctot Ntot 0 0]'; % end of branch
    info = 'E';
  end