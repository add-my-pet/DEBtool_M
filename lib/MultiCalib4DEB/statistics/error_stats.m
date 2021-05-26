%% error_stats
% Print error statistics on screen

%%
function error_stats(par, metaPar, data, auxData, metaData, txtData, txtPar)
% created 2020/11/30 by Juan Francisco Robles

%% Syntax
% <../error_stats.m *error_stats*>(par, metaPar, data, metaData, txtData, txtPar) 

%% Description
% Plotes model predictions from calibration solutions
%
% Input
% 
% * par: structure with parameters of species
% * metaPar: structure with information on metaparameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * txtData: structure with information on the data

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat and/or results_my_pet.html, 
% plots to screen
% writes to report_my_pet.html and shows in browser
% Plots use lava-colour scheme; from high to low: white, red, blue, black.
% In grp-plots, colours are assigned from high to low.
% Since the standard colour for females is red, and for males blue, compose set with females first, then males.

global pets 

n_pets = length(pets);

data2plot = data;
close all % to avoid saving figures generated prior the current run
univarX = {}; 
for i = 1:n_pets
  st = data2plot.(pets{i}); 
  [nm, nst] = fieldnmnst_st(st);
  for j = 1:nst  % replace univariate data by plot data 
    fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
    varData = getfield(st, fieldsInCells{1}{:});   % scaler, vector or matrix with data in field nm{i}
    k = size(varData, 2);  
    if k == 2 
      auxDataFields = fields(auxData.(pets{i}));
      dataCode = fieldsInCells{1}{:};
      univarAuxData = {};
      for ii = 1:length(auxDataFields) % add to univarAuxData all auxData for the data set that has length > 1
        if isfield(auxData.(pets{i}).(auxDataFields{ii}), dataCode) && length(auxData.(pets{i}).(auxDataFields{ii}).(dataCode)) > 1
          univarAuxData{end + 1} = auxDataFields{ii};
        end
      end
      aux = getfield(st, fieldsInCells{1}{:});
      dataVec = aux(:,1); 
      if isempty(univarAuxData) % if there is no univariate auxiliary data the axis can have 100 points otherwise it will have the same points as in data 
        xAxis = linspace(min(dataVec), max(dataVec), 100)';
        univarX = setfield(univarX, fieldsInCells{1}{:}, 'dft');
      else
        xAxis = dataVec;
        univarX = setfield(univarX, fieldsInCells{1}{:}, 'usr');
      end
      st = setfield(st, fieldsInCells{1}{:}, xAxis);
    end
  end
  data2plot.(pets{i}) = st;
end

prdData = predict_pets(par, data2plot, auxData);

for i = 1:n_pets
    parPets = parGrp2Pets(par);
    fprintf([pets{i}, ' \n']); % print the species name
    if isfield(metaData, 'COMPLETE')
        fprintf('COMPLETE = %3.1f \n', metaData.COMPLETE)
    end
    fprintf('MRE = %8.3f \n', metaPar.MRE)
    fprintf('SMSE = %8.3f \n\n', metaPar.SMSE)
      
    fprintf('\n');
    printprd_st(data.(pets{i}), txtData.(pets{i}), prdData.(pets{i}), metaPar.RE);
      
    currentPar = parPets.(pets{i});
    free = currentPar.free;  
    corePar = rmfield_wtxt(currentPar,'free'); coreTxtPar.units = txtPar.units; coreTxtPar.label = txtPar.label;
    [parFields, nbParFields] = fieldnmnst_st(corePar);
    % we need to make a small addition so that it recognised if one of the chemical parameters was released and then print that to the screen
    for j = 1:nbParFields
        if ~isempty(strfind(parFields{j},'n_')) || ~isempty(strfind(parFields{j},'mu_')) || ~isempty(strfind(parFields{j},'d_'))
            corePar = rmfield_wtxt(corePar, parFields{j});
            coreTxtPar.units = rmfield_wtxt(coreTxtPar.units, parFields{j});
            coreTxtPar.label = rmfield_wtxt(coreTxtPar.label, parFields{j});
            free  = rmfield_wtxt(free, parFields{j});
        end
    end
    parFreenm = fields(free);
    for j = 1:length(parFreenm)
        if length(free.(parFreenm{j})) ~= 1
            free.(parFreenm{j}) = free.(parFreenm{j})(i);
        end
    end
    corePar.free = free;
    printpar_st(corePar,coreTxtPar);
    fprintf('\n')
end
    
end 