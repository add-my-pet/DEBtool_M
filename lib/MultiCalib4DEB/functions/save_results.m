%% save_results
% Saves multimodal calibration results by using the DEB results format. 

%%
function archive = save_results(archive, name, par, metaPar, txtPar, data, auxData, metaData, txtData, weights)
% created 2015/01/17 by Goncalo Marques, 2015/03/21 by Bas Kooijman
% modified 2015/03/30 by Goncalo Marques, 2015/04/01 by Bas Kooijman, 2015/04/14, 2015/04/27, 2015/05/05  by Goncalo Marques, 
% modified 2015/07/30 by Starrlight Augustine, 2015/08/01 by Goncalo Marques
% modified 2015/08/25 by Dina Lika, 2018/05/21, 2018/08/21 by Bas Kooijman
% modified 2020/11/29 by Juan Francisco Robles

%% Syntax
% <../save_results.m *save_results*>(par_set, metaPar, txtPar, data, auxData, metaData, txtData, weights) 

%% Description
% Computes model predictions and save them
%
% Input
% 
% * archive: the structure containing the calibration results
% * par_set: set with the best parameters found in multimodal calibration
% * metaPar: structure with information on metaparameters
% * txtPar: structure with information on parameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * par: parameter data
% * weights: structure with weights for each data set

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat and/or results_my_pet.html, 

  global pets 
  
  n_pets = length(pets);
  par_set = archive.(name).solutionsParameters; % set with the best parameters found in multimodal calibration
  n_pars = size(par_set,1);

  %% Variables to compose the solutions to calculate MRE and SMSE.
  parnm = fieldnames(par.free); % Get free parameters names
  np = numel(parnm); % Get number of free parameters
  index = 1:np; % Get indexes of these free parameters which can be modifyed
  index = index(cell2mat(struct2cell(par.free)) == 1);
  free = par.free; % free is here removed, and after execution added again
  aux = rmfield(par, 'free'); % copy input parameter matrix into output
  auxvec = cell2mat(struct2cell(aux));
  
  %% Compose the solutions from results and calculate errors
  for sol=1:n_pars
      auxvec(index) = par_set(sol,:)';
      aux = cell2struct(num2cell(auxvec, np), parnm);
      aux.free = free; % add substructure free to q
      % convert parameter structure of group of pets to cell string for each pet
      parPets = parGrp2Pets(aux); 
      % get (mean) relative errors and symmetric mean squared errors
      weightsMRE = weights;  % define a weights structure with weight 1 for every data point and 0 for the pseudodata 
      for i = 1:n_pets    
        if isfield(weights.(pets{i}), 'psd')
          psdSets = fields(weights.(pets{i}).psd);
          for j = 1:length(psdSets)
            weightsMRE.(pets{i}).psd.(psdSets{j}) = zeros(length(weightsMRE.(pets{i}).psd.(psdSets{j})), 1);
          end
        end
        [metaPar.MRE, metaPar.RE, info] = mre_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
        [metaPar.SMSE, metaPar.SSE] = smse_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
        if info == 0
          error('One parameter set did not pass the customized filters in the predict file')
        end
        clear('dataTemp', 'auxDataTemp', 'weightsMRETemp');
      end

      % save results to result_group.mat or result_my_pet.mat
      if n_pets > 1
          archive.(name).('solutionSet').(['solution_', int2str(sol)]).par = aux;
          archive.(name).('solutionSet').strcat('solution_', int2str(sol)).txtPar = txtPar;
          archive.(name).('solutionSet').(['solution_', int2str(sol)]).metaPar = metaPar;
          archive.(name).('solutionSet').(['solution_', int2str(sol)]).metaData = metaData;
      else % n_pets == 1
          metaPar.MRE = metaPar.MRE;   metaPar.RE = metaPar.RE;
          metaPar.SMSE = metaPar.SMSE; metaPar.SSE = metaPar.SSE;
          %metaPar = rmfield(metaPar, pets{1});
          
          archive.(name).('solutionSet').(['solution_', int2str(sol)]).par = aux;
          archive.(name).('solutionSet').(['solution_', int2str(sol)]).metaPar = metaPar;
      end
  end
  
  archive.(name).('solutionSet').data = data; 
  archive.(name).('solutionSet').auxData = auxData;
  archive.(name).('solutionSet').txtPar = txtPar;
  archive.(name).('solutionSet').metaData = metaData;
  archive.(name).('solutionSet').txtData = txtData;
  archive.(name).('solutionSet').weights = weights;
end
