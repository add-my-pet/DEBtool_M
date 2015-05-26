function [c, b] = pirt (p, tcw, tbw)
  %% [c, b] = pirt (p, tcw, tbw)
  %% created at 2002/10/28 by Bas Kooijman, modified 2010/05/27
  %% calculates concentrations of substrate and
  %%  microbial biomass as functions of time in a batch culture
  %%  using the marr-pirt model
  %% p: parameter vector, see initial values and dpirt
  %% tcw: (nc,k) matrix with concentrations in column 1
  %% tbw: (nb,k) matrix with times in column 1
  %% c: (nc,1) matrix with calculated concentrations
  %% b: (nb,1) matrix with calculated biomass

  global par;
  par = p(3:6); % copy parameters for transfer to routine dpirt
  
  x0 = p(1:2); % initial values for concentration and biomass
  
  [t c] = ode45('dpirt', tcw(:,1), x0); c = c(:,1);
  if exist('tbw', 'var')== 1
    [t b] = ode45('dpirt', tbw(:,1), x0); 
    b = b(:,2);
  end
  
