%% shscale
% Plots quantities as function of max body weight

%%
function shscale (j)
  % created 2000/11/02 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % <../shscale.m *shscale*> (j)
  
  %% Description
  % Plots variables against the maximum body weight of a species in a double logarithmic way. 
  % Extensive primary parameter values covary among species, such that ratios of extensive primary parameters are intensive, and do not covary among species. (They do scatter though, so they vary, but not covary.) 
  % Variables that can be expressed as functions of primary parameters depend on one particular function of primary parameters, namely maximum body weight, in a predictable way, which this routine illustrates for some examples. 
  % See page 209 ff of the <http://www.bio.vu.nl/thb/research/bib/Kooy2010.html *DEB-book*>.
  % To facilitate the judgement of the morphology of the curves, allometric functions with slopes equal to multiples of 1/3 have also been plotted in red. 
  % Note that the result can look weird because the absolute size of the x and y units on the axes depends on the size of the plot window, which is controlled by the user, while they should be equal. 
  % A blue line indicates the maximum body weight as specified by the parameters.
  %
  % Input
  %
  % * j: optional scalar with plot number (default: all)
  %
  % Output figures with
  %
  % * structural volume against max body weight
  % * egg weight against max body weight                
  % * dioxygen flux against max body weight
  % * N-waste flux against max body weight
  % * min food density against max body weight
  % * max ingestion rate against max body weight
  % * max growth rate against max body weight
  % * von Bert growth rate against max body weight
  % * min incubation period against max body weight
  % * min juv period against max body weight
  % * max starvation time against max body weight
  % * max reproduction rate against max body weight
  
  %% Remark
  % Macro around <scale.html *scale*>
  % Run pars_animal to fill globals, but
  % make sure that report_animal in pars_animal is outcommented

  %% Example of use
  % clear all; close all; pars_animal; shscale

  clf;

  % set structural length range from 0.1 till 150 cm:
  z = 10.^linspace(log10(.1), log10(150), 50)'; % zoom factors

  % replace S1 by S in call for 'shloglogstar'
  %   to place star-center at first data-point
  
  if exist('j','var')              % single-plot mode
    
    S1 = scale (1,j);              % get variables for zoom factor 1
    S =  scale (z,j);              % get variables for all zoom factors
    RS = [min(S); max(S)];         % range of variables
    switch j
	
    case 1
	 shloglogstar (S1(1, [1 2]), RS(:, [1 2]), 'r');
	 plot(log10(S(:,1)), log10(S(:,2)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log structure, cm^3');

    case 2
	 shloglogstar (S1(1, [1 3]), RS(:, [1 3]), 'r');
	 plot(log10(S(:,1)), log10(S(:,3)), 'g');
     xlabel('log max weight, g');
	 ylabel('log egg weight, g');

    case 3
	 shloglogstar (S1(1, [1 4]), RS(:, [1 4]), 'r');
	 plot(log10(S(:,1)), log10(S(:,4)), 'g');
 	 xlabel('log max weight, g');
	 ylabel('log dioxygen consumption, mol/d');

    case 4
	 shloglogstar (S1(1, [1 5]), RS(:, [1 5]), 'r');
	 plot(log10(S(:,1)), log10(S(:,5)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log N-waste production, mol/d');

    case 5
	 shloglogstar (S1(1, [1 6]), RS(:, [1 6]), 'r');
	 plot(log10(S(:,1)), log10(S(:,6)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log min food density, mM');

    case 6
	 shloglogstar (S1(1, [1 7]), RS(:, [1 7]), 'r');
	 plot(log10(S(:,1)), log10(S(:,7)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log max ingestion rate, mol/d');

    case 7
	 shloglogstar (S1(1, [1 8]), RS(:, [1 8]), 'r');
	 plot(log10(S(:,1)), log10(S(:,8)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log max growth rate, cm^3/d');

    case 8
	 shloglogstar (S1(1, [1 9]), RS(:, [1 9]), 'r');
	 plot(log10(S(:,1)), log10(S(:,9)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log von Bertalanffy growth rate, 1/d');

    case 9
	 shloglogstar (S1(1, [1 10]), RS(:, [1 10]), 'r');
	 plot(log10(S(:,1)), log10(S(:,10)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log min incubation period, d');

    case 10
	 shloglogstar (S1(1, [1 11]), RS(:, [1 11]), 'r');
	 plot(log10(S(:,1)), log10(S(:,11)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log min juvenile period, d');

    case 11
	 shloglogstar (S1(1, [1 12]), RS(:, [1 12]), 'r');
	 plot(log10(S(:,1)), log10(S(:,12)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log max starvation time, d');

    case 12
	 shloglogstar (S1(1, [1 13]), RS(:, [1 13]), 'r');
	 plot(log10(S(:,1)), log10(S(:,13)), 'g');
	 xlabel('log max weight, g');
	 ylabel('log max reproduction rate, 1/d');
	
    otherwise
	 return
    end
    
  else % multiplot mode
    S1 = scale (1);              % get variables for zoom factor 1
    S = scale (z);               % get variables for all zoom factors
    RS = [min(S); max(S)];       % range of variables
	
   subplot(3,4,1); 
	shloglogstar (S1(1, [1 2]), RS(:, [1 2]), 'r');
	plot(log10(S(:,1)), log10(S(:,2)), 'g');
	xlabel('log max weight, g');
	ylabel('log structure, cm^3');

   subplot(3,4,2); 
	shloglogstar (S1(1, [1 3]), RS(:, [1 3]), 'r');
	plot(log10(S(:,1)), log10(S(:,3)), 'g');
	xlabel('log max weight, g');
	ylabel('log egg weight, g');

   subplot(3,4,3); 
	shloglogstar (S1(1, [1 4]), RS(:, [1 4]), 'r');
	plot(log10(S(:,1)), log10(S(:,4)), 'g');
	xlabel('log max weight, g');
	ylabel('log dioxygen consumption, mol/d');

   subplot(3,4,4); 
	shloglogstar (S1(1, [1 5]), RS(:, [1 5]), 'r');
	plot(log10(S(:,1)), log10(S(:,5)), 'g');
	xlabel('log max weight, g');
	ylabel('log N-waste production, mol/d');

   subplot(3,4,5); 
	shloglogstar (S1(1, [1 6]), RS(:, [1 6]), 'r');
	plot(log10(S(:,1)), log10(S(:,6)), 'g');
	xlabel('log max weight, g');
	ylabel('log min food density, mM');

   subplot(3,4,6); 
	shloglogstar (S1(1, [1 7]), RS(:, [1 7]), 'r');
	plot(log10(S(:,1)), log10(S(:,7)), 'g');
	xlabel('log max weight, g');
	ylabel('log max ingestion rate, mol/d');

   subplot(3,4,7); 
	shloglogstar (S1(1, [1 8]), RS(:, [1 8]), 'r');
	plot(log10(S(:,1)), log10(S(:,8)), 'g');
	xlabel('log max weight, g');
	ylabel('log max growth rate, cm^3/d');

   subplot(3,4,8); 
	shloglogstar (S1(1, [1 9]), RS(:, [1 9]), 'r');
	plot(log10(S(:,1)), log10(S(:,9)), 'g');
	xlabel('log max weight, g');
	ylabel('log von Bertalanffy growth rate, 1/d');

   subplot(3,4,9); 
	shloglogstar (S1(1, [1 10]), RS(:, [1 10]), 'r');
	plot(log10(S(:,1)), log10(S(:,10)), 'g');
	xlabel('log max weight, g');
	ylabel('log min incubation period, d');

   subplot(3,4,10);
	shloglogstar (S1(1, [1 11]), RS(:, [1 11]), 'r');
	plot(log10(S(:,1)), log10(S(:,11)), 'g');
	xlabel('log max weight, g');
	ylabel('log min juvenile period, d');

   subplot(3,4,11); 
	shloglogstar (S1(1, [1 12]), RS(:, [1 12]), 'r');
	plot(log10(S(:,1)), log10(S(:,12)), 'g');
	xlabel('log max weight, g');
	ylabel('log max starvation time, d');

   subplot(3,4,12); 
	shloglogstar (S1(1, [1 13]), RS(:, [1 13]), 'r');
	plot(log10(S(:,1)), log10(S(:,13)), 'g');
	xlabel('log max weight, g');
	ylabel('log max reproduction rate, 1/d');
	    
  end
 