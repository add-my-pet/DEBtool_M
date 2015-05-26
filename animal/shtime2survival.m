%% shtime2survival
% Plots survival as a function of time for various f's

%%
function shtime2survival
  % created 2000/09/05 by Bas Kooijman, modified 2011/02/03
  
  %% Syntax
  % <../shtime2survival.m *shtime2survival*>
  
  %% Description
  % Plots the survival probability with respect to aging at scaled functional responses f = 1, 0.8, 0.6, .. 
  % The lowest value of f still has an ultimate length larger than l_b, which depends on other parameter values. 
  % See page 214 of the <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.
  %
  % The development is through embryo (red), juvenile (blue) and adult (green) if food density is large enough.

  %% Remarks
  % The script <..pars_animal.m *pars_animal*> might be edited to see effects of parameter values.

  %% Example of use 
  % clear all; pars_animal; shtime2survival

  
  global hT_a s_G vHb vHp k g l_T f        % to dget_tm
  global eb_min a_m vT kT_M kT_J v_Hb v_Hp % from pars_animal
  
  hold on;
  
  vHb = v_Hb; vHp = v_Hp;
  L_m = vT/ g/ kT_M; k = kT_J/ kT_M;
  Lv = vT/ kT_M; ht = hT_a/ kT_M^2; % for export to fnlifespan
 
  f = 1;                            % -, scaled functional response
  
  while f > eb_min(2) % f large than ceasing growth at birth
    [uE0 lb info] = get_ue0([g, kT_J/ kT_M, v_Hb], f); % scaled intial reserve
    if info ~= 1
      fprintf('warning: no convergence for uE0 \n');
    end
  
    x0 = [lb/1000; uE0; 1e-12; 0; 0; 1; 0];
    [t x]= ode23('dget_tm', [0; 3 * a_m * kT_M], x0);           
    t = t/ kT_M;  % convert mean to real time
  
    sel_embryo = (x(:,3) < v_Hb);
    sel_juvenile = and((x(:,3) > v_Hb),(x(:,3) < v_Hp));
    sel_adult = (x(:,3) > v_Hp);

    plot( ...
        t(sel_embryo), x(sel_embryo, 6), 'b', ...
        t(sel_juvenile), x(sel_juvenile, 6), 'g', ...	
        t(sel_adult), x(sel_adult, 6), 'r')
    
    f = f - 0.2;        % -, decrease functional response
  end    
  title ('survival probability for f = 1, 0.8, 0.6, ..');
  xlabel('time, d'); ylabel('survival probability');
  
  