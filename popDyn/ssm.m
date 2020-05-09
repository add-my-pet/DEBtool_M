%% ssm
% Semi Structured Model: runs a semi stage-structured model using a generalized reactor

%%
function txNL23W = ssm(species, tT, tJX, x_0, V_X, h, t_max)
% created 2020/05/08 by Bas Kooijman

%% Syntax
% txNL23W = <../ssm.m *ssm*> (species, tT, tJX, x_0, V_X, h, t_max) 

%% Description
% Semi Structured Model: Plots population trajectories in a generalised reactor for a selected species that reproduce as a continuous flux. 
% Opens 2 html-pages in system browser to report species traits and ebt parameter settings, and plots 4 figures.
% The parameters of species are obtained either from allStat.mat, or from a cell-string {par, metaPar, metaData}.
% The 3 cells are obtained by loading a copy of <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries *results_my_pet.mat*>.
% Structure metadata is required to get species-name, T_typical and ecoCode, metaPar to get model.
% If dioecy applies, the sex-ratio is assumed to be 1:1 and fertilisation is assumed to be sure.
% The energy cost for male-production is taken into account by halving kap_R, but male parameters are assumed to be the same as female parameters. 
% The initial population is a single fertilized (female) egg. 
% Like all parameters, default settings can be changed by changing structure par in cell-string input.
% If specified background hazards in 6th input are too high, the population goes extinct.
%
% Input:
%
% * species: character-string with name of entry or cell-string with structures: {metaData, metaPar, par}
% * tT: optional (nT,2)-array with time and temperature in Kelvin (default: T_typical); time scaled between 0 (= start) and 1 (= end of cycle)
%     If scalar, the temperature is assumed to be constant
% * tJX: optional (nX,2)-array with time and food supply; time scaled between 0 (= start) and 1 (= end of cycle)
%     If scalar, the food supply is assumed to be constant (default 100 times max ingestion rate) 
% * h: optional vector with dilution and background hazards for each stage (depending on the model) and boolean for thinning
%     Default value for the std model: [h_D, h_B0b, h_Bbp, h_Bpi, thin] = [0 0 0 0 0]
% * V_X: optional scalar with reactor volume (default 1000*V_m, where V_m is max struct volume)
% * x_0: optional scalar with initial scaled food density as fraction of half saturation constant (default: 0)
% * t_max: optional scalar with simulation time (d, default 250*365).
%
% Output:
%
% * txNL23W: (n,7)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight
%
%% Remarks
% If species is specified by string (rather than by data), its parameters are obtained from allStat.mat.
% The starvation parameters can only be set different from the default values by first input in the form of data and adding them to the par-structure.
% Empty inputs are allowed, default values are then used.
% The (first) html-page has traits at individual level using the possibly modified parameter values. 
% Temperature changes during embryo-period are ignored; age at birth uses T(0); All embryo's start with f=1.
% Background hazards do not depend on temperature, ageing hazards do.

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_my_pet_pop({metaData, metaPar, par}, [], T, f, destinationFolder)
% * ssm('Torpedo_marmorata');
% * ssm('Torpedo_marmorata', C2K(18));

% get core parameters (2 possible routes for getting pars), species and model
if iscell(species) 
  metaData = species{1}; metaPar = species{2}; par = species{3};  
  species = metaData.species;
  par.reprodCode = metaData.ecoCode.reprod{1};
  par.genderCode = metaData.ecoCode.gender{1};
  datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
else  % use allStat.mat as parameter source 
  [par, metaPar, txtPar, metaData, info] = allStat2par(species); 
  if info == 0
    txNL23W=[];  return
  end
  reprodCode = read_eco({species}, 'reprod'); par.reprodCode = reprodCode{1};
  genderCode = read_eco({species}, 'gender'); par.genderCode = genderCode{1};
  datePrintNm = ['allStat version: ', datestr(date_allStat, 'yyyy/mm/dd')];
end
model = metaPar.model;

% unpack par and compute compound pars
vars_pull(par); vars_pull(parscomp_st(par)); 

% number of reproduction events to be simulated
if ~exist('t_max','var') || isempty(n_R)
  t_max = 150 * 365; % -, total simulation time
end

% temperature
if ~exist('tT','var') || isempty(tT)
  tT = metaData.T_typical;
elseif length(tT) > 1 && sum(tT(:,1) > 1) > 0
  fprintf('abcissa of temp knots must be between 0 and 1\n');
  txNL23W=[]; return
elseif tT(1,1) == 0 && ~(tT(end,1) == 1)
  tT = [tT; 1 tT(1,2)];    
end

% volume of reactor
if ~exist('V_X','var') || isempty(V_X)
  V_X = 1e3 * L_m^3; % cm^3, volume of reactor
end

% supply food 
if ~exist('tJX','var') || isempty(tJX)
  tJX = 10*144.5*V_X/mu_X; % 500 * J_X_Am * L_m^2 ;
elseif length(tJX) > 1 && sum(tJX(:,1) > 1) > 0
  fprintf('abcissa of food supply knots must be between 0 and 1\n');
  txNL23W=[]; return
elseif tJX(1,1) == 0 && ~(tJX(end,1) == 1)
  tJX = [tJX; 1 tJX(1,2)];    
end

% initial scaled food density
if ~exist('x_0','var') || isempty(x_0)
  x_0 = 0.2793; % -, X/K at t=0
end

% account for cost of male production
if strcmp(reprodCode{1}, 'O') && strcmp(genderCode{1}, 'D')
  kap_R = kap_R/2; par.kap_R = kap_R; % reprod efficiency is halved, assuming sex ratio 1:1
end

% rejuvenation parameters
if ~isfield('par', 'k_JX')
  k_JX = k_J/ 100; par.k_JX = k_JX;
end
if ~isfield('par', 'h_J')
  h_J = 1e-4; par.h_J = h_J;
end

% hazard rates
if ~exist('h','var') || isempty(h)
  h_D = 0.1; 
else
  h_D = h(1); 
end
par.h_D = h_D; 
%
if ~exist('h','var') || isempty(h)
  h_B = 0; 
else
  h_B = h(2); 
end
par.h_B = h_B; 

% get trajectories
txNL23W = get_ssm(model, par, tT, tJX, x_0, V_X, t_max);
t = txNL23W(:,1); x = txNL23W(:,2); N = txNL23W(:,3); L = txNL23W(:,4); L2 = txNL23W(:,5); L3 = txNL23W(:,6); W = txNL23W(:,7); 

%% plotting
close all
title_txt = [strrep(species, '_', ' '), ' ', datePrintNm];
%
figure(1) % t-x
plot(t, x, 'k', 'Linewidth', 2)
title(title_txt);
xlabel('time in reprod event periods');
ylabel('scaled food density, X/K');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(2) % t-N_tot
hold on
plot(t, N, 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('# of individuals, #/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(3) % t-L_tot
plot(t, L, 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural length, cm/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(4) % t-L^2_tot
plot(t, L2, 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural surface area, cm^2/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(5) % t-L^3_tot
plot(t, L3, 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural volume, cm^3/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(6) % t-Ww_tot
plot(t, W, 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total wet weight, g/L');
set(gca, 'FontSize', 15, 'Box', 'on')

%% report_my_pet

fileName = ['report_', species, '.html'];
prt_report_my_pet({par, metaPar, txtPar, metaData}, [], [], [], [], fileName);
web(fileName,'-browser') % open html in systems browser

%%  cpm_my_pet

fileName = ['cpm_', species, '.html'];
oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

fprintf(oid, '<!DOCTYPE html>\n');
fprintf(oid, '<HTML>\n');
fprintf(oid, '<HEAD>\n');
fprintf(oid, '  <TITLE>CPM %s</TITLE>\n', strrep(species, '_', ' '));
fprintf(oid, '  <style>\n');
fprintf(oid, '    .newspaper {\n');
fprintf(oid, '      column-count: 3;\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    div.par {\n');
fprintf(oid, '      width: 100%%;\n');
fprintf(oid, '      padding-bottom: 100px;\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    .head {\n');
fprintf(oid, '      background-color: #FFE7C6\n');                  % pink header background
fprintf(oid, '    }\n\n');

fprintf(oid, '    #par {\n');
fprintf(oid, '      border-style: solid hidden solid hidden;\n');   % border top & bottom only
fprintf(oid, '    }\n\n');

fprintf(oid, '    tr:nth-child(even){background-color: #f2f2f2}\n');% grey on even rows
fprintf(oid, '  </style>\n');
fprintf(oid, '</HEAD>\n\n');
fprintf(oid, '<BODY>\n\n');

fprintf(oid, '  <div>\n');
fprintf(oid, '  <h1>%s</h1>\n', strrep(species, '_', ' '));
fprintf(oid, '  </div>\n\n');

fprintf(oid, '  <div class="newspaper">\n');
fprintf(oid, '  <div class="par">\n');

% Table with DEB parameters

fprintf(oid, '  <TABLE id="par">\n');
fprintf(oid, '    <TR  class="head"><TH>symbol</TH> <TH>units</TH> <TH>value</TH>  <TH>description</TH> </TR>\n');
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n', 'model', '-', model, 'model type');
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n', 'reprodCode', '-', reprodCode{1}, 'ecoCode reprod');
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n\n', 'genderCode', '-', genderCode{1}, 'ecoCode gender');

       str = '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%3.4g</TD> <TD>%s</TD></TR>\n';
fprintf(oid, str, 'k_JX', '1/d', k_JX, 'rejuvenation rate');
fprintf(oid, str, 'h_J', '1/d', h_J, 'hazard rate for rejuvenation');
fprintf(oid, str, 'h_D', '1/d', h_D, 'hazard rate for food from reactor');
fprintf(oid, str, 'h_B', '1/d', h_B0b, 'background hazard rate from');
fprintf(oid, str, 'x_0', '-', x_0, 'initial scaled food density');
fprintf(oid, str, 'V_X', 'L', V_X, 'volume of reactor');
fprintf(oid, str, 't_max', 'd', t_max, 'simulation time');

fprintf(oid, '  </TABLE>\n'); % close prdData table
fprintf(oid, '  </div>\n\n');

fprintf(oid, '  <div class="par">\n');

% Table with knots for temperature

fprintf(oid, '  <TABLE id="par">\n');
fprintf(oid, '    <TR  class="head"> <TH>Knots for<br>temperature</TH> <TH>units<br>&deg;C</TH> </TR>\n');
n_T = size(tT,1);
if n_T == 1
    tT = [0 tT; 1 tT]; n_T = 2;
end
for i=1:n_T
  fprintf(oid, '    <TR><TD>%3.4g</TD> <TD>%3.4g</TD></TR>\n', tT(i,1), K2C(tT(i,2)));
end
fprintf(oid, '  </TABLE>\n');
fprintf(oid, '  </div>\n\n');

fprintf(oid, '  <div class="par">\n');

% Table with knots for food input

fprintf(oid, '  <TABLE id="par">\n');
fprintf(oid, '    <TR  class="head"> <TH>Knots for<br>food supply</TH> <TH>units<br>mol/d</TH> </TR>\n');
n_JX = size(tJX,1);
if n_JX == 1
  tJX = [0 tJX; 1 tJX]; n_JX = 2;
end
for i=1:n_JX
  fprintf(oid, '    <TR><TD>%3.4g</TD> <TD>%3.4g</TD></TR>\n', tJX(i,1), tJX(i,2));
end
fprintf(oid, '  </TABLE>\n');
fprintf(oid, '  </div>\n\n');
fprintf(oid, '  </div>\n\n'); % end div newspaper

fprintf(oid, '</BODY>\n');
fprintf(oid, '</HTML>\n');

fclose(oid);
web(fileName,'-browser') % open html in systems browser


