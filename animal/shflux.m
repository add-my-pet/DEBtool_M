%% shflux
%

%%
function shflux (j)
  % created 2000/09/07 by Bas Kooijman, modified 2009/09/29

  %% Syntax
  % <../shflux.m *shflux*> (j)
  
  %% Description
  % Routine produces eight plots that show fluxes of compounds as functions of the scaled length, for scaled functional responses f = 1, 0.8, 0.6, ... 
  % The lowest value of f still has an ultimate length larger than l_b, which depends on other parameter values. 
  % The range of the scaled lengths is from 0 to f. See pages 138 ff of the <A HREF="http://www.bio.vu.nl/thb/research/bib/Kooy2010.html">DEB-book</A>.
  %
  % The animal develops through the embryo (red), juvenile (blue) and adult (green) stages. 
  % The combination of the eight fluxes fully specify the interaction of the animal with its environment. 
  % All fluxes are expressed in mol per time. 
  %
  % Input
  % 
  % * optional scalar with figure number
  %
  % Output figures
  %
  % * fig 1 Food; 
  %   negative, because it disappears.
  % * fig 2 Structural mass; 
  %   note that the fluxes are zero when the animal is fully grown; 
  %   this occurs at structural length l = f.
  % * fig 3 Reserve mass; 
  %   the flux is negative during the embryonal stage. 
  %   During the adult state, the flux adds the production of the reserve of the individual, and that of the offspring. 
  %   The first contribution is zero for scaled length l = f, because no new reserves are produced in a fully grown individual (because of weak homeostasis).
  % * fig 4 Faeces; 
  %   proportional to food, but positive, because it appears.
  % * fig 5 Carbon dioxide; 
  %   usually positive, but can become negative, depending on parameter values.
  % * fig 6 Water; 
  %   usually positive.
  % * fig 7 Dioxygen; 
  %   usually negative
  % * fig 8 Nitrogen waste (frequently ammonia for animals that live in water);
  %   usually positive
  
  %% Remarks
  % The discontinuities between the different stages relate to the switches of assimilation and reproduction.
  % See <shflux_struc.html *shflux_struc*> for structure-specific fluxes and <shflux_weight.html *shflux_weight*> for weight-specific fluxes
  
  %% Example of use
  % after editing <../pars_animal.m *pars_animal*>: 
  % clear all; pars_animal; shflux.

  global eta_O n_O n_M eb_min g k l_T v_Hb v_Hp p_ref
  global L_m L_T vT kT_M kT_J kap kap_R U_Hb U_Hp

  f = 1;              % -, scaled functional response
  O2M = (- n_M\n_O)'; % -, matrix that converts organic to mineral fluxes
			          % O2M is prepared for post-multiplication
                            
  pars_lp = [g; k; l_T; v_Hb; v_Hp];
  pars_power = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];
  
  txt =   {'food mol/d'; 'structure mol/d';
	       'reserve mol/d'; 'faeces mol/d'; 
           'carbon dioxyde mol/d';'water mol/d';
	       'dioxygen mol/d';'ammonia mol/d'};

  if exist('j','var') ~= 1
    handle = zeros(8,1);
    for i = 1:8 
        handle(i) = figure(i);
    end
  end
   
  while f > .2 + eb_min(2)  
        
    [l_p l_b] = get_lp(pars_lp, f);
    l = linspace(1e-4, f - l_T, 100)';
        
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
 
    if exist('j','var') == 1 % single-plot mode
      plot(l(sel_embryo), J(sel_embryo,j), 'b', ... 
         l(sel_juvenile), J(sel_juvenile,j), 'g', ... 
         l(sel_adult), J(sel_adult,j), 'r')
      ylabel(txt{j}); xlabel('scaled length');
      title('total flux for f = 1, .8, ..')
      hold on  
    else % multiple plot-mode
      for i = 1:8
        set(0,'CurrentFigure',handle(i))
        plot(l(sel_embryo), J(sel_embryo,i), 'b', ... 
           l(sel_juvenile), J(sel_juvenile,i), 'g', ... 
           l(sel_adult), J(sel_adult,i), 'r')
        ylabel(txt{i}); xlabel('scaled length');
        title('total flux for f = 1, .8, ..')
        hold on
      end 

    end
    f = f - 0.2;               % -, decrease functional response
  end
  