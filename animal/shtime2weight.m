%% shtime2weight
% Plots weights as a function of time

%%
function shtime2weight
  % created 2000/09/05 by Bas Kooijman; modified 2009/01/29
  
  %% Syntax
  % <../shtime2weight.m *shtime2weight*>
  
  %% Description
  % Plots the development of body weight at scaled functional responses f = 1, 0.8, 0.6, .. 
  % The lowest value of f still has an ultimate length larger than l_b, which depends on other parameter values. 
  % See pages 51ff of the <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.
  %
  % The development is through embryo (red), juvenile (blue) and adult (green) if food density is large enough. 
  
  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values.
  % See <shtime2eweight.html *shtime2eweight*> for more detail for embryos.


  %% Example of use 
  % clear all; pars_animal; shtime2weight

  global L_m kT_M d_O w_O u_Hb u_Hp kap y_E_V eb_min a_m
  global hT_a s_G v_Hb v_Hp k g l_T  % for get_leh
  
  hold on;
  
  
  pars_leh = [g; k; l_T; v_Hb; v_Hp; hT_a/ kT_M^2; s_G]; % collect parameters  

  f = 1;                % -, initiate scaled functional response
    
  while f > eb_min(2)   % f at which maturation ceases at birth

    t = linspace(0, 3 * a_m * kT_M, 100);
    leh = get_leh(t, pars_leh, f);

    a = t/ kT_M;      % d, convert scaled time to real time
    L = L_m * leh(:,1); % cm, structural length
    m_E = (y_E_V/ kap) * leh(:,2) ./ leh(:,1) .^ 3; % mol/mol, reserve density m_E
    W_V = L .^3 * d_O(2);                    % g, dry weight of structure
    W = W_V .* (1 + m_E * (w_O(3)/ w_O(2))); % g, total dry weight
    
    % actual plotting
    sel_embryo = leh(:,3) < u_Hb;
    sel_juvenile = and(leh(:,3) >= u_Hb, leh(:,3) < u_Hp);
    sel_adult = leh(:,3) >= u_Hp;
    
    % actual plotting
    plot( ...
        a(sel_embryo), W(sel_embryo), 'b', ... % a(sel_embryo), W_V(sel_embryo), '.b', ...
        a(sel_juvenile), W(sel_juvenile),  ... % 'g',a(sel_juvenile), W_V(sel_juvenile), '.g', ...
        a(sel_adult), W(sel_adult), 'r'    ... %, a(sel_adult), W_V(sel_adult), '.r' ...
        );


    f = f - 0.2;        % -, decrease functional response
  end
  
  title ('weight for f = 1, 0.8, 0.6, ..');
  % title ('structural & total weight for f = 1, 0.8, 0.6, ..');
  xlabel('time, d'); ylabel('weight, g');
