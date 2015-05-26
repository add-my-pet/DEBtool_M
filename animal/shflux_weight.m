%% shflux_weight
% Plots mass-specific fluxes as function of scaled length

%%
function shflux_weight (j)
  % created 2000/09/07 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % <../shflux_weight.m *shflux_weight*> (j)
  
  %% Description
  % See <shflux.html *shflux*>, but the units of the dependent variables is mol/g.d.

  global eta_O n_O n_M eb_min g k l_T v_Hb v_Hp p_ref d_O w_O m_Em
  global L_m L_T vT kT_M kT_J kap kap_R U_Hb U_Hp

  f = 1;              % -, scaled functional response
  O2M = (- n_M\n_O)'; % -, matrix that converts organic to mineral fluxes
			               	% O2M is prepared for post-multiplication
  pars_lp = [g; k; l_T; v_Hb; v_Hp];
  pars_power = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];
  
  txt =   {'food mol/d.g'; 'structure mol/d.g';
	       'reserve mol/d.g'; 'faeces mol/d.g'; 
           'carbon dioxyde mol/d.g';'water mol/d.g';
	       'dioxygen mol/d.g';'ammonia mol/d.g'};

  if exist('j','var') ~= 1
    handle = zeros(8,1);
    for i = 1:8 
        handle(i) = figure(i);
    end
  end
  
  while f > .2 + eb_min(2)  
        
    [l_p l_b] = get_lp(pars_lp, f);
    l = linspace(1e-3, f - l_T, 100)';
        
    % actual plotting
    sel_embryo = l < l_b;
    sel_juvenile = and(l >= l_b, l < l_p);
    sel_adult = l >= l_p;
    % scaled lengths for embryo, juvenile and adult
    
    pACSJGRD = p_ref * scaled_power(l * L_m, f, pars_power, l_b, l_p);
    pADG = pACSJGRD(:, [1 7 5]);
    
    JO = pADG * eta_O';        % organic fluxes
    JM = JO * O2M;             % mineral fluxes
    J = [JO, JM];
    W = (L_m * l) .^ 3 * d_O(2)* (1 + f * m_Em * w_O(3)/ w_O(2));
    J = J ./ [W, W, W, W, W, W, W, W];
 
    if exist('j','var') == 1 % single-plot mode
      plot(l(sel_embryo), J(sel_embryo,j), 'b', ... 
         l(sel_juvenile), J(sel_juvenile,j), 'g', ... 
         l(sel_adult), J(sel_adult,j), 'r')
      ylabel(txt{j}); xlabel('scaled length');
      title('total spec flux for f = 1, .8, ..')
      hold on  
    else % multiple plot-mode
      for i = 1:8
        set(0,'CurrentFigure',handle(i))
        plot(l(sel_embryo), J(sel_embryo,i), 'b', ... 
           l(sel_juvenile), J(sel_juvenile,i), 'g', ... 
           l(sel_adult), J(sel_adult,i), 'r')
        ylabel(txt{i}); xlabel('scaled length');
        title('total spec flux for f = 1, .8, ..')
        hold on
      end 

    end
    f = f - 0.2;               % -, decrease functional response

  end
