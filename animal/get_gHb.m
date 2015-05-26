%% get_eHb
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function gHb = get_gHb(p, eb, lb0)
  % created 2015/03/31 by Bas Kooijman
  
  %% Syntax
  % eHb = <../get_gHb.m *get_gHb*>(p, eb, lb0)
  
  %% Description
  % Obtains scaled scaled reserve density from scaled structural length at birth 
  %
  % Input
  %
  % * p: 4-vector with parameters: g, k, lb (see below)
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb0: optional scalar with initial estimate for scaled length at birth (default lb0: lb for k = 1)
  %  
  % Output
  %
  % * gHb: scalar with maturity investment ratio at birth: 
  %    [E_H^b]/ (1 - kap) [E_m]
  
 
  %  unpack p
  g   = p(1); % g = [E_G] * v/ kap * {p_Am}, energy investment ratio
  k   = p(2); % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lb =  p(3); % L_b/ L_m, sacled length at birth
  

  if ~exist('eb','var')
    eb = 1;
  elseif isempty(eb)
    eb = 1;
  end
       
  n = 1000 + round(1000 * max(0, k - 1)); xb = g/ (g + eb); xb3 = xb ^ (1/3);
  x = linspace(1e-6, xb, n); dx = xb/ n;  x3 = x .^ (1/3);
  
  b = beta0(x, xb)/ (3 * g);
     
  l = x3 ./ (xb3/ lb - b);
  s = (k - x) ./ (1 - x) .* l/ g ./ x;
  v = exp( - dx * cumsum(s)); vb = v(n);
  r = (g + l); rv = r ./ v;    
  gHb = vb * dx * sum(rv)/ xb;
    
