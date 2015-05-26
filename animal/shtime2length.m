%% shtime2length
% Plots lengths as a function of time

%%
function shtime2length
  % created 2000/09/05 by Bas Kooijman
  
  %% Syntax
  % <../shtime2length.m *shtime2length*>
  
  %% Description
  % Plots the development of structural volumetric length at scaled functional responses f = 1, 0.8, 0.6, .. 
  % The lowest value of f still has an ultimate length larger than l_b, which depends on other parameter values. 
  % Structural volumetric length is not identical to physical volumetric length, because of the contribution of reserves in the latter; 
  % in many cases, it will be close, however. 
  % See page 51 of the <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.
  %
  % The development is through embryo (red), juvenile (blue) and adult (green) if food density is large enough.

  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values

  %% Example of use
  % clear all;pars_animal; shtime2length
  
  global L_m kT_M eb_min a_m u_Hp u_Hb
  global hT_a s_G v_Hb v_Hp k g l_T  % for get_leh
  

  hold on;
  
  pars_leh = [g; k; l_T; v_Hb; v_Hp; hT_a/ kT_M^2; s_G]; % collect parameters  
  f = 1;                % -, initiate scaled functional response
    
  while f > eb_min(2)   % f at which maturation ceases at birth
    
    t = linspace(0, 3 * a_m * kT_M, 100)';
    leh = get_leh(t, pars_leh, f); % scaled length l, reserve u_E, maturity u_H 

    a = t/ kT_M;      % d, convert scaled time to real time
    L = L_m * leh(:,1); % cm, structural length
    
    sel_embryo = leh(:,3) < u_Hb;
    sel_juvenile = and(leh(:,3) >= u_Hb, leh(:,3) < u_Hp);
    sel_adult = leh(:,3) >= u_Hp;
    
    % actual plotting
    plot( ...
        a(sel_embryo), L(sel_embryo), 'b', ...
        a(sel_juvenile), L(sel_juvenile), 'g', ...
        a(sel_adult), L(sel_adult), 'r' ...
        );

    f = f - 0.2;        % -, decrease functional response
  end

  title ('structural lengths for f = 1, 0.8, 0.6, ..');
  xlabel('time, d'); ylabel('length, mm');

