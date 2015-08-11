%% get_lb
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function [lb, info] = get_lb(p, eb, lb0)
  % created 2007/08/15 by Bas Kooijman; modified 2013/08/19, 2015/01/20
  
  %% Syntax
  % [lb, info] = <../get_lb.m *get_lb*>(p, eb, lb0)
  
  %% Description
  % Obtains scaled length at birth, given the scaled reserve density at birth. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b (see below)
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb0: optional scalar with initial estimate for scaled length at birth (default lb0: lb for k = 1)
  %  
  % Output
  %
  % * lb: scalar with scaled length at birth 
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % The theory behind get_lb, get_tb and get_ue0 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b>.
  % Solves y(x_b) = y_b  for lb with explicit solution for y(x)
  %   y(x) = x e_H/(1-kap) = x g u_H/ l^3
  %   and y_b = x_b g u_H^b/ ((1-kap)l_b^3)
  %   d/dx y = r(x) - y s(x);
  %   with solution y(x) = v(x) \int r(x)/ v(x) dx
  %   and v(x) = exp(- \int s(x) dx).
  % A Newton Raphson scheme is used with Euler integration, starting from an optional initial value. 
  % Replacement of Euler integration by ode23: <get_lb1.html *get_lb1*>,
  %  but that function is much lower.
  % Shooting method: <get_lb2.html *get_lb2*>.
  % Bisection method (via fzero): <get_lb3.html *get_lb3*>.
  % In case of no convergence, <get_lb2.html *get_lb2*> is run automatically as backup.
  % Consider the application of <get_lb_foetus.html *get_lb_foetus*> for an alternative initial value.

  %% Example of use
  % See <../mydata_ue0.m *mydata_ue0*>
  
  %  unpack p
  g = p(1);   % g = [E_G] * v/ kap * {p_Am}, energy investment ratio
  k = p(2);   % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm}

  info = 1;
  if ~exist('lb0', 'var')
    lb0 = [];
  end
   
  if k == 1
    lb = vHb^(1/ 3); % exact solution for k = 1
    info = 1;
    return;
  end
  if isempty(lb0)
    lb = vHb^(1/ 3); % exact solution for k = 1     
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
  
  b = beta0(x, xb)/ (3 * g); t0 = xb * g * vHb;
  i = 0; norm = 1; % make sure that we start Newton Raphson procedure
  ni = 100; % max number of iterations
  
  while i < ni  && norm > 1e-8
    l = x3 ./ (xb3/ lb - b);
    s = (k - x) ./ (1 - x) .* l/ g ./ x;
    v = exp( - dx * cumsum(s)); vb = v(n);
    r = (g + l); rv = r ./ v;
    t = t0/ lb^3/ vb - dx * sum(rv);
    dl = xb3/ lb^2 * l .^ 2 ./ x3; dlnl = dl ./ l;
    dv = v .* exp( - dx * cumsum(s .* dlnl));
    dvb = dv(n); dlnv = dv ./ v; dlnvb = dlnv(n);
    dr = dl; dlnr = dr ./ r;
    dt = - t0/ lb^3/ vb * (3/ lb + dlnvb) - dx * sum((dlnr - dlnv) .* rv);
    % [i lb t dt] % print progress
    lb = lb - t/ dt; % Newton Raphson step
    norm = t^2; i = i + 1;
  end
    
  if i == ni || lb < 0 || lb > 1 || isnan(norm) || isnan(lb) % no convergence
    % try to recover with a shooting method
    if isempty(lb0)
      [lb, info] = get_lb2(p, eb);
    elseif lb0 < 1 && lb0 > 0
      [lb, info] = get_lb2(p, eb, lb0);
    else
      [lb, info] = get_lb2(p, eb);
    end
  end
  
  if info == 0
    fprintf('warning get_lb: no convergence of l_b \n');
  end
