%% shratio
% Plots of ratio's of mineral fluxes for 'animal'

%%
function shratio (j)
  % created 2000/10/20 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax 
  % <../shratio.m *shratio*> (j)
  
  %% Description
  % Produces three plots that show ratio of mineral fluxes as functions of the scaled length, for scaled functional responses f = 1, 0.8, 0.6, ... 
  % respiration, urination and watering quotients,
  % excluding contributions from assimilation
  %
  % Input
  %
  % * optional scalar with figure number
  %
  % Output figures
  %
  % * fig 1 Respiration Quotient: 
  %   ratio of carbon dioxide and (negative) dioxygen fluxes
  % * fig 2 Watering Quotient: 
  %   ratio of water and (negative) dioxygen fluxes
  % *fig 3 Urination Quotient: 
  %   ratio of nitrogen waste and (negative) dioxygen fluxes

  %% Remarks
  % The lowest value of f still has an ultimate length larger than l_b, which depends on other parameter values. 
  % The range of the scaled lengths is from 0.8*l_b to f. 
  % The fluxes exclude contributions from assimilation; so only contributions from dissipation and growth are included. 
  % All fluxes are in terms of mol per time; the ratio's are dimensionless. 
  % See pages 138 ff of the <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.
  
  %% Example of use
  % after editing <../pars_animal.m *pars_animal*>: 
  % clear all; pars_animal; shratio.
  
  global eta_O n_O n_M eb_min g k l_T v_Hb v_Hp p_ref
  global L_m L_T vT kT_M kT_J kap kap_R U_Hb U_Hp

  f = 1;              % -, scaled functional response
  O2M = (- n_M\n_O)'; % -, matrix that converts organic to mineral fluxes
			               	% O2M is prepared for post-multiplication
  pars_lp = [g; k; l_T; v_Hb; v_Hp];
  pars_power = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];
  
  txt =   {'respiration quotient, mol CO_2/mol O_2';
	       'urination  quotient mol NH_3/mol O_2';
           'watering quotient mol H_2O/mol O_2'};

  if exist('j','var') ~= 1
    handle = zeros(3,1);
    for i = 1:8 
        handle(i) = figure(i);
    end
  end
  
  while f > .2 + eb_min(2)  
        
    [l_p l_b] = get_lp(pars_lp, f);
    l = linspace(1e-4, f, 100)';
        
    % actual plotting
    sel_embryo = l < l_b;
    sel_juvenile = and(l >= l_b, l < l_p);
    sel_adult = l >= l_p;
    
    % scaled lengths for embryo, juvenile and adult
    
    pACSJGRD = p_ref * scaled_power(l * L_m, f, pars_power, l_b, l_p);
    pADG = pACSJGRD(:, [1 7 5]);
    
    pADG(:,1) = 0; % exclude contributions from assimilation
    JO = pADG * eta_O';        % organic fluxes
    JM = JO * O2M;             % mineral fluxes
    % respiration, urination, watering quotient
    RUW = -JM(:,[1 4 2]) ./ JM(:,[3 3 3]);   

 
    if exist('j','var') == 1 % single-plot mode
      plot(l(sel_embryo), RUW(sel_embryo,j), 'b', ... 
         l(sel_juvenile), RUW(sel_juvenile,j), 'g', ... 
         l(sel_adult), RUW(sel_adult,j), 'r')
      ylabel(txt{j}); xlabel('scaled length');
      title('total flux for f = 1, .8, ..')
      hold on  
    else % multiple plot-mode
      for i = 1:3
        set(0,'CurrentFigure',handle(i))
        plot(l(sel_embryo), RUW(sel_embryo,i), 'b', ... 
           l(sel_juvenile), RUW(sel_juvenile,i), 'g', ... 
           l(sel_adult), RUW(sel_adult,i), 'r')
        ylabel(txt{i}); xlabel('scaled length');
        title('quotient for f = 1, .8, .., excl assim')
        hold on
      end 

    end
    f = f - 0.2;               % -, decrease functional response
  end
  