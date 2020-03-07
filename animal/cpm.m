%% cpm
% runs a cohort projection model using a generalized reactor

%%
function [tXN tXW] = cpm(species, tT, tx, h, x_0, n_R, t_R)
% created 2020/03/02 by Bob Kooi and Bas Kooijman

%% Syntax
% tXN = <../cpm.m *cpm*> (species, tT, tx, h, x_0, n_R, t_R) 

%% Description
% Plot population trajectories in a generalised reactor for a selected species of cohorts that periodically reproduce synchroneously. 
% The number of cohorts equals the max age in years plus 1; max age is when the survaval prob is less than 1e-6.
% The parameters of species are obtained either from allStat.mat, or from a cell-string {par, metaPar, metaData}.
% The 3 cells are output structures of <http://www.debtheory.org/wiki/index.php?title=Mydata_file *mydata_my_pet*> and
% <http://www.debtheory.org/wiki/index.php?title=Pars_init_file *pars_init_my_pet*>, as part of the parameter estimation process.
% Structure metadata is required to get species-name, T_typical and ecoCode, metaPar to get model.
% If dioecy applies, the sex-ratio is assumed to be 1:1 and fertilisation is assumed to be sure.
% The energy cost for male-production is taken into account by halving kap_R, but their parameters are assumed to be the same, compared to females. 
% The initial population is a single fertilized (female) egg. 
% Starvation parameters are added to parameter structure, if not present.
% Default: max shrinking fraction del_X = 0.7, maturity decay k_JX = k_J and maturity hazard h_J = 1e-2 1/d;
% If specified background hazards in 4th input are too high, the population goes extinct.
%
% Input:
%
% * species: character-string with name of entry or cell-string with structures: {metaData, metaPar, par}
% * tT: optional (nT,2)-array with time and temperature in Kelvin (default: T_typical); time scaled between 0 (= start) and 1 (= end of cycle)
%     If scalar, the temperature is assumed to be constant
% * tx: optional (nX,2)-array with time and food density in supply as fraction of half saturation constant K (default: 1); time scaled between 0 (= start) and 1 (= end of cycle)
%     If scalar, the food density in the supply is assumed to be constant
% * h: optional vector with supply, dilution and background hazards for each stage (depending on the model) and boolean for thinning
%     Default value for the std model: [h_I, h_D, h_B0b, h_Bbp, h_Bpi, thin] = [1e-2 0 0 0 0 0]  
% * x_0: optional scalar with scaled initial food density (default that of supply in input 3)
% * n_R: optional scalar with number of reproduction events to be simulated (default 100).
% * t_R: optional scalar with time period between reproduction events (default 1 yr)
%
% Output:
%
% * tXN: (n,m)-array with times, food density and number of individuals in the various cohorts
% * tXW: (n,m)-array with times, food density and cohort wet weights
%
%% Remarks
% If species is specified by string (rather than by data), its parameters are obtained from allStat.mat.
% The starvation parameters can only be set different from the default values by first input in the form of data and adding them to the par-structure.

%% Example of use
%
% * If results_My_Pet.mat exists in current directory (where "My_Pet" is replaced by the name of some species, but don't replace "my_pet"):
%   load('results_My_Pet.mat'); prt_my_pet_pop({metaData, metaPar, par}, [], T, f, destinationFolder)
% * cmp('Rana_temporaria')
% * cmp('Rana_temporaria', C2K(22))
% * cmp('Rana_temporaria', [0 .25 .75; C2K([10 25 7])]', 5)
% * cmp('Rana_temporaria', [], [0 .25 .75; 6 8 .8]')

% get core parameters (2 possible routes for getting pars), species and model
if iscell(species) 
  metaData = species{1}; metaPar = species{2}; par = species{3};  
  species = metaData.species;
  par.reprodCode = metaData.ecoCode.reprod(1);
  par.genderCode = metaData.ecoCode.gender(1);
  datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
else  % use allStat.mat as parameter source 
  reprodCode = read_eco({species}, 'reprod'); par.reprodCode = reprodCode(1);
  genderCode = read_eco({species}, 'gender'); par.genderCode = genderCode(1);
  [par, metaPar, txtPar, metaData] = allStat2par(species); 
  datePrintNm = ['allStat version: ', datestr(date_allStat, 'yyyy/mm/dd')];
end
model = metaPar.model;

% starvation parameters
if ~isfield('par', 'del_X')
  par.del_X = 0;
end
if ~isfield('par', 'k_JX')
  par.k_JX = par.k_J;
end
if ~isfield('par', 'h_J')
  par.h_J = 1e-2;
end

% hazard rates and thinning
if ~exist('h','var') || isempty(h)
  par.h_I = 1e-2; par.h_D = 0; par.thin = 0;
else
  par.h_I = h(1); par.h_D = h(2); par.thin = h(end);
end

switch model
  case {'std','stf','sbp','abp'}
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbp = 0; par.h_Bpi = 0; 
    else
      par.h_B0b = h(3); par.h_Bbp = h(3); par.h_Bpi = h(5);       
    end
  case 'stx'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbx = 0; par.h_Bxp = 0; par.h_Bpi = 0; 
    else
      par.h_B0b = h(3); par.h_Bbx = h(4); par.h_Bxp = h(5); par.h_Bpi = h(6);       
    end
  case 'ssj'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbs = 0; par.h_Bsj = 0; par.h_Bjp = 0; par.h_Bpi = 0; 
    else
      par.h_B0b = h(3); par.h_Bbs = h(4); par.h_Bsp = h(5); par.h_Bpi = h(6);       
    end
  case 'abj'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbj = 0; par.h_Bjp = 0; par.h_Bpi = 0; 
    else
      par.h_B0b = h(3); par.h_Bbj = h(4); par.h_Bjp = h(5); par.h_Bpi = h(6);       
    end
  case 'asj'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbs = 0;par.h_Bsj = 0; par.h_Bjp = 0; par.h_Bpi = 0; 
    else
      par.h_B0b = h(3); par.h_Bbs = h(4); par.h_Bsj = h(5); par.h_Bjp = h(6); par.h_Bpi = h(7);       
    end
  case 'hep'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbp = 0; par.h_Bpj = 0; par.h_Bji = 0; 
    else
      par.h_B0b = h(3); par.h_Bbp = h(4); par.h_Bpj = h(5);  par.h_Bji = h(6);       
    end
  case 'hex'
    if ~exist('h','var') || isempty(h)
      par.h_B0b = 0; par.h_Bbj = 0; par.h_Bje = 0; par.h_Bei = 0; 
    else
      par.h_B0b = h(3); par.h_Bbj = h(4); par.h_Bje = h(5); par.h_Bei = h(6);    
    end
  otherwise
    return
end

% temperature
if ~exist('tT','var') || isempty(tT)
  T = metaData.T_typical; tT = [0 T; 1 T];
elseif length(tT) == 1
  tT = [0 tT; 1 tT];
end

% scaled supply food density x = X/K
if ~exist('tx','var') || isempty(tX)
  tx = [0 1; 1 1];
elseif length(tx)  == 1
  tx = [0 tx; 1 tx];
end

% initial scaled food density
if ~exist('x_0','var') || isempty(x_0)
  x_0 = tx(1,2); % X/K at t=0
end

% number of reproduction events to be simulated
if ~exist('n_R','var') || isempty(n_R)
  n_R = 100; % -, total simulation time: n_R * t_R
end

% time between reproduction events
if ~exist('t_R','var') || isempty(t_R)
  t_R = 365; % d
end

% get trajectories
[tXN, tXW] = get_cpm(model, par, tT, tx, x_0, n_R, t_R);
t = tXN(:,1); X = tXN(:,2); N = cumsum(tXN(:,3:end),2); W = cumsum(tXW(:,3:end),2); n_c = size(N,2);

% plotting
figure(1)
plot(t,X,'k')
title([species, ' ', datePrintNm]);
xlabel('time, d');
ylabel('food density');
%
figure(2)
hold on
for i = 1:n_c-1
  plot(t,N(:,i),'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,N(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title([species, ' ', datePrintNm]);
xlabel('time, d');
ylabel('# of individuals');

figure(3)
hold on
for i = 1:n_c-1
  plot(t,W(:,i),'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,W(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title([species, ' ', datePrintNm]);
xlabel('time, d');
ylabel('total wet weight, g');

