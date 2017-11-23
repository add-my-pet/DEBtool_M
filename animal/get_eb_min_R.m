%% get_eb_min_R
% scaled reserve for which maturation ceases at birth

%%
function [eb lb info] = get_eb_min_R (p, lb0)
  % created 2013/08/15 by Bas Kooijman; modified 2017/07/24
  
  %% Syntax
  % [eb lb info] = <../get_eb_min_R.m *get_eb_min_R*> (p, lb0)
  
  %% Description
  % Obtains the scaled reserve at birth for maturation ceasing at birth. 
  % It can be seen as the lower viable scaled reserve density for embryo development. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b see get_lb
  % * lb0: optional scalar with initial estimate for lb
  %  
  % Output
  %
  % * eb: scalar with e_b such that maturation ceases at birth
  % * lb: scalar with l_b such that maturition ceases at birth
  % * info: scalar with 1 for success and 0 otherwise
  
  %% Remarks
  % The theory behind get_eb_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.html the comments for DEB3>.
  % If k < 1, shrinking can occur at birth if maturation just ceases
  % Cf <get_eb_min_G.html *get_eb_min_G*> for e at which growth ceases at birth

  %% Example of use
  % get_eb_min_R([.1 .3 .01])

  % unpack par
  g = p(1); k = p(2); vHb = p(3);

  if exist('lb0', 'var') == 0
    lb0 = .1;
  end 
  
  f = fnget_lb_min_R(lb0, g, k, vHb); % loss function at lb0, which should be set to 0
  dlb = 0.001;    % width of range [lb0 lb1] where lb must be
  lb0_min = 1e-4; % lower boundary for lb0 (too small gives numerical errors)
  if  f < 0 % lb is larger than lb0, find upper boundary
    lb1 = lb0;
    if lb1 >= 1
      info = 0; lb = lb1; lb2 = lb * lb; lb3 = lb2 * lb; eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb); return
    end
    
    while  f < 0 && lb1 < 1
      lb0 = lb1; lb1 = min(1, lb1 + dlb);
      f = fnget_lb_min_R(lb1, g, k, vHb);
    end
    
    if f < 0 && lb1 == 1
      fprintf('Warning from get_eb_min_R: l_b is larger than 1\n')
      info = 0; lb = lb1; lb2 = lb * lb; lb3 = lb2 * lb; eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb); return
    end
  else % lb is smaller than lb0, find lower boundary
    if lb0 <= lb0_min
      info = 0; lb = lb0; lb2 = lb * lb; lb3 = lb2 * lb; eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb); return
    end
    
    while  f > 0 && lb0 > lb0_min
      lb1 = lb0; lb0 = max(lb0_min, lb1 - dlb);
      f = fnget_lb_min_R(lb0, g, k, vHb);
    end
    if f > 0 && lb0 == lb0_min
      fprintf(['Warning from get_eb_min_R: l_b is smaller than ', num2str(lb0_min), '\n'])
      info = 0; lb = lb0; lb2 = lb * lb; lb3 = lb2 * lb; eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb); return
    end
  end
  lb_range = [lb0; lb1];
   
  f = 1; i = 0; i_max = 20; % initiate 
  while abs(f) > 5e-4 && i <= i_max
    lb = sum(lb_range)/2; i = i + 1; info = 1;
    f = fnget_lb_min_R(lb, g, k, vHb);
    if f < 0
      lb_range(1) = lb;
    else
      lb_range(2) = lb;
    end
  end
  if i > i_max
    info = 0;
    fprintf(['Warning from get_eb_min_R: no convergence in ', num2str(i_max), ' steps \n']);
    fprintf(['loss function ', num2str(f), '; l_b ', num2str(lb), '\n']);
  end
  lb2 = lb * lb; lb3 = lb2 * lb;
  eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb);
end

% subfunctions

function fn = fnget_lb_min_R(lb, g, k, vHb)
  lb = max(1e-10, min(1-1e-10, lb));
  lb2 = lb * lb; lb3 = lb2 * lb;
  xb = (lb3 + g * lb2 - k * vHb)/ (lb3 + g * lb2);
  
  [x y] = ode45(@dydx, [1e-10; xb], 0, [], g, k, lb, xb);
  fn = y(end) - g * xb * vHb/ lb3;
end

function dy = dydx(x, y, g, k, lb, xb)
  l = max(1e-8, 1/((xb/ x)^(1/3)/ lb - beta0(x, xb)/ 3/ g/ x^(1/3)));
  dy = min(100, g + l - y * (k - x) * l/ (1 - x)/ g/ x);
end
          