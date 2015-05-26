%% get_lb1
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function [lb info] = get_lb1(p, eb, lb0)
  % created 2007/08/02 by Bas Kooijman; modified 2013/08/19, 2015/01/18
  
  %% Syntax
  % [lb info] = <../get_lb1.m *get_lb1*> (p, eb, lb0)
  
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
  % Like <get_lb.html *get_lb*>, but using ode23, rather than Euler integration

  %  unpack p
  g = p(1);   % g = [E_G] * v/ kap * {p_Am}, energy investment ratio
  k = p(2);   % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm}

  info = 1;

  if ~exist('lb0','var') || k == 1
    lb = vHb ^ (1/3); % exact solution for k = 1
    if k == 1
      return;
    end
  elseif isempty(lb0)
    lb = vHb^(1/ 3); % exact solution for k = 1     
  else
    lb = lb0;
  end
  if ~exist('eb','var')
    eb = 1;
  elseif isempty(eb)
    eb = 1;
  end
   
  xb = g/ (g + eb);
  xb3 = xb^(1/ 3);
  t0 = xb * g * vHb;
  i = 0; norm = 1; % make sure that we start Newton Raphson procedure
  ni = 100; % max number of iterations
  
  while i < ni  && norm > 1e-8
    z0 = [1, 1, 0, 0]; % v(0), v'(0)/v(0); int_0^0 r(x)/ v(x) dx
    [x, z]  = ode23s(@dget_lb1, [1e-10; xb], z0, [], k, g, lb, xb, xb3);
    v  = z(end,1); % v(x_b)
    lv = z(end,2); % v'(x_b)/ v(x_b)
    rv = z(end,3); % int_0^xb r(x)/ v(x) dx
    w  = z(end,4); % int_0^xb (r'(x)/r(x) - v'(x)/v(x)) r(x)/v(x) dx
   
    t = t0/ lb^3/ v - rv;
    dt = - t0/ lb^3/ v * (3/ lb + lv) - w;
    lb = lb - t/ dt; % Newton Raphson step
    norm = t^2; i = i + 1;
  end
    
  if i == ni || lb < 0 || lb > 1
    fprintf(['warning get_lb1: no convergence of l_b within ', num2str(ni),' steps \n']);
    info = 0;
  end
  
end

% subfunction

function dz = dget_lb1(x, z, k, g, lb, xb, xb3)
  % modified 2009/09/29
  % dz = dget_lb2(x, z)
  % z: 4-vector with (v,dv,rv,w) of embryo
  % dz: 4-vector with d/dx (v,dv,rv,w)
  
  v  = z(1); % v(x)
  lv = z(2); % v'(x)/v(x); v'(x) = d/d l_b v(x)
  %rv = z(3); % r(x)/ v(x)
  %w  = z(4); % (r'(x)/r(x) - v'(x)/v(x)) r(x)/v(x)
  
  x3 = x^(1/ 3);
  l = x3/ (xb3/ lb - beta0(x, xb)/ 3/ g); % l(x)
  dl = (l/ lb)^2 * xb3/ x3; % l'(x)
  
  dv = - v * (k - x)/ (1 - x) * l/ g/ x; % d/dx v(x)

  dlv = - lv * (k - x)/ (1 - x) * dl/ g/ x; % d/dx v'(x)/v(x)

  r = l + g;
  drv = r/ v; % r(x)/ v(x)

  lr = dl/ r; % r'(x)/ r(x)
  dw = (lr - lv) * drv;
  
  dz = [dv; dlv; drv; dw];
end
