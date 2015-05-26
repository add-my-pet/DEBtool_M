function [c, b] = deb (p, tcw, tbw)
  %% [c, b] = deb (p, tcw, tbw)
  %% created at 2002/10/28 by Bas Kooijman, modified 2010/06/27
  %% calculates concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the DEB model
  %% p: parameter vector, see initial values and ddeb
  %% tcw: (nc,k) matrix with times in column 1
  %% tbw: (nb,k) matrix with times in column 1
  %% c: (nc,1) matrix with calculated concentrations
  %% b: (nb,1) matrix with calculated biomass (= structure)

  global par;
  par = p(3:7);   % copy parameters for transfer to routine ddeb

  %% initial values for concentration, structure, max scaled res density
  x0 = [p(1:2,1); p(4)/(p(6)*p(5))]; 
  
  [t, c] = ode45('ddeb', tcw(:,1), x0); c = c(:,1); % concentration of substrate
  [t, b] = ode45('ddeb', tbw(:,1), x0); b = b(:,2); % structure
  







