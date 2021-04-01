%% IBM
% Individual-Based-Model for NetLogo: runs NetLogo's Java-code using a generalized reactor

%%
function [txNL23W, info] = IBM(species, tT, tJX, X_0, V_X, h, t_R, t_max, tickRate, runNetLogo)
% created 2021/01/08 by Bas Kooijman

%% Syntax
% txNL23W = <../IBM.m *IBM*> (species, tT, tJX, X_0, V_X, h, t_R, t_max, tickrate, runNetLogo) 

%% Description
% Individual-Based-Model for NetLogo: Plots population trajectories in a generalised reactor for a selected species of cohorts that reproduce using 
%  a choice of 3 reprocduction-buffer-handling rules: (1) as soon as buffer allows (2) at accumulation during period a_b {3} at accumulation during period t_R. 
% Opens 2 html-pages in system browser to report species traits and EBT parameter settings, and plots 4 figures.
% The parameters of species are obtained either from allStat.mat, or from a cell-string {par, metaPar, metaData}.
% The 3 cells are obtained by loading a copy of <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries *results_my_pet.mat*>.
% Structure metaData is required to get species-name, T_typical and ecoCode, metaPar to get model.
% Sex allocation is randomised. If dioecy applies, the default (mean) sex-ratio is 1:1. Fertilisation is assumed to be sure. Males might differ in {p_Am} and/or E_Hp.
% The initial population is a single fertilized (female) egg from a well-fed mother. 
% Starvation parameters are added to parameter structure, if not present.
% Like all parameters, default settings can be changed by changing structure par in cell-string input.
% If specified background hazards in 6th input are too high, the population goes extinct.
%
% Input:
%
% * species: character-string with name of entry or cell-string with structures: {metaData, metaPar, par}
% * tT: optional (nT,2)-array with time and temperature in Kelvin (default: T_typical); time between 0 (= start) and t_max
%     If scalar, the temperature is assumed to be constant
% * tJX: optional (nX,2)-array with time and food supply; time scaled between 0 (= start) and t_max
%     If scalar, the food supply is assumed to be constant (default 100 times max ingestion rate) 
% * h: optional vector with dilution and background hazards for each stage (depending on the model) and boolean for thinning
%     Default value for the std model: [h_X, h_B0b, h_Bbp, h_Bpi, thin] = [0 0 0 0 0]
% * V_X: optional scalar with reactor volume (default 1000*V_m, where V_m is max struct volume)
% * X_0: optional scalar with initial food density (default: 0)
% * t_R: optional scalar for reproduction buffer handling rule with 
%
%    - 0 for spawning as soon as reproduction buffer allows (default)
%    - 1 for spawning after accumulation over an incubation period
%    - time between spawning events
%
% * t_max: optional scalar with simulation time (d, default 250*a_m, where a_m is mean life span)
% * tickRate: optional scalar number of ticks per day
% * runNetLogo: optional boolean for running NetLogo under Matlab in command-line (default 1)
%
% Output:
%
% * txNL23W: (n,7)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight
% * info: boolean with failure (0) of success (1)
%
%% Remarks
% The function assumes that NetLogo (version 6.2.0 was tested) and java.exe has been installed and a path to them specified.
% Model DEBtool_M/popDyn/IBMnlogo/std.nlogo (and other DEB models) can also be loaded directly into NetLogo (via dropdown File, item Open), after running this function with runNetLogo = 0, to set parameters.
% The parameters in NetLogo are set by hitting setup in NetLogo's gui and can subsequently be modified. See, however, info in NetLogo for restrictions.
% Hitting setup initiates the output file txNL23W.txt.
%
% If species is specified by string (rather than by data), its parameters are obtained from allStat.mat.
% The starvation parameters can only be set different from the default values by first input in the form of data and adding them to the par-structure.
% Empty inputs are allowed, default values are then used.
% The (first) html-page has traits at inidvidual level using the possibly modified parameter values. 
% This function IBM only controls input/output; computations are done in NetLogo.
% Temperature changes during embryo-period are ignored; age at birth uses T(0); All embryo's start with f=1.
% Background hazards do not depend on temperature, ageing hazards do.
%
% Be aware that the required computation time is roughly proportional to the number of individuals in the reactor, which can be very large, depending on the parameter settings. 
% Progress can be monitored by inspecting output-file txNL23W.txt

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_my_pet_pop({metaData, metaPar, par}, [], T, f, destinationFolder)
% * IBM('Torpedo_marmorata');
% * IBM('Torpedo_marmorata', C2K(18));

WD = cdIBMnlogo;

if ~exist ('runNetLogo', 'var') || isempty(runNetLogo)
  runNetLogo = true;
end

if ~exist ('t_R', 'var') || isempty(t_R)
  t_R = 0;
end

if ~exist ('tickRate', 'var') || isempty(tickRate)
  tickRate = 24;
end

% get core parameters (2 possible routes for getting pars), species and model
if iscell(species) 
  metaData = species{1}; metaPar = species{2}; par = species{3};  
  species = metaData.species; info = 1;
  par.reprodCode = metaData.ecoCode.reprod{1};
  par.genderCode = metaData.ecoCode.gender{1};
  datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
else  % use allStat.mat as parameter source 
  [par, metaPar, txtPar, metaData, info] = allStat2par(species);
  if info == 0
    fprintf('Species not recognized\n');
    txNL23W = []; return
  end
  reprodCode = read_eco({species}, 'reprod'); par.reprodCode = reprodCode{1};
  genderCode = read_eco({species}, 'gender'); par.genderCode = genderCode{1};
  datePrintNm = ['allStat version: ', datestr(date_allStat, 'yyyy/mm/dd')];
end
model = metaPar.model;

% unpack par and compute compound pars
vars_pull(par); vars_pull(parscomp_st(par)); 

% time to be simulated
if ~exist('t_max','var') || isempty(t_max)
  t_max = 150*365; % -, total simulation time
end

% temperature
if ~exist('tT','var') || isempty(tT) 
  T = metaData.T_typical; tT = [0 T; t_max T];
elseif size(tT,2) == 2 && tT(1,1) == 0 && ~(tJX(end,1) < t_max)
  tT = [tT; t_max tT(end,2)];
elseif size(tT,1) == 1
  T = tT; tT = [0 T; (t_max + 1) T];   
end

% volume of reactor
if ~exist('V_X','var') || isempty(V_X)
  V_X = 1e2 * L_m^3; % cm^3, volume of reactor
end

% supply food 
if ~exist('tJX','var') || isempty(tJX) || size(tJX,2) == 1
  J_X = 1500*V_X/mu_X; % 500 * J_X_Am * L_m^2 ;
  tJX = [0 J_X; t_max J_X]; 
else tJX(1,1) == 0 & ~(tJX(end,1) < t_max)
  tJX = [tJX; t_max tJX(end,2)];    
end

% initial food density
if ~exist('X_0','var') || isempty(X_0)
  X_0 = 0; % -, X at t=0
end

% account for male production
if strcmp(reprodCode{1}, 'O') && strcmp(genderCode{1}, 'D')
  par.fProb = 0.5;  % probability of embryo to be female
else
  par.fProb = 0.999; % probability of embryo to be female   
end

% rejuvenation parameters
if ~isfield('par', 'k_JX')
  k_JX = k_J/ 100; par.k_JX = k_JX;
end
if ~isfield('par', 'h_J')
  h_J = 1e-4; par.h_J = h_J;
end

% hazard rates, thinning
if ~exist('h','var') || isempty(h)
  h_X = 0.1; thin = 0; 
else
  h_X = h(1); thin = h(end);
end
par.h_X = h_X; par.thin = thin; 
%
switch model
  case {'std','stf','sbp','abp'}
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(3); h_Bbp = h(3); h_Bpi = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpi = h_Bpi; 
  case 'stx'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbx = 1e-35; h_Bxp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(3); h_Bbx = h(4); h_Bxp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbx = h_Bbx; par.h_Bxp = h_Bxp; par.h_Bpi = h_Bpi; 
  case 'ssj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbs = 1e-35; h_Bsj = 1e-35; h_Bjp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(3); h_Bbs = h(4); h_Bsp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs; par.h_Bsj = h_Bsj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'abj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbj = 1e-35; h_Bjp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(3); h_Bbj = h(4); h_Bjp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'asj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbs = 1e-35; h_Bsj = 1e-35; h_Bjp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(3); h_Bbs = h(4); h_Bsj = h(5); h_Bjp = h(6); h_Bpi = h(7);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs;par.h_Bsj = h_Bsj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'hep'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-10; h_Bbp = 1e-10; h_Bpj = 1e-10; h_Bji = 1e-10; 
    else
      h_B0b = h(3); h_Bbp = h(4); h_Bpj = h(5);  h_Bji = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpj = h_Bpj; par.h_Bji = h_Bji; 
  case 'hex'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-10; h_Bbj = 1e-10; h_Bje = 1e-10; h_Bei = 1e-10; 
    else
      h_B0b = h(3); h_Bbj = h(4); h_Bje = h(5); h_Bei = h(6);    
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bje = h_Bje; par.h_Bei = h_Bei; 
  otherwise
    return
end

% get trajectories
txNL23W = get_IBMnlogo(model, par, tT, tJX, X_0, V_X, t_R, t_max, tickRate, runNetLogo);

cd(WD);

if runNetLogo

%% plotting
close all
title_txt = [strrep(species, '_', ' '), ' ', datePrintNm];
%
figure(1)
plot(txNL23W(:,1), txNL23W(:,2), 'k', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('scaled food density X/K, -');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(2)
plot(txNL23W(:,1), txNL23W(:,3), 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('# of individuals, #/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(3)
plot(txNL23W(:,1), txNL23W(:,4),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural length, cm/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(4)
plot(txNL23W(:,1), txNL23W(:,5),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural surface area, cm^2/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(5)
plot(txNL23W(:,1), txNL23W(:,6),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural volume, cm^3/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(6)
plot(txNL23W(:,1), txNL23W(:,7),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total wet weight, g/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(7)
plot(txNL23W(:,1), txNL23W(:,7)./txNL23W(:,3), 'k', 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('mean wet weight per individual, g');
set(gca, 'FontSize', 15, 'Box', 'on')

end

%% report_my_pet.html

fileName = ['report_', species, '.html'];
prt_report_my_pet({par, metaPar, txtPar, metaData}, [], [], [], [], fileName);
web(fileName,'-browser') % open html in systems browser

%%  IBMnlogo_my_pet.html

fileName = ['IBMnlogo_', species, '.html'];
oid = fopen(fileName, 'w+'); % open file for writing, delete existing content

fprintf(oid, '<!DOCTYPE html>\n');
fprintf(oid, '<HTML>\n');
fprintf(oid, '<HEAD>\n');
fprintf(oid, '  <TITLE>EBT %s</TITLE>\n', strrep(species, '_', ' '));
fprintf(oid, '  <style>\n');
fprintf(oid, '    .newspaper {\n');
fprintf(oid, '      column-count: 3;\n');
fprintf(oid, '      height: 500px;\n');
fprintf(oid, '    }\n\n');

fprintf(oid, '    div.temp {\n');
fprintf(oid, '      width: 100%%;\n');
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
fprintf(oid, str, 'h_X', '1/d', h_X, 'hazard rate for food from reactor');
fprintf(oid, str, 'thin', '-', thin, 'boolean for thinning');
switch model
  case {'std','stf','sbp','abp'}
      fprintf(oid, str, 'h_B0b', '1/d', h_B0b, 'background hazard rate from 0 to b');
      fprintf(oid, str, 'h_Bbp', '1/d', h_Bbp, 'background hazard rate from b to p');
      fprintf(oid, str, 'h_Bpi', '1/d', h_Bpi, 'background hazard rate from p to i');
  case 'stx'
      fprintf(oid, str, 'h_B0b', '1/d', h_B0b, 'background hazard rate from 0 to b');
      fprintf(oid, str, 'h_Bbx', '1/d', h_Bbx, 'background hazard rate from b to x');
      fprintf(oid, str, 'h_Bxp', '1/d', h_Bxp, 'background hazard rate from x to p');
      fprintf(oid, str, 'h_Bpi', '1/d', h_Bpi, 'background hazard rate from p to i');
  case 'ssj'
      fprintf(oid, str, 'h_B0b', '1/d', h_B0b, 'background hazard rate from 0 to b');
      fprintf(oid, str, 'h_Bbs', '1/d', h_Bbs, 'background hazard rate from b to s');
      fprintf(oid, str, 'h_Bsj', '1/d', h_Bsj, 'background hazard rate from s to j');
      fprintf(oid, str, 'h_Bjp', '1/d', h_Bjp, 'background hazard rate from j to p');
      fprintf(oid, str, 'h_Bpi', '1/d', h_Bpi, 'background hazard rate from p to i');
  case 'abj'
      fprintf(oid, str, 'h_B0b', '1/d', h_B0b, 'background hazard rate from 0 to b');
      fprintf(oid, str, 'h_Bbj', '1/d', h_Bbj, 'background hazard rate from b to j');
      fprintf(oid, str, 'h_Bjp', '1/d', h_Bjp, 'background hazard rate from j to p');
      fprintf(oid, str, 'h_Bpi', '1/d', h_Bpi, 'background hazard rate from p to i');
  case 'asj'
      fprintf(oid, str, 'h_B0b', '1/d', h_B0b, 'background hazard rate from 0 to b');
      fprintf(oid, str, 'h_Bbs', '1/d', h_Bbs, 'background hazard rate from b to s');
      fprintf(oid, str, 'h_Bsj', '1/d', h_Bsj, 'background hazard rate from s to j');
      fprintf(oid, str, 'h_Bjp', '1/d', h_Bjp, 'background hazard rate from j to p');
      fprintf(oid, str, 'h_Bpi', '1/d', h_Bpi, 'background hazard rate from p to i');
end
fprintf(oid, str, 'X_0', 'mol/L', X_0, 'initial food density');
fprintf(oid, str, 'V_X', 'L', V_X, 'volume of reactor');
fprintf(oid, str, 't_max', '-', t_max, 'maximum integration time');

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

fprintf(oid, '  </TABLE>\n'); % close numPar table
fprintf(oid, '  </div>\n\n');
fprintf(oid, '  </div>\n\n'); % end div newspaper

fprintf(oid, '</BODY>\n');
fprintf(oid, '</HTML>\n');

fclose(oid);
web(fileName,'-browser') % open html in systems browser


