%% check_my_pet
% Checks my_data, pars_init and predict files for field inconsistencies

%%
function check_my_pet(speciesnms)
  % created 2015/05/05 by Goncalo Marques; 
  % modified Goncalo Marques 2015/05/12, 2015/06/05, 2015/07/02, 2015/07/08, 2015/07/22 
  % modified Bas Kooijman 2015/07/31, modified Goncalo Marques 2015/07/31
  
  %% Syntax 
  % <../check_my_pet.m *check_my_pet*> (speciesnm)

  %% Description
  % Checks my_data, pars_init and predict files for field inconsistencies.
  %
  % Checking points for my_data:
  %
  %   - existence of standard metaData fields
  %   - existence of temp
  %   - existence of pseudodata
  %   - existence of weights
  %   - existence of units (and number consistence with type of data)
  %   - existence of labels (and number consistence with type of data)
  %   - existence of bibkeys and the corresponding entries in biblist
  %
  % Checking points for pars_init:
  %
  %   - existence of standard metapar fields
  %   - model is one of the predefined models
  %   - existence of free 
  %   - existence of units 
  %   - existence of labels 
  %
  % Checking points for predict:
  %
  %   - existence of the same fields as in data
  %   - length of prediction results matches the length of data
  %
  % Input
  %
  % * speciesnms: string with species name or cell vector with multiple species names
  %  
  % Output is printed to screen as warnings
  
  %% Remarks
  % check_my_pet is a macro for check_my_pet_stnm, which checks each species one by one

  %% Example of use
  % check_my_pet('my_pet') 

if iscell(speciesnms)
  k = length(speciesnms);
  for i = 1:k
    check_my_pet_stnm(speciesnms{i});
  end
else
  check_my_pet_stnm(speciesnms);
end
    
function check_my_pet_stnm(speciesnm)

info = 0;

if ~isempty(strfind(speciesnm, ' '))
  error('   The species name in input should not have spaces.\n The standard species name follow the form ''Genus_species' );
end
  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Checking the my_data file
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%

bibNotToCheck = {'Kooy2010', 'LikaKear2011'};    % list of bib references that does not need to have an explicit reference

if exist(['mydata_', speciesnm], 'file')~=2
  error(['    There is no mydata_', speciesnm,' file']);
end

[data, auxData, metaData, txtData, weights] = feval(['mydata_', speciesnm]);

dataFields = fields(data);
auxDataTypes = fields(auxData);
txtDataFields = fields(txtData);
weightFields = fields(weights);

% checking the existence of metaData fields
metaDataFields = {'phylum', 'class', 'order', 'family', 'species', 'species_en', 'T_typical', 'data_0', 'data_1'};

for i = 1:length(metaDataFields)
  if ~isfield(metaData, metaDataFields{i})
    fprintf(['In mydata_',speciesnm,'.m: The field ', metaDataFields{i}, ' is missing in metaData. \n']);
  end
end

% checking if metaData.species matches speciesnm
if ~strcmp(speciesnm, metaData.species)
  fprintf(['In mydata_',speciesnm,'.m: The species name in metaData.species does not match the species name in the mydata file name.\n']);
end

for i = 1 : 5
    if strncmp(metaData.(metaDataFields{i}),'my_pet_', 7 ) 
         fprintf(['In mydata_',speciesnm,'.m: ', metaDataFields{i}, ' still set for my_pet example \n']);
    end  
end

    


% checking the existence of psd in the data structure
if sum(strcmp(dataFields, 'psd'))
  dataFields = dataFields(~strcmp(dataFields, 'psd'));
  psdFields = fields(data.psd);
  psdexist = 1;
else
  fprintf(['In mydata_',speciesnm,'.m: The data structure does not include the pseudodata for the regression. \n']);
  psdexist = 0;
end

% checking the existence of temp in the auxData structure
if ~sum(strcmp(auxDataTypes, 'temp'))
  error(['    In mydata_', speciesnm,'.m: The auxData structure does not include temperature data']);
end

% checking the auxData fields match data fields
for i = 1:size(auxDataTypes, 1)
  currentAuxDataType = auxDataTypes{i};
  auxDataFields = fields(auxData.(currentAuxDataType));
  for j = 1:size(auxDataFields, 1)
    if sum(strcmp(dataFields, auxDataFields(i))) == 0
      error(['    In mydata_',speciesnm,'.m: There is a ', auxDataTypes{i},' defined for ', auxDataFields{i}, ' but there is no corresponding data']);
    end    
  end
end

% checking the weights fields match data fields
if sum(strcmp(weightFields, 'psd'))
  psdWeightFields = fields(weights.psd);
  weightFields = weightFields(~strcmp(weightFields, 'psd'));
end
  
if length(weightFields) > length(dataFields)
  for i = 1:length(weightFields)
    if ~sum(strcmp(dataFields, weightFields(i)))
      fprintf(['In mydata_',speciesnm,'.m: There is a weight defined for ', weightFields{i}, ' but there is no corresponding data. \n']);
    end
  end
else
  for i = 1:length(dataFields)
    if ~sum(strcmp(dataFields(i), weightFields))
      fprintf(['In mydata_',speciesnm,'.m: There is no weight defined for data point/set ', dataFields{i}, '. \n']);
    end
  end
end

if psdexist
  if length(psdWeightFields) > length(psdFields)
    for i = 1:length(psdWeightFields)
      if ~sum(strcmp(psdFields, psdWeightFields(i)))
        fprintf(['In mydata_',speciesnm,'.m: There is a weight defined for pseudodata ', psdWeightFields{i}, ' but there is no corresponding pseudodata. \n']);
      end
    end
  else
    for i = 1:length(psdFields)
      if ~sum(strcmp(psdFields(i), psdWeightFields))
        fprintf(['In mydata_',speciesnm,'.m: There is no weight defined for pseudodata point ', psdFields{i}, '. \n']);
      end
    end
  end
end

% checking the existence of units in the txtData structure
if sum(strcmp(txtDataFields, 'units'))
  unitsFields = fields(txtData.units);
  unitsChecked = zeros(length(unitsFields), 1);   % vector to keep track of the units that have been checked
  
  % first check if all fields in data have units
  for i = 1:length(dataFields)
    if sum(strcmp(dataFields(i), unitsFields))
      unitsChecked = unitsChecked + strcmp(dataFields(i), unitsFields);
    else
      error(['   In mydata_',speciesnm,'.m: There are no units defined for data point/set ', dataFields{i}, '. \n']);
    end
  end
  
  % then check if all fields in psd have units
  if psdexist
    if sum(strcmp(unitsFields, 'psd'))
      psdUnitsFields = fields(txtData.units.psd);
      if length(psdFields) > length(psdUnitsFields)
        for i = 1:length(psdFields)
          if ~sum(strcmp(psdFields(i), psdUnitsFields))
            fprintf(['In mydata_',speciesnm,'.m: There are no units defined for pseudodata ', psdFields{i}, '. \n']);
          end
        end
      else
        for i = 1:length(psdUnitsFields)
          if ~sum(strcmp(psdFields, psdUnitsFields(i)))
            fprintf(['In mydata_',speciesnm,'.m: There are units defined for pseudodata ', psdUnitsFields{i}, ' but no corresponding value. \n']);
          end
        end
      end
      unitsChecked = unitsChecked + strcmp('psd', unitsFields); 
    else
      fprintf(['In mydata_',speciesnm,'.m: There are no units defined for pseudodata. \n'])
    end
  end
  
  % then check if all fields in auxData have units
  for i = 1:length(auxDataTypes)
    if sum(strcmp(unitsFields, auxDataTypes(i)))
      auxDataFields = fields(auxData.(currentAuxDataType));
      auxDataUnitsFields = fields(txtData.units.(currentAuxDataType));
      if length(auxDataFields) > length(auxDataUnitsFields)
        for j = 1:length(auxDataFields)
          if ~sum(strcmp(auxDataFields(j), auxDataUnitsFields))
            fprintf(['In mydata_',speciesnm,'.m: There are no units defined for auxiliary data ', auxDataFields{j}, ' of type ', auxDataTypes{i}, '. \n']);
          end
        end
      else
        for j = 1:length(auxDataUnitsFields)
          if ~sum(strcmp(auxDataFields, auxDataUnitsFields(i)))
            fprintf(['In mydata_',speciesnm,'.m: There are units defined for auxiliary data ', auxDataUnitsFields{j}, ' of type ', auxDataTypes{i}, ' but no corresponding value. \n']);
          end
        end
      end
      unitsChecked = unitsChecked + strcmp(auxDataTypes(i), unitsFields); 
    else
      fprintf(['In mydata_',speciesnm,'.m: There are no units defined for auxData type ', auxDataTypes{i},'. \n']);
    end
  end
  
  % finnaly check if there are extra unit fields without data
  extraUnits = unitsFields(unitsChecked == 0);
  if ~isempty(extraUnits)
    for i = 1:length(extraUnits)
      error(['    In mydata_',speciesnm,'.m: There are no units defined for ', extraUnits{i},' but no corresponding value(s). \n']);
    end
  end
else
  fprintf(['In mydata_',speciesnm,'.m: The txtData structure does not include the data units. \n']);
end

% checking the existence of labels in the txtData structure
if sum(strcmp(txtDataFields, 'label'))
  labelFields = fields(txtData.label);
  labelChecked = zeros(length(labelFields), 1);   % vector to keep track of the labels that have been checked
  
  % first check if all fields in data have labels
  for i = 1:length(dataFields)
    if sum(strcmp(dataFields(i), labelFields))
      labelChecked = labelChecked + strcmp(dataFields(i), labelFields);
    else
      error([' In mydata_',speciesnm,'.m: There are no labels defined for data point/set ', dataFields{i}, '. \n']);
    end
  end
  
  % then check if all fields in psd have labels
  if psdexist
    if sum(strcmp(labelFields, 'psd'))
      psdLabelFields = fields(txtData.label.psd);
      if length(psdFields) > length(psdLabelFields)
        for i = 1:length(psdFields)
          if ~sum(strcmp(psdFields(i), psdLabelFields))
            fprintf(['In mydata_',speciesnm,'.m: There are no labels defined for pseudodata ', psdFields{i}, '. \n']);
          end
        end
      else
        for i = 1:length(psdLabelFields)
          if ~sum(strcmp(psdFields, psdLabelFields(i)))
            fprintf(['In mydata_',speciesnm,'.m: There are labels defined for pseudodata ', psdLabelFields{i}, ' but no corresponding value. \n']);
          end
        end
      end
      labelChecked = labelChecked + strcmp('psd', labelFields); 
    else
      fprintf(['In mydata_',speciesnm,'.m: There are no labels defined for pseudodata. \n'])
    end
  end
  
  % then check if all fields in auxData have labels
  for i = 1:length(auxDataTypes)
    if sum(strcmp(labelFields, auxDataTypes(i)))
      auxDataFields = fields(auxData.(currentAuxDataType));
      auxDataLabelFields = fields(txtData.label.(currentAuxDataType));
      if length(auxDataFields) > length(auxDataLabelFields)
        for j = 1:length(auxDataFields)
          if ~sum(strcmp(auxDataFields(j), auxDataLabelFields))
            fprintf(['In mydata_',speciesnm,'.m: There are no labels defined for auxiliary data ', auxDataFields{j}, ' of type ', auxDataTypes{i}, '. \n']);
          end
        end
      else
        for j = 1:length(auxDataLabelFields)
          if ~sum(strcmp(auxDataFields, auxDataLabelFields(i)))
            fprintf(['In mydata_',speciesnm,'.m: There are labels defined for auxiliary data ', auxDataLabelFields{j}, ' of type ', auxDataTypes{i}, ' but no corresponding value. \n']);
          end
        end
      end
      labelChecked = labelChecked + strcmp(auxDataTypes(i), labelFields); 
    else
      fprintf(['In mydata_',speciesnm,'.m: There are no labels defined for auxData type ', auxDataTypes{i},'. \n']);
    end
  end
  
  % finnaly check if there are extra label fields without data
  extraLabel = labelFields(labelChecked == 0);
  if ~isempty(extraLabel)
    for i = 1:length(extraLabel)
      fprintf(['In mydata_',speciesnm,'.m: There are no labels defined for ', extraLabel{i},' but no corresponding value(s). \n']);
    end
  end
else
  fprintf(['In mydata_',speciesnm,'.m: The txtData structure does not include the data labels. \n']);
end

% checking the existence of facts
if isfield(metaData, 'facts')
  factsFields = fields(metaData.facts);
else
  factsFields = {};
end

if isfield(metaData, 'bibkey')
  factsBibkeys = fields(metaData.bibkey);
else
  factsBibkeys = {};
end

% checking the existence of bibkeys in the txtData structure
if sum(strcmp(txtDataFields, 'bibkey'))
  bibkeyFields = [fields(txtData.bibkey); factsBibkeys];
  referencedFields = [dataFields; factsFields];

  if length(bibkeyFields) > length(referencedFields)
    for i = 1:length(bibkeyFields)
      if sum(strcmp(referencedFields, bibkeyFields(i))) == 0
        fprintf(['In mydata_',speciesnm,'.m: There is a bibkey defined for ', bibkeyFields{i}, ' but there is no corresponding data or fact. \n']);
      end
    end
  else
    for i = 1:length(referencedFields)
      if sum(strcmp(referencedFields(i), bibkeyFields)) == 0
        fprintf(['In mydata_',speciesnm,'.m: There is no bibkey defined for data point/set or fact ', referencedFields{i}, '. \n']);
      end
    end
  end
else
  fprintf(['In mydata_',speciesnm,'.m: The txtData structure does not include the bibkeys. \n']);
end

% checking the existence of bibkeys in the biblist structure
if sum(strcmp(fields(metaData), 'biblist'))
  biblistFields = fields(metaData.biblist);
  for i = 1:length(bibNotToCheck)
      biblistFields = biblistFields(~strcmp(biblistFields, bibNotToCheck{i}));    % bibNotToCheck defined at the beginning of mydata section
  end
  bibkeyMarker = length(fields(txtData.bibkey));
  for i = 1:length(bibkeyFields)
    if i > bibkeyMarker
      bibkeynm = metaData.bibkey.(bibkeyFields{i});
    else
      bibkeynm = txtData.bibkey.(bibkeyFields{i});
    end
    if ~iscell(bibkeynm) 
      if ~sum(strcmp(biblistFields, cellstr(bibkeynm)))
        fprintf(['In mydata_',speciesnm,'.m: The bibkey ', bibkeynm, ' defined for ', bibkeyFields{i}, ' has no corresponding reference in biblist. \n']);
      end
    else
      [lin, k] = size(bibkeynm);
      if lin ~= 1 % check if for multiple references they are in a line vector
        fprintf(['In mydata_',speciesnm,'.m: The bibkey defined for ', bibkeyFields{i}, ' should be a line vector - use commas (,) to separate multiple references. \n']);
      else
        for j = 1:k
          if ~sum(strcmp(biblistFields, bibkeynm(j)))
            fprintf(['In mydata_',speciesnm,'.m: The bibkey ', bibkeynm{j}, ' defined for ', bibkeyFields{i}, ' has no corresponding reference in biblist. \n']);
          end
        end
      end
    end
  end
  
  listbibUsed = {};
  for i = 1:length(bibkeyFields)
    if i > bibkeyMarker
      bib = metaData.bibkey.(bibkeyFields{i});
    else
      bib = txtData.bibkey.(bibkeyFields{i});
    end
    if iscell(bib)
      listbibUsed = [listbibUsed, bib];
    else
      listbibUsed(length(listbibUsed) + 1) = {bib};
    end
  end
  for i = 1:length(biblistFields)
    if ~sum(strcmp(biblistFields(i), listbibUsed))
      fprintf(['In mydata_',speciesnm,'.m: The reference ', biblistFields{i}, ' in biblist is not used for any data point/set. \n']);
    end
  end
else
  fprintf(['In mydata_',speciesnm,'.m: The metaData structure does not include the biblist. \n']);
end

% checking the consistency of group setting for plotting
if isfield(metaData, 'grp')
  setsInGroups = horzcat(metaData.grp.sets{:});
  for i = 1:length(setsInGroups)
    if ~sum(strcmp(setsInGroups(i), dataFields))
      fprintf(['In mydata_',speciesnm,'.m: The data set ', setsInGroups{i}, ' in grp setting for plotting is not defined in data. \n']);
    end
  end
  
  % checking the units in a group
  %grpNumber = length(metaData.grp.sets);
  for i = 1:length(metaData.grp.sets)
    unitsOf1stSet = txtData.units.(metaData.grp.sets{i}{1});
    labelOf1stSet = txtData.label.(metaData.grp.sets{i}{1});
    for j = 2:length(metaData.grp.sets{i})
      if sum(strcmp(unitsOf1stSet, txtData.units.(metaData.grp.sets{i}{j}))) ~= 2
        fprintf(['In mydata_',speciesnm,'.m: The sets ', metaData.grp.sets{i}{1}, ' and ' metaData.grp.sets{i}{j}, ' are in the same group for plotting but have different units. \n']);
      end
      if sum(strcmp(labelOf1stSet, txtData.label.(metaData.grp.sets{i}{j}))) ~= 2
        fprintf(['In mydata_',speciesnm,'.m: The sets ', metaData.grp.sets{i}{1}, ' and ' metaData.grp.sets{i}{j}, ' are in the same group for plotting but have different labels. \n']);
      end
    end
  end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Checking the pars_init file
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if exist(['pars_init_', speciesnm], 'file')~=2
  error(['    There is no pars_init_', speciesnm,' file']);
end

[par, metaPar, txtPar] = feval(['pars_init_', speciesnm], metaData);

parFields = fields(par);
txtParTypes = fields(txtPar);

% checking the existence of metapar fields
metaParFields = {'model'};

for i = 1:length(metaParFields)
  if ~isfield(metaPar, metaParFields{i})
   error(['    In pars_init_',speciesnm,'.m: The field ', metaParFields{i}, ' is missing in metapar']);
  end
end

% checking the existence of metapar fields
EparFields = get_parfields(metaPar.model);

if isempty(EparFields)
  error(['    In pars_init_',speciesnm,'.m: The model ', metaPar.model, ' is not one of the predefined models']);
end

parFields2Check = [EparFields, 'T_A', 'f'];

% checking the existence of par fields
for i = 1:length(parFields2Check)
  if ~isfield(par, parFields2Check{i})
    error(['    In pars_init_',speciesnm,'.m: The parameter ', parFields2Check{i}, ' is missing in the par structure']);

  end
end

% checking the T_ref
if ~isfield(par, 'T_ref')
    error(['    In pars_init_',speciesnm,'.m: The parameter T_ref is missing in the par structure']);
elseif par.T_ref ~= C2K(20)
    error(['    In pars_init_',speciesnm,'.m: The parameter T_ref is not 20ºC (or 293.15K) and it should be']);
end

% checking the existence of free in the par structure and if it is filled with either 0 or 1
if sum(strcmp(parFields, 'free'))
  parFields = parFields(~strcmp(parFields, 'free'));
  freeFields = fields(par.free);

  if length(freeFields) > length(parFields)
    for i = 1:length(freeFields)
      if sum(strcmp(parFields, freeFields(i)))
        freeVal = par.free.(freeFields{i});
        if freeVal ~= 0 && freeVal ~= 1
          error(['    In pars_init_',speciesnm,'.m: The value in free for ', freeFields{i}, ' should be either 0 or 1']);
        end
      else
        fprintf(['In pars_init_',speciesnm,'.m: There is free defined for ', freeFields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(parFields)
      if sum(strcmp(parFields(i), freeFields))
        freeVal = eval(['par.free.', parFields{i}]);
        if freeVal ~= 0 && freeVal ~= 1
          error(['    In pars_init_',speciesnm,'.m: The value in free for ', parFields{i}, ' should be either 0 or 1']);
        end
      else
        error(['    In pars_init_',speciesnm,'.m: There is no free defined for data point/set ', parFields{i}]);
      end
    end
  end
else
  fprintf(['In pars_init_',speciesnm,'.m: The par structure does not include the free substructure. \n']);
end

% checking the existence of units in the txtPar structure
if sum(strcmp(txtParTypes, 'units'))
  unitsFields = fields(txtPar.units);

  if length(unitsFields) > length(parFields)
    for i = 1:length(unitsFields)
      if ~sum(strcmp(parFields, unitsFields(i)))
        fprintf(['In pars_init_',speciesnm,'.m: There are units defined for ', unitsFields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(parFields)
      if ~sum(strcmp(parFields(i), unitsFields))
        fprintf(['In pars_init_',speciesnm,'.m: There are no units defined for data point/set ', parFields{i}, '. \n']);
      end
    end
  end
else
  fprintf(['In pars_init_',speciesnm,'.m: The txtPar structure does not include the parameter units. \n']);
end

% checking the existence of labels in the txtPar structure
if sum(strcmp(txtParTypes, 'label'))
  labelFields = fields(txtPar.label);

  if length(labelFields) > length(parFields)
    for i = 1:length(labelFields)
      if sum(strcmp(parFields, labelFields(i))) == 0
        fprintf(['In pars_init_',speciesnm,'.m: There is a label defined for ', labelFields{i}, ' but there is no corresponding parameter. \n']);
      end
    end
  else
    for i = 1:length(parFields)
      if sum(strcmp(parFields(i), labelFields)) == 0
        fprintf(['In pars_init_',speciesnm,'.m: There is no label defined for data point/set ', parFields{i}, '. \n']);
      end
    end
  end
else
  fprintf(['In pars_init_',speciesnm,'.m: The txtPar structure does not include the parameter labels. \n']);
end

% checking the realism of the par set
filternm = ['filter_', metaPar.model];
[pass, flag]  = feval(filternm, par);
if ~pass 
    fprintf(['In pars_init_',speciesnm,'.m: The seed parameter set is not realistic. \n']);
    print_filterflag(flag);
    info = 1;
end

if info == 1
  fprintf('Due to the problems stated above only the my_data and pars_init files were checked. \n');
  return;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Checking the predict file
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist(['predict_', speciesnm], 'file')~=2
  error(['    There is no predict_', speciesnm,' file']);
end

[prdData, infoPrd] = feval(['predict_', speciesnm], par, data, auxData);

if infoPrd == 0 
  fprintf('The seed parameter set is not realistic (from use of info in the predict file). \n');
  return;
end

prdDataFields = fields(prdData);

% checking the existence of psd in the prdData structure
if sum(strcmp(prdDataFields, 'psd'))
  prdDataFields = prdDataFields(~strcmp(prdDataFields, 'psd'));
  prdpsdFields = fields(prdData.psd);
  prdpsdexist = 1;
else
  prdpsdexist = 0;
end

% checking for the bijection data-predictions
if length(prdDataFields) > length(dataFields)
  for i = 1:length(prdDataFields)
    if sum(strcmp(dataFields, prdDataFields(i)))
      ldt = size(data.(prdDataFields{i}), 1);       % number of data points per set
      lprdt = size(prdData.(prdDataFields{i}), 1);  % number of prdData points per set
      if ldt ~= lprdt
        error(['    In predict_',speciesnm,'.m: There is a prediction defined for ', prdDataFields{i}, ' has a length of ', num2str(lprdt), ' but the corresponding data has a length of ', num2str(ldt)]);
      end
    else 
      error(['    In predict_',speciesnm,'.m: There is no data defined for the predictions ', prdDataFields{i}]);
    end
  end
else
  for i = 1:length(dataFields)
    if sum(strcmp(dataFields(i), prdDataFields))
      ldt = size(data.(dataFields{i}), 1);       % number of data points per set
      lprdt = size(prdData.(dataFields{i}), 1);  % number of prdData points per set
      if ldt ~= lprdt
        error(['    In predict_',speciesnm,'.m: The data defined for ', dataFields{i}, ' has a length of ', num2str(ldt), ' but the corresponding prediction has a length of ', num2str(lprdt)]);
      end
    else 
      error(['   In predict_',speciesnm,'.m: There are no predictions defined for data point/set ', dataFields{i}]);
    end
  end
end

% checking for the pseudodata predictions in data (assuming each psd point has length 1)
if prdpsdexist 
  for i = 1:length(prdpsdFields)
    if ~sum(strcmp(psdFields, prdpsdFields(i)))
      error(['    In predict_',speciesnm,'.m: There is a prediction defined for psd.', prdpsdFields{i}, ' but there is no corresponding pseudodata point']);
    end
  end
end
