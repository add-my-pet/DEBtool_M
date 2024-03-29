%% CPM
% Cohort Projection Model: runs a cohort projection model using a generalized reactor

%%
function [txNL23W, M_N, M_L, M_L2, M_L3, M_W, NL23Wt] = CPM(species, tT, tJX, x_0, V_X, h, n_R, t_R)
% created 2020/03/02 by Bob Kooi and Bas Kooijman

%% Syntax
% [txNL23W, M_N, M_L, M_L2, M_L3, M_W, NL23Wt] = <../CPM.m *CPM*> (species, tT, tJX, x_0, V_X, h, n_R, t_R) 

%% Description
% Cohort Projection Model: Plots population trajectories in a generalised reactor for a selected species of cohorts that periodically reproduce synchroneously. 
% Opens 2 html-pages in system browser to report species traits and ebt parameter settings, and plots 4 figures.
% The parameters of species are obtained either from allStat.mat, or from a cell-string {par, metaPar, metaData}.
% The 3 cells are obtained by loading a copy of <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries *results_my_pet.mat*>.
% Structure metadata is required to get species-name, T_typical and ecoCode, metaPar to get model.
% If dioecy applies, the sex-ratio is assumed to be 1:1 and fertilisation is assumed to be sure.
% The energy cost for male-production is taken into account by halving kap_R, but male parameters are assumed to be the same as female parameters. 
% The initial population is a single fertilized (female) egg. 
% Starvation parameters are added to parameter structure, if not present.
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
% * n_R: optional scalar with number of reproduction events to be simulated (default 150).
% * t_R: optional scalar with time period between reproduction events (default 1 yr)
%
% Output:
%
% * txNL23W: (n,7)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight
% * M_N: (n_c,n_c)-array with map for N: N(t+t_R) = M_N * N(t)
% * M_L: (n_c,n_c)-array with map for N: L(t+t_R) = M_N * L(t)
% * M_L2: (n_c,n_c)-array with map for N: L^2(t+t_R) = M_N * L^2(t)
% * M_L3: (n_c,n_c)-array with map for V: L^3(t+t_R) = M_N * L^3(t)
% * M_W: (n_c,n_c)-array with map for W: W(t+t_R) = M_W * W(t)
% * NL23Wt: (n_c.5)-array with values for N, L, L^2, L^3, W of cohorts at final time
%
%% Remarks
% If species is specified by string (rather than by data), its parameters are obtained from allStat.mat.
% The starvation parameters can only be set different from the default values by first input in the form of data and adding them to the par-structure.
% Empty inputs are allowed, default values are then used.
% The (first) html-page has traits at individual level using the possibly modified parameter values. 
% The last 5 outputs (the linear maps for N, L, L^2, L^3 and W) are only not-empty if the number of cohorts did not change long enough.
% CPM only controls input/output; computations are done in get_CPM, which calls <../html/dpm_mod.html *dCPMmod*>.
% Temperature changes during embryo-period are ignored; age at birth uses T(0); All embryo's start with f=1.
% Background hazards do not depend on temperature, ageing hazards do.
% During execution, the number of time-intervals of length n_R and the number of cohorts are printed to screen

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_my_pet_pop({metaData, metaPar, par}, [], T, f, destinationFolder)
% * CPM('Torpedo_marmorata');
% * CPM('Torpedo_marmorata', C2K(18));

% get core parameters (2 possible routes for getting pars), species and model
if iscell(species) 
  metaData = species{1}; metaPar = species{2}; par = species{3}; txtPar = species{4}; 
  species = metaData.species;
  datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
else  % use allStat.mat as parameter source 
  [par, metaPar, txtPar, metaData, info] = allStat2par(species); 
  if info == 0
    txNL23W=[]; M_N=[]; M_L = []; M_L2 = []; M_L3 = []; M_W=[]; NL23Wt = []; return
  end
  datePrintNm = ['allStat version: ', datestr(date_allStat, 'yyyy/mm/dd')];
end
par.reprodCode = metaData.ecoCode.reprod{1};
par.genderCode = metaData.ecoCode.gender{1};
model = metaPar.model;

% unpack par and compute compound pars
vars_pull(par); vars_pull(parscomp_st(par)); 

% number of reproduction events to be simulated
if ~exist('n_R','var') || isempty(n_R)
  n_R = 150; % -, total simulation time: n_R * t_R
end

% time between reproduction events
if ~exist('t_R','var') || isempty(t_R)
  t_R = 365; % d
end

% temperature
if ~exist('tT','var') || isempty(tT)
  tT = metaData.T_typical;
elseif length(tT) > 1 && sum(tT(:,1) > 1) > 0
  fprintf('abcissa of temp knots must be between 0 and 1\n');
  txNL23W=[]; M_N=[]; M_L = []; M_L2 = []; M_L3 = []; M_W=[]; NL23Wt = []; return
elseif tT(1,1) == 0 && ~(tT(end,1) == 1)
  tT = [tT; 1 tT(1,2)];    
end

% volume of reactor
if ~exist('V_X','var') || isempty(V_X)
  V_X = 1e3 * L_m^3; % cm^3, volume of reactor
end

% supply food 
if ~exist('tJX','var') || isempty(tJX)
  tJX = 1500*V_X/mu_X; % 500 * J_X_Am * L_m^2 ;
elseif length(tJX) > 1 && sum(tJX(:,1) > 1) > 0
  fprintf('abcissa of food supply knots must be between 0 and 1\n');
  txNL23W=[]; M_N=[]; M_L = []; M_L2 = []; M_L3 = []; M_W=[]; NL23Wt = []; return
elseif tJX(1,1) == 0 && ~(tJX(end,1) == 1)
  tJX = [tJX; 1 tJX(1,2)];    
end

% initial scaled food density
if ~exist('x_0','var') || isempty(x_0)
  x_0 = 10; % -, X/K at t=0
end

% account for cost of male production
if strcmp(reprodCode(1), 'O') && strcmp(genderCode(1), 'D')
  kap_R = kap_R/2; par.kap_R = kap_R; % reprod efficiency is halved, assuming sex ratio 1:1
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
      h_B0b = 0; h_Bbp = 0; h_Bpi = 0; 
    else
      h_B0b = h(3); h_Bbp = h(3); h_Bpi = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpi = h_Bpi; 
  case 'stx'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbx = 0; h_Bxp = 0; h_Bpi = 0; 
    else
      h_B0b = h(3); h_Bbx = h(4); h_Bxp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbx = h_Bbx; par.h_Bxp = h_Bxp; par.h_Bpi = h_Bpi; 
  case 'ssj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbs = 0; h_Bsj = 0; h_Bjp = 0; h_Bpi = 0; 
    else
      h_B0b = h(3); h_Bbs = h(4); h_Bsp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs; par.h_Bsj = h_Bsj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'abj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbj = 0; h_Bjp = 0; h_Bpi = 0; 
    else
      h_B0b = h(3); h_Bbj = h(4); h_Bjp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'asj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbs = 0; h_Bsj = 0; h_Bjp = 0; h_Bpi = 0; 
    else
      h_B0b = h(3); h_Bbs = h(4); h_Bsj = h(5); h_Bjp = h(6); h_Bpi = h(7);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs;par.h_Bsj = h_Bsj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'hep'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbp = 0; h_Bpj = 0; h_Bji = 0; 
    else
      h_B0b = h(3); h_Bbp = h(4); h_Bpj = h(5);  h_Bji = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpj = h_Bpj; par.h_Bji = h_Bji; 
  case 'hex'
    if ~exist('h','var') || isempty(h)
      h_B0b = 0; h_Bbj = 0; h_Bje = 0; h_Bei = 0; 
    else
      h_B0b = h(3); h_Bbj = h(4); h_Bje = h(5); h_Bei = h(6);    
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bje = h_Bje; par.h_Bei = h_Bei; 
  otherwise
    txNL23W=[]; M_N=[]; M_L = []; M_L2 = []; M_L3 = []; M_W=[]; NL23Wt = []; return
end

% get trajectories
[txN, txL, txL2, txL3, txW, M_N, M_L, M_L2, M_L3, M_W, info] = get_CPM(model, par, tT, tJX, x_0, V_X, n_R, t_R);
if info==0
  txNL23W=[]; M_N=[]; M_L = []; M_L2 = []; M_L3 = []; M_W=[]; NL23Wt = []; return
end
t = txN(:,1); x = txN(:,2); 
N = cumsum(txN(:,3:end),2); n_c = size(N,2);
L =  cumsum(txL(:,3:end),2); 
L2 =  cumsum(txL2(:,3:end),2); 
L3 =  cumsum(txL3(:,3:end),2); 
W = cumsum(txW(:,3:end),2);
txNL23W = [txN(:,1:2), N(:,end), L(:,end), L2(:,end), L3(:,end), W(:,end)]; 
NL23Wt = [txN(end,3:end); txL(end,3:end); txL2(end,3:end); txL3(end,3:end); txW(end,3:end)]';

%% plotting
close all
title_txt = [strrep(species, '_', ' '), ' ', datePrintNm];
%
figure(1) % t-x
plot(t, x, 'k', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('scaled food density, X/K');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(2) % t-N_tot
hold on
for i = 1:n_c-1
  plot(t, N(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t, N(:,n_c), 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('# of individuals, #/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(3) % t-L_tot
hold on
for i = 1:n_c-1
  plot(t, L(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,L(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural length, cm/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(4) % t-L^2_tot
hold on
for i = 1:n_c-1
  plot(t, L2(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,L2(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural surface area, cm^2/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(5) % t-L^3_tot
hold on
for i = 1:n_c-1
  plot(t, L3(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,L3(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total structural volume, cm^3/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(6) % t-Ww_tot
hold on
for i = 1:n_c-1
  plot(t, W(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,W(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('total wet weight, g/L');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure(7) % t- mean Ww of individual
hold on
W = zeros(n_c,1); 
for i = 1:n_c
  W(i,:) = txW(i,2+i)/txN(i,2+i);
end
plot(t(1:n_c), W, 'k', 'Linewidth', 2) 
title(title_txt);
xlabel('time, d');
ylabel('indiv. wet weight, g');
set(gca, 'FontSize', 15, 'Box', 'on')

%% report_my_pet

fileName = ['report_', species, '.html'];
prt_report_my_pet({par, metaPar, txtPar, metaData}, [], [], [], [], fileName);
web(fileName,'-browser') % open html in systems browser

%%  CPM_my_pet

fileName = ['CPM_', species, '.html'];
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
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n', 'reprodCode', '-', reprodCode, 'ecoCode reprod');
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD> <TD>%s</TD> <TD>%s</TD></TR>\n\n', 'genderCode', '-', genderCode, 'ecoCode gender');

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
fprintf(oid, str, 'x_0', '-', x_0, 'initial scaled food density');
fprintf(oid, str, 'V_X', 'L', V_X, 'volume of reactor');
fprintf(oid, str, 'n_R', '-', n_R, 'number of simulated reproduction events');
fprintf(oid, str, 't_R', 'd', t_R, 'time between reproduction events');
fprintf(oid, str, 'n_c', '-', n_c, 'ultimate number of cohorts');

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


