%% get_tb1
% Obtains scaled age at birth

%%
function [tb lb uE0 info] = get_tb1(p, eb, lb0)
  %  created at 2011/07/05 by Bas Kooijman, modified 2015/01/18
  
  %% Syntax
  % [tb lb uE0 info] = <../get_tb1.m *get_tb1*> (p, eb, lb0)
  
  %% Description
  % Obtains scaled age at birth, given the scaled reserve density at birth. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
  % Warning: this routine integrates backwards over maturity; the accuracy can be low
  %
  % Input
  %
  % * p: 1 or 3-vector with parameters g, k, v_H^b
  %
  %     Last 2 values are optional in invoke call to get_lb
  %
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
  %  
  % Output
  %
  % * tb: scaled age at birth \tau_b = a_b k_M
  % * lb: scalar with scaled length at birth 
  % * uE0: scalar with scaled reserve at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See also <get_tb.html *get_tb*>
  
  %% Example of use
  % get_tb1([.1;.5;.03])
  
  if ~exist('eb', 'var')
    eb = 1; % maximum value as juvenile
  end
  
  if exist('lb', 'var') == 0
    if length(p) < 3
      fprintf('not enough input parameters, see get_lb \n');
      tb = [];
      return;
    end
    [lb info] = get_lb2(p, eb); lb0 = [];
  else
    lb = lb0; info = 1;
  end
  if isempty(lb)
    [lb info] = get_lb2(p, eb);
  end

  % unpack p
  g = p(1);  k = p(2); vHb = p(3);
  
  options = [];
  %options = odeset('RelTol',1e-10,'AbsTol',[1e-10 1e-10 1e-11],'MaxStep',1e-5);
  [vH aul] = ode45(@dget_aul1, [vHb 0], [0; eb * lb^3/g; lb], options , g, k);
  tb = - aul(end,1); uE0 = aul(end,2); l0 = aul(end,3);
  
  if abs(l0) > 1e-3 % use get_tb and integrate foreward in time to check
    info = 0;
    fprintf(['warning in get_tb1: l(0) = ', num2str(l0), '\n'])
    [tb lb] = get_tb(p,eb,lb0);
    uE0 = get_ue0(p, eb);
    [a hul] = ode45(@dget_hul1, [0 tb], [0; uE0; 1e-8], options , g, k);
    vHb1 = hul(end,1); eb1 = hul(end,2) * g/ lb^3; lb1 = hul(end,3);
    if abs(vHb1 - vHb) < 1e-4 && abs(eb1 - eb) < 1e-4 && abs(lb1 - lb) < 1e-4
      info = 1;
      fprintf('problem solved\n')
    else
      fprintf('recovery failed\n');
      fprintf(['v_Hb = ', num2str(vHb1), '; e_b = ', num2str(eb1), '; l_b = ', num2str(lb1), '\n'])
      fprintf('should have been\n')
      fprintf(['v_Hb = ', num2str(vHb), '; e_b = ', num2str(eb), '; l_b = ', num2str(lb), '\n'])     
    end
  end
end 
  
% subfunction

function daul = dget_aul1(v_H, aul, g, k)

  u_E = aul(2); l = aul(3);
  l2 = l * l; l3 = l2 * l; l4 = l3 * l; ul3 = u_E + l3;

  du_E = - u_E * l2 * (g + l)/ ul3;
  dl = (g * u_E - l4)/ ul3/ 3;
  dv_H = u_E * l2 * (g + l)/ul3 - k * v_H;

  daul = [1; du_E; dl]/ dv_H;
end

function daul = dget_hul1(a, hul, g, k)

  v_H = hul(1); u_E = hul(2); l = hul(3);
  l2 = l * l; l3 = l2 * l; l4 = l3 * l; ul3 = u_E + l3;

  du_E = - u_E * l2 * (g + l)/ ul3;
  dl = (g * u_E - l4)/ ul3/ 3;
  dv_H = u_E * l2 * (g + l)/ul3 - k * v_H;
end
daul = [dv_H; du_E; dl];