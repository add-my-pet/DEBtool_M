%% prt_results2screen
% writes results of estimation to screen

%%
function prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData)
% created 2019/03/01 by Bas Kooijman

%% Syntax
% <../prt_results2screen.m *prt_results2screen*> (parPets, metaPar, txtPar, data, metaData, txtData, prdData) 

%% Description
% Writes results of an estimation to screen. Input is the same as for results_pets, but inputs auxData and  weights are not required in this function
%
% Input:
%
% * parPets: cell string of parameters for each pet
% * metaPar: structure with information on metaparameters
% * txtPar: structure with information on parameters
% * data: structure with data for species
% * metaData: structure with information on the entry
% * txtData: structure with information on the data
% * prdData: structure with predictions for the data
%
% Output:
%
% * no Malab output, text is written to screen

%% Remarks
% Function prt_results_my_pet writes to html; subfunction of results_pets.

  global pets
  
  n_pets = length(pets);
  
  for i = 1:n_pets
      fprintf([pets{i}, ' \n']); % print the species name
      if isfield(metaData.(pets{i}), 'COMPLETE')
        fprintf('COMPLETE = %3.1f \n', metaData.(pets{i}).COMPLETE)
      end
      fprintf('MRE = %8.3f \n', metaPar.(pets{i}).MRE)
      fprintf('SMSE = %8.3f \n\n', metaPar.(pets{i}).SMSE)
      
      fprintf('\n');
      printprd_st(data.(pets{i}), txtData.(pets{i}), prdData.(pets{i}), metaPar.(pets{i}).RE);
      
      currentPar = parPets.(pets{i});
      free = currentPar.free;  
      corePar = rmfield_wtxt(currentPar,'free'); coreTxtPar.units = txtPar.units; coreTxtPar.label = txtPar.label;
      [parFields, nbParFields] = fieldnmnst_st(corePar);
      % we need to make a small addition so that it recognised if one of the chemical parameters was released and then print that to the screen
      for j = 1:nbParFields
        if  ~isempty(strfind(parFields{j},'n_')) || ~isempty(strfind(parFields{j},'mu_')) || ~isempty(strfind(parFields{j},'d_'))
          corePar          = rmfield_wtxt(corePar, parFields{j});
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
