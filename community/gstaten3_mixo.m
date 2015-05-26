function [X, info]= gstaten3 (X_t)
  %% created: 2001/09/07 by Bas Kooijman
  %% gets steady states from initial estimates for 3-reserve mixotrophs
  %% calls findstaten3
  %% info =
  %%   'N' nitrogen limitation
  %%   'E' no positive equilibria
  opt = optimset('display','off');

  global j_L_F Ctot Ntot n_NV n_NE n_NEN;

  %% N limitation
  XN = zeros(8,1);
  [XN([2 3 4 6 7 8]), val, inf] = fsolve('findstaten3',X_t([2 3 4 6 7 8]),opt);
  N = XN(2); DV = XN(3); DE = XN(4); E = XN(6); EC = XN(7); EN = XN(8);
  
  XN(5) = V = (Ntot - N - n_NV*DV - n_NE*DE - n_NE*E - n_NEN*EN)/n_NV;
  XN(1) = Ctot - DV - DE - V - E - EC;
  
  if 0 == prod(XN > 0) % no positive solution
    fprintf (['No pos. equil. for Light = ', num2str(j_L_F), ...
	     '; Ctot = ', num2str(Ctot), ...
	     '; Ntot = ', num2str(Ntot), ' on N-lim branch\n']);
    X = [Ctot Ntot 0 0 0 0 0 0]'; % end of branch
    info = 'E';
  else
    X = XN; % N limitation
    info = 'N';
  end
