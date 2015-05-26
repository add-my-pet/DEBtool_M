%% get_lb2
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function [lb info] = get_lb2(p, eb, lb0)
  % created 2007/07/26 by Bas Kooijman; modified 2013/08/19, 2015/01/18
  
  %% Syntax
  % [lb info] = <../get_lb2.m *get_lb2*> (p, eb, lb0)
  
  %% Description
  % Obtains scaled length at birth, given the scaled reserve density at birth. 
  % Like get_lb, but using the shooting method, rather than Newton Raphson
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
  % Like <get_lb.html *get_lb*>, but uses a shooting method in 1 variable

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

  xb = g/ (eb + g); 
  xb3 = xb^(1/3); 
    
  [lb, flag, info] = fzero(@fnget_lb2, lb, [], xb, xb3, g, vHb, k);
  if lb < 0 || lb > 1
      info = 0;
  end
  
end

% subfunctions

function f = fnget_lb2(lb, xb, xb3, g, vHb, k)
  % f = y(x_b) - y_b = 0; x = g/ (e + g); x_b = g/ (e_b + g)
  % y(x) = x e_H = x g u_H/ l^3 and y_b = x_b g u_H^b/ l_b^3

  [x, y] = ode23s(@dget_lb2, [1e-10, xb], 0, [], lb, xb, xb3, g, k);
  f = y(end) - xb * g * vHb/ lb^3;
end

function dy = dget_lb2(x, y, lb, xb, xb3, g, k)
  % y = x e_H; x = g/(g + e)
  % (x,y): (0,0) -> (xb, xb eHb) 

  x3 = x^(1/ 3);
  l = x3/ (xb3/ lb - beta0(x, xb)/ 3/ g);
  dy = l + g - y * (k - x)/ (1 - x) * l/ g/ x;
end
