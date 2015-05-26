function [c, b, d] = flocpirt (p, tcw, tbw, tdw)
  %% [c, b, d] = flocpirt (p, tcw, tbw, tdw)
  %% created at 2002/10/30 by Bas Kooijman, modified 2010/06/27
  %% calculates concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the pirt model for flocs
  %% p: parameter vector, see initial values and dflocpirt
  %% tcw: (nc,k) matrix with times in column 1
  %% tbw: (nb,k) matrix with times in column 1
  %% tdw: (nd,k) matrix with times in column 1
  %% c: (nc,1) matrix with calculated concentrations
  %% b: (nb,1) matrix with calculated living biomass
  %% d: (nd,1) matrix with calculated dead biomass

  global par;
  par = p(4:9); % copy parameters for transfer to routine dflocpirt
  
  x0 = p(1:3); % initial values for concentration and living, dead biomass
  
  [tc c] = ode45('dflocpirt', tcw(:,1), x0); c = c(:,1);
  [tb b] = ode45('dflocpirt', tbw(:,1), x0); b = b(:,2);
  [td d] = ode45('dflocpirt', tdw(:,1), x0); d = d(:,3);
  
