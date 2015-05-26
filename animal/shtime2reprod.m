%% shtime2reprod
% Plots reproduction rate as a function of time

%%
function shtime2reprod
  % created 2000/09/05 by Bas Kooijman, modified 2011/02/03
  
  %% Syntax
  % <../shtime2reprod.m *shtime2reprod*>
  
  %% Description
  % Plots the reproduction rate at scaled functional responses f = 1, 0.8, 0.6, .. as functions of the volumetric lengths. 
  % The lowest value of f still has an ultimate length larger than l_p, which depends on other parameter values. 
  % See pages 69 ff of the  <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.

  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values

  %% Example of use 
  % clear all; pars_animal; shtime2reprod

  
  global kap kap_R g kT_J kT_M L_T vT U_Hb U_Hp ep_min L_m
  global l_T v_Hb v_Hp a_m

  hold on;
  
  pars_R = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];
  pars_tp = [g; kT_J/ kT_M; l_T; v_Hb; v_Hp];
  info = 1;
  f = 1;               % -, initiate scaled functional response

  while f > ep_min && info == 1 % f at which maturation ceases at puberty
      
    [t_p t_b l_p l_b info] = get_tp(pars_tp, f); % -, scaled time at puberty
    a_p = t_p/ kT_M;                       % d, age at puberty
    a = linspace(a_p, 3 * a_m, 50)';       % d, ages
    r_B = 1/(3/ kT_M + 3 * f * L_m/ vT);   % 1/d, von Bert growth rate
    L_i = f * L_m - L_T;                   % cm, ultimate length
    L_p = L_m * l_p;                       % cm, length at puberty
    L = L_i - (L_i - L_p) * exp( - r_B * (a - a_p));  % cm, lengths
    R = reprod_rate(L, f, pars_R);         % #/d, reprod rate

    % actual plotting
    if info == 1
      plot(a, R, 'g');
    end
       
    f = f - 0.2;        % -, decrease functional response
  end    
  title ('reproduction rate for f = 1, 0.8, 0.6, ..');
  xlabel('time, d'); ylabel('reproduction rate, #/d');
