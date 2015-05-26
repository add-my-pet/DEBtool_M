%% shtime2eweight
% Plots embryo weight as a function of time

%%
function shtime2eweight
  % created 2000/09/05 by Bas Kooijman, modified 2009/07/30
  
  %% Syntax
  % <../shtime2eweight.m *shtime2eweight*>
  
  %% Description  
  % Plots the development of embryo's structural weight (green) and total weight (red) at scaled reserve density e<sub>b</sub> = 1, 0.8, 0.6, .... 
  % See pages 64 ff of the <A HREF="http://www.bio.vu.nl/thb/research/bib/Kooy2010.html">DEB-book</A>.
  %
  % The curves correspond with <shtime2weight.html *shtime2weight*>, but the sections that correspond with embryo's are so close to zero, 
  %  that the weights are hardly visible.
  
  %% Example of use 
  % clear all; pars_animal; shtime2eweight

  global L_m kT_M d_O w_O kap y_E_V eb_min
  global hT_a s_G v_Hb v_Hp k g l_T  % for get_leh
  
  hold on;
  
  pars_leh = [g; k; l_T; v_Hb; v_Hp; hT_a/ kT_M^2; s_G]; % collect parameters  
  f = 1;                % -, initiate scaled functional response
    
  while f > eb_min(2)   % f at which maturation ceases at birth

    [t_b l_b] = get_tb([g, k, v_Hb], f);                     % -, scaled age at birth
    t = linspace(0, t_b, 50)';

    leh = get_leh(t, pars_leh, f);

    a = t/ kT_M;      % d, convert scaled time to real time
    L = L_m * leh(:,1); % cm, structural length
    m_E = (y_E_V/ kap) * leh(:,2) ./ leh(:,1) .^ 3; % mol/mol, reserve density m_E
    W_V = L .^3 * d_O(2);                    % g, dry weight of structure
    W = W_V .* (1 + m_E * (w_O(3)/ w_O(2))); % g, total dry weight
    
    %% actual plotting
    plot(a, W, 'r', a, W_V, 'g');

    f = f - 0.2;        % -, decrease functional response
  end
 
  title ('(struct) weight of embryo for f = 1, 0.8, 0.6, ..');
  xlabel('time, d'); ylabel('weight, g');
