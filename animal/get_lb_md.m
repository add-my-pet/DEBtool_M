%% get_lb_md
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function [lb, info] = get_lb_md(p, eb, lb0)
  % created 2015/03/31 by Bas Kooijman
  
  %% Syntax
  % [lb, info] = <../get_lb_md.m *get_lb_md*>(p, eb, lb0)
  
  %% Description
  % Obtains scaled length at birth, given the scaled reserve density at birth in case of birth at specified maturity density. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, g_H^b (see below)
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb0: optional scalar with initial estimate for scaled length at birth (default lb0: lb for k = 1)
  %  
  % Output
  %
  % * lb: scalar with scaled length at birth 
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_lb.m *get_lb*> for birth at specified maturity.
  % Maturity density must increase, so k_J < k_M
  
  %% Example of use
  % get_lb_md([.4;.1;.5])
  
  %  unpack p
  g   = p(1); % g = [E_G] * v/ kap * {p_Am}, energy investment ratio
  k   = p(2); % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  gHb = p(3); % gHb = E_H^b/ L_b^3.[E_m].(1 - kap), with [E_m] = v/ {p_Am}, maturity density at birth
  
  if gHb < g || gHb > g/k
    info = 0;
    lb = [];
    fprintf('warning get_lb_md: gHb outside range \n');
    return
  end
  
  info = 1;
  if ~exist('lb0', 'var') || isempty(lb0)
    lb = .1;
  else
    lb = lb0;
  end
  if ~exist('eb','var')
    eb = 1;
  elseif isempty(eb)
    eb = 1;
  end
       
  n = 1000 + round(1000 * max(0, k - 1)); xb = g/ (g + eb); xb3 = xb ^ (1/3);
  x = linspace(1e-6, xb, n); dx = xb/ n;  x3 = x .^ (1/3);
  
  b = beta0(x, xb)/ (3 * g);
  i = 0; norm = 1; % make sure that we start Newton Raphson procedure
  ni = 100; % max number of iterations
  
  while i < ni  && norm > 1e-10
    l = x3 ./ (xb3/ lb - b);
    s = (k - x) ./ (1 - x) .* l/ g ./ x;
    v = exp( - dx * cumsum(s)); vb = v(n);
    r = (g + l); rv = r ./ v;
    t = xb * gHb/ vb - dx * sum(rv);
    dl = xb3/ lb^2 * l .^ 2 ./ x3; dlnl = dl ./ l;
    dv = v .* exp( - dx * cumsum(s .* dlnl));
    dvb = dv(n); dlnv = dv ./ v; dlnvb = dlnv(n);
    dr = dl; dlnr = dr ./ r;
    dt = - xb * gHb/ vb * dlnvb - dx * sum((dlnr - dlnv) .* rv);
    lb = lb - t/ dt; % Newton Raphson step
    norm = t^2; i = i + 1;
  end
    
  if i == ni || lb < 0 || lb > 1 || isnan(norm) % no convergence
    info = 0;
    fprintf('warning get_lb_md: no convergence of l_b \n');
  end
