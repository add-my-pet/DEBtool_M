%% EBT
% escalator boxcar train: runs Andre de Roos' C-code using a generalized reactor

%%
function [txNL23W, info] = EBT(species, tT, tJX, x_0, V_X, h, t_max, numPar)
% created 2020/04/03 by Bas Kooijman, modified 2023/05/13

%% Syntax
% txL23W = <../EBT.m *EBT*> (species, tT, tJX, x_0, V_X, h, t_max, numPar) 

%% Description
% Escalator Boxcar Train: Plots population trajectories in a generalised reactor for a selected species of cohorts that reproduce continuously. 
% Opens 2 html-pages in system browser to report species traits and EBT parameter settings, and plots 4 figures.
% The parameters of species are obtained either from allStat.mat, or from a cell-string {par, metaPar, metaData}.
% The 3 cells are obtained by loading a copy of <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries *results_my_pet.mat*>.
% Structure metaData is required to get species-name, T_typical and ecoCode, metaPar to get model.
% If dioecy applies, the sex-ratio is assumed to be 1:1 and fertilisation is assumed to be sure.
% The present implementation ignores males. 
% The initial population is a single fertilized (female) egg. 
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
% * x_0: optional scalar with initial scaled food density as fraction of half saturation constant (default: 0)
% * t_max: optional scalar with simulation time (d, default 250*365).
% * numPar: optional structure with numerical parameter settings.
%      Possible fields: 
%
%        TIME_METHOD,integr_accuracy,cycle_interval,tol_zero,time_interval_out,state_out_interval,min_cohort_nr, ...
%        relTol_a,relTol_q,relTol_h_a,relTol_L,relTol_E,relTol_E_R,relTol_E_H,relTol_W, ...
%        absTol_a,absTol_q,absTol_h_a,absTol_L,absTol_E,absTol_E_R,absTol_E_H,absTol_W
%
%      Possible values for TIME_METHOD: 
%     	- rk2: the 2nd order Runge-Kutta integration method with fixed step size,
%    	- rk4: the 4th order Runge-Kutta integration method with fixed step size,
%    	- rkf45: the Runge-Kutta-Fehlberg 4/5th order integration method with an adaptive step size,
%    	- rkck: the Cash-Karp Runga-Kutta integration method with adaptive step size, 
%    	- DOPRI5: an explicit Runge-Kutta method of order (4)5 due to Dormand & Prince with step size control and dense output.
%   	- DOPRI8: an explicit Runge-Kutta method of order 8(5,3) due to Dormand & Prince with step size control and dense output.
%   	- RADAU5: an implicit Runge-Kutta method of order 5 with step size  control and dense output.
%
%     The DOPRI5, DOPRI8 and RADAU5 methods can detect and locate discontinuities or events. 
%     These events are signalled by the routine	EventLocation() in the program definition file. 
%     Integration will be carried out exactly up to the moment that the event takes place and will be restarted subsequently.
%     Default: DOPRI5
%
% Output:
%
% * txNL23W: (n,7)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight
% * info: boolean with failure (0) of success (1)
%
%% Remarks
% The function assumes that a C-compiler with name gcc.exe has been installed and a path to it specified.
% This C-code was written by Andre de Roos.
% This Matlab function only uses the computational core of EBTtool, which required tiny modifications; the required modified files have been copied into DEBtool_M/EBTtool
%
% If species is specified by string (rather than by data), its parameters are obtained from allStat.mat.
% The starvation parameters can only be set different from the default values by first input in the form of data and adding them to the par-structure.
% Empty inputs are allowed, default values are then used.
% The (first) html-page has traits at inidvidual level using the possibly modified parameter values. 
% This function EBT only controls input/output; computations are done in EBTtool of Andre de Roos via <../html/get_EBT.html *get_EBT*>.
% Temperature changes during embryo-period are ignored; age at birth uses T(0); All embryo's start with f=1.
% Background hazards do not depend on temperature, ageing hazards do.
% For modification of EBTtool, see <https://add-my-pet.github.io/DEBtool_M/EBTtool/EBTmanual.pdf *manual*>

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_my_pet_pop({metaData, metaPar, par}, [], T, f, destinationFolder)
% * EBT('Torpedo_marmorata');
% * EBT('Torpedo_marmorata', C2K(18));

WD = cdEBTtool;

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
  T = metaData.T_typical; tT = [0 T; t_max*1.1 T];
elseif size(tT,2) == 2 && tT(1,1) == 0 && ~(tJX(end,1) < t_max)
  tT = [tT; t_max*1.1 tT(end,2)];
elseif size(tT,1) == 1
  T = tT; tT = [0 T; t_max*1.1 T];   
end

% volume of reactor
if ~exist('V_X','var') || isempty(V_X)
  V_X = 1e2 * L_m^3; % cm^3, volume of reactor
end

% supply food 
if ~exist('tJX','var') || isempty(tJX)
  J_X = 75 * J_X_Am * L_m^2 ;
  tJX = [0 J_X; t_max*1.1 J_X]; 
elseif size(tJX,2) == 1
  tJX = [0 tJX; t_max*1.1 tJX]; 
end
if tJX(1,1) > 0
  tJX = [0 tJX(1,2); tJX];
end
if tJX(end,1) <= t_max
  tJX = [tJX; t_max*1.1 tJX(end,2)];    
end

% initial scaled food density
if ~exist('x_0','var') || isempty(x_0)
  x_0 = 0; % -, X/K at t=0
end

% account for cost of male production, but presently not implemented in ETB
if strcmp(reprodCode{1}, 'O') && strcmp(genderCode{1}, 'D')
  kap_R = kap_R/2;  par.kap_R = kap_R; % reprod efficiency is halved, assuming sex ratio 1:1
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
      h_B0b = h(2); h_Bbp = h(3); h_Bpi = h(4);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpi = h_Bpi; 
  case 'stx'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbx = 1e-35; h_Bxp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(2); h_Bbx = h(3); h_Bxp = h(4); h_Bpi = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbx = h_Bbx; par.h_Bxp = h_Bxp; par.h_Bpi = h_Bpi; 
  case 'ssj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbs = 1e-35; h_Bsp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(2); h_Bbs = h(3); h_Bsp = h(4); h_Bpi = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs; par.h_Bsp = h_Bsp; par.h_Bpi = h_Bpi; 
  case 'abj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbj = 1e-35; h_Bjp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(2); h_Bbj = h(3); h_Bjp = h(4); h_Bpi = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'asj'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-35; h_Bbs = 1e-35; h_Bsj = 1e-35; h_Bjp = 1e-35; h_Bpi = 1e-35; 
    else
      h_B0b = h(2); h_Bbs = h(3); h_Bsj = h(4); h_Bjp = h(5); h_Bpi = h(6);       
    end
    par.h_B0b = h_B0b; par.h_Bbs = h_Bbs;par.h_Bsj = h_Bsj; par.h_Bjp = h_Bjp; par.h_Bpi = h_Bpi; 
  case 'hep'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-10; h_Bbp = 1e-10; h_Bpj = 1e-10; h_Bji = 1e-10; 
    else
      h_B0b = h(2); h_Bbp = h(3); h_Bpj = h(4);  h_Bji = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpj = h_Bpj; par.h_Bji = h_Bji; 
  case 'hax'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-10; h_Bbp = 1e-10; h_Bpj = 1e-10; h_Bje = 1e-10; h_Bei = 1e-10; 
    else
      h_B0b = h(2); h_Bbp = h(3); h_Bpj = h(4);  h_Bji = h(5);       
    end
    par.h_B0b = h_B0b; par.h_Bbp = h_Bbp; par.h_Bpj = h_Bpj; par.h_Bji = h_Bji; 
  case 'hex'
    if ~exist('h','var') || isempty(h)
      h_B0b = 1e-10; h_Bbj = 1e-10; h_Bje = 1e-10; h_Bei = 1e-10; 
    else
      h_B0b = h(2); h_Bbj = h(3); h_Bje = h(4); h_Bei = h(4);    
    end
    par.h_B0b = h_B0b; par.h_Bbj = h_Bbj; par.h_Bje = h_Bje; par.h_Bei = h_Bei; 
  otherwise
    return
end

% fields for numerical parameters
flds = {'TIME_METHOD','integr_accurary','cycle_interval','tol_zero','time_interval_out','state_out_interval','min_cohort_nr', ...
    'relTol_a','relTol_q','relTol_h_a','relTol_L','relTol_E','relTol_E_R','relTol_E_H','relTol_W','relTol_s_M', ...
    'absTol_a','absTol_q','absTol_h_a','absTol_L','absTol_E','absTol_E_R','absTol_E_H','absTol_W','absTol_s_M'};
n_flds = length(flds);
% set default numerical parameters
opt.TIME_METHOD = 'DOPRI5';  opt.txt.TIME_METHOD = 'Time integration method'; % should be 'DOPRI5'
opt.integr_accurary = 1e-8;  opt.txt.integr_accurary = 'Fixed step size or integration accuracy when adaptive';
opt.cycle_interval = 2;      opt.txt.cycle_interval = 'Cohort/Integration cycle time interval'; 
opt.tol_zero = 1e-6;         opt.txt.tol_zero = 'Tolerance value, determining identity with zero';
opt.time_interval_out = t_max/5000; opt.txt.time_interval_out = 'Output time interval';
opt.state_out_interval = 0;  opt.txt.state_out_interval = 'Complete state output interval, 0 for none';
opt.min_cohort_nr = 1e-3;    opt.txt.min_cohort_nr = 'Minimum allowable number of individuals in cohort';

tol = 1e-7;
opt.relTol_a = tol;         opt.txt.relTol_a = 'Relative tolerance for age a'; 
opt.relTol_q = tol;         opt.txt.relTol_q = 'Relative tolerance for aging acceleration q'; 
opt.relTol_h_a = tol;       opt.txt.relTol_h_a = 'Relative tolerance for hazard for aging h';
opt.relTol_L = tol;         opt.txt.relTol_L = 'Relative tolerance for structural length L'; 
opt.relTol_E = tol;         opt.txt.relTol_E = 'Relative tolerance for reserve density [E]';
opt.relTol_E_R = tol;       opt.txt.relTol_E_R = 'Relative tolerance for reprod buffer E_R';
opt.relTol_E_H = tol;       opt.txt.relTol_E_H = 'Relative tolerance for maturity E_H'; 
opt.relTol_W = tol;         opt.txt.relTol_W = 'Relative tolerance for wet weight Ww';
opt.relTol_s_M = tol;       opt.txt.relTol_s_M = 'Relative tolerance for acceleration factor s_M';

opt.absTol_a = tol;         opt.txt.absTol_a = 'Absolute tolerance for age a'; 
opt.absTol_q = tol;         opt.txt.absTol_q = 'Absolute tolerance for aging acceleration q'; 
opt.absTol_h_a = tol;       opt.txt.absTol_h_a = 'Absolute tolerance for hazard for aging h';
opt.absTol_L = tol;         opt.txt.absTol_L = 'Absolute tolerance for structural length L'; 
opt.absTol_E = tol;         opt.txt.absTol_E = 'Absolute tolerance for reserve density [E]';
opt.absTol_E_R = tol;       opt.txt.absTol_E_R = 'Absolute tolerance for reprod buffer E_R';
opt.absTol_E_H = tol;       opt.txt.absTol_E_H = 'Absolute tolerance for maturity E_H'; 
opt.absTol_W = tol;         opt.txt.absTol_W = 'Absolute tolerance for wet weight Ww';
opt.absTol_s_M = tol;       opt.txt.absTol_s_M = 'Absolute tolerance for acceleration factor s_M';

% overwrite with specified numerical parameters
if exist('numPar', 'var') && ~isempty(numPar)
  for i=1:n_flds
    if isfield(numPar,flds{i})
      opt.(flds{i}) = numPar.(flds{i});
    end
  end
end

% get trajectories
txNL23W = get_EBT(model, par, tT, tJX, x_0, V_X, t_max, opt);

% delete created files
delete(['EBT', model, '.csb'])
delete(['EBT', model, '.cvf'])
delete(['EBT', model, '.esf'])
delete(['EBT', model, '.exe'])
delete(['EBT', model, '.isf'])
delete(['EBT', model, '.out'])
delete(['EBT', model, '.rep'])
delete(['deb\EBT', model, '.h'])
delete('spline_JX.c')
delete('spline_TC.c')

cd(WD);

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


%% report_my_pet.html

fileName = ['report_', species, '.html'];
prt_report_my_pet({par, metaPar, txtPar, metaData}, [], [], [], [], fileName);

%%  EBT_my_pet.html

fileName = ['EBT_', species, '.html'];
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
      fprintf(oid, str, 'h_Bsp', '1/d', h_Bsp, 'background hazard rate from s to p');
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
fprintf(oid, str, 'X_0', 'mol/L', x_0 * K, 'initial food density');
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

% Table with numerical parameters

fprintf(oid, '  <div class="par">\n');
fprintf(oid, '  <TABLE id="par">\n');
fprintf(oid, '    <TR  class="head"> <TH>Numerical parameters</TH> <TH>value</TH> </TR>\n');
fprintf(oid, '    <TR><TD>%s</TD> <TD>%s</TD>\n', opt.txt.(flds{1}), opt.(flds{1}));
for i=2:n_flds
fprintf(oid, '    <TR><TD>%s</TD> <TD>%3.4g</TD>\n', opt.txt.(flds{i}), opt.(flds{i}));
end

fprintf(oid, '  </TABLE>\n'); % close numPar table
fprintf(oid, '  </div>\n\n');
fprintf(oid, '  </div>\n\n'); % end div newspaper

fprintf(oid, '</BODY>\n');
fprintf(oid, '</HTML>\n');

fclose(oid);
web(fileName,'-browser') % open html in systems browser

