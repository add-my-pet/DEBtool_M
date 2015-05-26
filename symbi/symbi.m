%% Copyright (C) 2000 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 2000/10/18
%% Keywords: Herbivory -> symbiosis
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%
%% This script has been coded and tested in Matlab version 5.3
%% This script can be obtained from http://www.bio.vu.nl/thb/deb/deblab/
%%   new versions are indicated by the date of creation
%%
%% Usage: symbi
%%   Produces plots of state variables as functions of time and their
%%   equilibrium values as functions of parameters.
%%   The parameters in the routine pars can be modified.
 
%% The theory for the model can be found in:
%%   Kooijman, S. A. L. M. 2000 Van herbivorie, via symbiose naar mixotrofie.
%% In: Heesterbeek, H., Diekmann, O. en Metz, J. A. J. Theoretische Biologie. 
%%   Epsilon-uitgevers, Utrecht.
%% You can download the paper from  http://www.bio.vu.nl/thb/deb/
%% This paper is based on the DEB theory, described in
%%   Kooijman, S. A. L. M. 2000 Dynamic Energy and Mass Budgets in
%%   Biological Systems. Cambridge University Press.
%% You can download a concepts-paper from http://www.bio.vu.nl/thb/deb/
%%
%% The paper describes the trophic relationships between autothrophs and
%% herbivores, and how herbivory can make a smooth transition to
%% symbiosis. The basis is that herbivores consume the structure and,
%% more important, the reserves of the autotrophs. Autotrophs also have
%% to excrete some reserves in the environment, which can be taken up by
%% the herbivores as well. Stoichiometric constraints and conversion
%% efficiencies dominate the relationships between the partners.

%% Autotroph and heterotroph in a chemostat
%%
%% Inorganic carbon and light are not limiting.
%% The inflowing medium has organic substrate (X) and/or nitrogen (N, ammonia);
%%   the specific throughput rate of the chemostat is called h
%% Initially hardly any autotrophs (VA), heterotrophs (VH) or hydrocarbon (CH)
%%   are present in the chemostat, and the concentrations
%%   nitrogen and substrate equal that in the feed;
%% Substrate contains nitrogen, but this is not available for the autotroph
%% The autotroph (VA) excretes nitrogen (N) and carbohydrate (CH), and
%%   consumes nitrogen (N)
%% The heterotroph (VH) excretes nitrogen (N), and consumes, apart from the
%%   autotroph (VA), nitrogen (N), carbohydrate (CH) and substrate (X);
%% no faeces is produced, so all wastes are mineralized instantaneously
%% The autotroph has structure (VA), nitrogen-reserves (EN),
%%   and carbohydrate-reserves (EC);
%%   reserve-densities: mEN = mass EN/ mass VA; mEC = mass EC/ mass VA
%% The heterotroph has structure (VH), and reserves (E);
%%   reserve density: mE = mass E/ mass VH
%% Both auto- and heterotrophs are taken to be V1-morphs,
%%   with negigible aging
%%

%%  pipe_gnuplot
  
  pars_symbi;

  shtime_symbi;
  fprintf('hit a key to proceed \n');
  pause
    
  shsubstr2graz;
  fprintf('hit a key to proceed \n');
  pause

  shsubstr2nitro;
  fprintf('hit a key to proceed \n');
  pause

  shsubstr2throu;
  fprintf('hit a key to proceed \n');
  pause

  shthrou2graz;
