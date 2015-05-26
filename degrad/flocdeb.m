function [c, b, d] = flocdeb (p, tcw, tbw, tdw)
  %% [c, b, d] = flocdeb (p, tcw, tbw, tdw)
  %% created at 2002/10/31 by Bas Kooijman, modfied 2010/06/27
  %% calculates concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the deb model for flocs
  %% p: parameter vector, initial values and see dflocdeb
  %% tcw: (nc,k) matrix with times in column 1
  %% tbw: (nb,k) matrix with times in column 1
  %% tdw: (nd,k) matrix with times in column 1
  %% c: (nc,1) matrix with calculated concentrations
  %% b: (nb,1) matrix with calculated living biomass
  %% d: (nd,1) matrix with calculated dead biomass

  global par;
  par = p(6:13);  % copy parameters for transfer to routine dflocpirt
  
  x0 = p(1:5); % initial values for concentration and living structure,
				% reserve density, dead structure, dead reserve
  
  [tc, c] = ode45('dflocdeb', tcw(:,1), x0); c = c(:,1);
  [tb, b] = ode45('dflocdeb', tbw(:,1), x0); b = b(:,2);
  [td, d] = ode45('dflocdeb', tdw(:,1), x0); d = d(:,4);
  %% column 3 has reserve densities, but these are not assumed to be measured  
