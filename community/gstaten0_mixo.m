function [X, info]= gstaten0 (X_t)
  %% created: 2001/09/07 by Bas Kooijman
  %% gets steady states from initial estimates for 0-reserve mixotrophs
  %% calls findstaten0
  %% info =
  %%   'N' nitrogen limitation
  %%   'E' no positive equilibria
  opt = optimset('display','off');

  global j_L_F Ctot Ntot n_NV;

  %% N limitation
  XN = zeros(4,1);
  [XN([2 3]), val, infN] = fsolve('findstaten0',X_t([2 3]),opt);
  N = XN(2); D = XN(3);
  
  V = (Ntot - N - n_NV*D)/n_NV;
  XN(4) = V;
  XN(1) = Ctot - D - V;
  
  if 0 == prod(XN > 0) | (infN <= 0) % no positive solution
    fprintf (['No pos. equil. for Light = ', num2str(j_L_F), ...
	     '; Ctot = ', num2str(Ctot), ...
	     '; Ntot = ', num2str(Ntot), ' on N-lim branch\n']);
    X = [Ctot Ntot 0 0]'; % end of branch
    info = 'E';
  else
    X = XN; % N limitation
    info = 'N';
  end
