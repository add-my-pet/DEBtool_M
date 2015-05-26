%% get_eb_min
% Gets eb such that growth or maturation  ceases at birth

%%
function [eb lb uE0 info] = get_eb_min(p, option)
  %% created 2009/01/15 by Bas Kooijman; modified 2013/08/15
  
  %% Syntax
  % [eb lb uE0 info] = <../get_eb_min.m *get_eb_min*>(p, option)
  
  %% Description
  % Obtains the scaled reserve at birth for growth or maturation ceases at birth. 
  % It can be seen as the lower viable scaled reserve density for embryo development. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b see get_lb
  % * option: optional scalar with
  %
  %   0: growth ceases at birth
  %   1: maturitation ceases at birth
  %   2: growth, maturity ceases at birth (default)
  %  
  % Output
  %
  % * eb: 1 or 2-vector with e_b such that growth and/or maturation cease at birth
  % * lb: 1 or 2-vector with l_b such that growth and/or maturition cease at birth
  % * uE0: 1 or 2-vector with u_E^0
  % * info: 1 or 2-vector with 1's for success and 0's otherwise
  
  %% Remarks
  % The theory behind get_eb_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.html the comments for DEB3>.
  % Shell around <get_eb_min_G.html *get_eb_min_G*> and <get_eb_min_R.html *get_eb_min_R*>.
  % Cf <get_ep_min.html *get_ep_min*>  for minimum e to reach puberty

  %% Example of use
  % get_eb_min([.1 .3 .01])
      
  if exist('option', 'var') == 0
      option = 2;
  end
  if ~(option == 0 || option == 1 || option == 2)
    fprintf('unknown option value\n');
    info = 0;
    eb = []; lb = []; uE0 = [];
    return
  end
  
  g = p(1); k = p(2); vHb = p(3);
  
  if k == 1;
    lb = vHb^(1/ 3);
    if option == 0 
      uEb = lb^4/ g;
      eb = g * uEb/ lb^3;  
      uE0 = get_ue0(p, eb);
      info = 1;
    elseif option == 1
      uEb = vHb * lb/ (g + lb - vHb/ lb^2);
      eb = g * uEb/ lb^3;        
      uE0 = get_ue0(p, eb);
      info = 1;
    elseif option == 2
      uEb = [lb^4/ g; vHb * lb/ (g + lb - vHb/ lb^2)];        
      eb = g * uEb/ lb^3;        
      lb = lb * [1;1];
      uE0 = [get_ue0(p, eb(1)); get_ue0(p, eb(2))];
      info = [1; 1];
    end
    return
  end
    
  if option == 0 % growth ceases
    [eb lb info] = get_eb_min_G(p);
    [uE0 lb]  = get_ue0(p, eb, lb);

  elseif option == 1 % maturation ceases
    [eb lb info] = get_eb_min_R(p);
    [uE0 lb]  = get_ue0(p, eb, lb);

  else % option == 2 % growth, maturation caeses
    % growth ceases
    [eb_G lb_G info_G] = get_eb_min_G(p);
    [uE0_G lb_G]  = get_ue0(p, eb_G, lb_G);
    [eb_R lb_R info_R] = get_eb_min_R(p, lb_G);
    [uE0_R lb_R]  = get_ue0(p, eb_R, lb_R);
    eb = [eb_G; eb_R]; 
    lb = [eb_G; lb_R];
    uE0 = [uE0_G; uE0_R];
    info = [info_G; info_R];  
  end