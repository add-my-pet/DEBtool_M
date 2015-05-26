%% check_my_pet
% Checks my_data file for field inconsistencies

%%
function check_my_pet(speciesnm)
  % created 2015/05/05 by Goncalo Marques
  
  %% Syntax 
  % <../check_my_pet.m *check_my_pet*> (speciesnm)

  %% Description
  % Checks my_data and pars_init files for field inconsistencies
  % Checking points for my_data:
  %   - existence of standard metadata fields
  %   - existence of temp
  %   - existence of pseudodata
  %   - existence of weights
  %   - existence of units (and number consistence with type of data)
  %   - existence of labels (and number consistence with type of data)
  %   - existence of bibkeys
  %               and the corresponding entrances in biblist
  % Checking points for pars_init:
  %   - existence of standard metapar fields
  %   - model is one of the predefined models
  %   - existence of free 
  %   - existence of units 
  %   - existence of labels 
  %
  % Input
  %
  % * speciesnm: string with species name
  %  


  %% Example of use
  % check_files('my_pet') 

info = 0;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Checking the my_data file
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
[data, txt_data, metadata] = feval(['mydata_', speciesnm]);

datafields = fields(data);
txtdatafields = fields(txt_data);

%% checking the existence of metadata fields
mtdtfields = {'phylum', 'class', 'order', 'family', 'species', 'species_en', 'T_typical', 'data_0', 'data_1'};

for i = 1:length(mtdtfields)
  if ~isfield(metadata, mtdtfields{i})
    fprintf(['The field ', mtdtfields{i}, ' is missing in metadata. \n']);
  end
end

%% checking the existence of temp in the data structure
if sum(strcmp(datafields, 'temp')) == 0
  fprintf('The data structure does not include temperature data. \n');
else
  datafields = datafields(~strcmp(datafields, 'temp'));
  tempfields = fields(data.temp);
  
  for i = 1:length(tempfields)
    if sum(strcmp(datafields, tempfields(i))) == 0
      fprintf(['There is a temperature defined for ', tempfields{i}, ' but there is no corresponding data. \n']);
    end
  end
end

%% checking the existence of psd in the data structure
if sum(strcmp(datafields, 'psd')) == 0
  fprintf('The data structure does not include the pseudodata for the regression. \n');
  psdexist = 0;
else
  datafields = datafields(~strcmp(datafields, 'psd'));
  psdfields = fields(data.psd);
  psdexist = 1;
end

%% checking the existence of weight in the data structure
if sum(strcmp(datafields, 'weight')) == 0
  fprintf('The data structure does not include the weights for the regression. \n');
  info = 1;
else
  datafields = datafields(~strcmp(datafields, 'weight'));
  weightfields = fields(data.weight);
  if sum(strcmp(weightfields, 'psd')) == 1
    psdweightfields = fields(data.weight.psd);
    weightfields = weightfields(~strcmp(weightfields, 'psd'));
  end
  
  if length(weightfields) > length(datafields)
    for i = 1:length(weightfields)
      if sum(strcmp(datafields, weightfields(i))) == 0
        fprintf(['There is a weight defined for ', weightfields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(datafields)
      if sum(strcmp(datafields(i), weightfields)) == 0
        fprintf(['There is no weight defined for data point/set ', datafields{i}, '. \n']);
      end
    end
  end
  
  if psdexist
    if length(psdweightfields) > length(psdfields)
      for i = 1:length(psdweightfields)
        if sum(strcmp(psdfields, psdweightfields(i))) == 0
          fprintf(['There is a weight defined for pseudodata ', psdweightfields{i}, ' but there is no corresponding pseudodata. \n']);
        end
      end
    else
      for i = 1:length(psdfields)
        if sum(strcmp(psdfields(i), psdweightfields)) == 0
          fprintf(['There is no weight defined for pseudodata point ', psdfields{i}, '. \n']);
        end
      end
    end
  end
end

%% checking the existence of units in the txt_data structure
if sum(strcmp(txtdatafields, 'units')) == 0
  fprintf('The txt_data structure does not include the data units. \n');
else
  unitsfields = fields(txt_data.units);
  if sum(strcmp(unitsfields, 'psd')) == 1
    psdunitsfields = fields(txt_data.units.psd);
    unitsfields = unitsfields(~strcmp(unitsfields, 'psd'));
  end

  if length(unitsfields) > length(datafields)
    for i = 1:length(unitsfields)
      if sum(strcmp(datafields, unitsfields(i))) == 0
        fprintf(['There are units defined for ', unitsfields{i}, ' but there is no corresponding data. \n']);
      else 
        eval(['[aux, k] = size(data.', datafields{i}, ');']);  % number of data points per set
        if eval(['ischar(txt_data.units.', datafields{i}, ');'])
          kunit = 1;
        else
          eval(['kunit = length(txt_data.units.', datafields{i}, ');']);
        end
        if k == 1 && kunit > 1
          fprintf(['There is more than one unit defined for the zerovariate data ', unitsfields{i}, '. \n']);
        elseif k > 1 && (kunit ~= 2 || kunit ~= k)
          fprintf(['There should be two (or ', num2srt(k),') units defined for the univariate data ', unitsfields{i}, '. \n']);
        end
      end
    end
  else
    for i = 1:length(datafields)
      if sum(strcmp(datafields(i), unitsfields)) == 0
        fprintf(['There are no units defined for data point/set ', datafields{i}, '. \n']);
      else 
        eval(['[aux, k] = size(data.', datafields{i}, ');']);  % number of data points per set
        if eval(['ischar(txt_data.units.', datafields{i}, ');'])
          kunit = 1;
        else
          eval(['kunit = length(txt_data.units.', datafields{i}, ');']);
        end
        if k == 1 && kunit > 1
          fprintf(['There is more than one unit defined for the zerovariate data ', unitsfields{i}, '. \n']);
        elseif k > 1 && (kunit ~= 2 || kunit ~= k)
          fprintf(['There should be two (or ', num2str(k),') units defined for the univariate data ', unitsfields{i}, '. \n']);
        end
      end
    end
  end
end
  
%% checking the existence of labels in the txt_data structure
if sum(strcmp(txtdatafields, 'label')) == 0
  fprintf('The txt_data structure does not include the data labels. \n');
else
  labelfields = fields(txt_data.label);
  if sum(strcmp(labelfields, 'psd')) == 1
    psdlabelfields = fields(txt_data.label.psd);
    labelfields = labelfields(~strcmp(labelfields, 'psd'));
  end

  if length(labelfields) > length(datafields)
    for i = 1:length(labelfields)
      if sum(strcmp(datafields, labelfields(i))) == 0
        fprintf(['There is a label defined for ', labelfields{i}, ' but there is no corresponding data. \n']);
      else 
        eval(['[aux, k] = size(data.', datafields{i}, ');']);  % number of data points per set
        if eval(['ischar(txt_data.label.', datafields{i}, ');'])
          kunit = 1;
        else
          eval(['kunit = length(txt_data.label.', datafields{i}, ');']);
        end
        if k == 1 && kunit > 1
          fprintf(['There is more than one label defined for the zerovariate data ', labelfields{i}, '. \n']);
        elseif k > 1 && (kunit ~= 2 || kunit ~= k)
          fprintf(['There should be two (or ', num2srt(k),') labels defined for the univariate data ', labelfields{i}, '. \n']);
        end
      end
    end
  else
    for i = 1:length(datafields)
      if sum(strcmp(datafields(i), labelfields)) == 0
        fprintf(['There are no labels defined for data point/set ', datafields{i}, '. \n']);
      else 
        eval(['[aux, k] = size(data.', datafields{i}, ');']);  % number of data points per set
        if eval(['ischar(txt_data.label.', datafields{i}, ');'])
          kunit = 1;
        else
          eval(['kunit = length(txt_data.label.', datafields{i}, ');']);
        end
        if k == 1 && kunit > 1
          fprintf(['There is more than one label defined for the zerovariate data ', labelfields{i}, '. \n']);
        elseif k > 1 && (kunit ~= 2 || kunit ~= k)
          fprintf(['There should be two (or ', num2str(k),') labels defined for the univariate data ', labelfields{i}, '. \n']);
        end
      end
    end
  end
end

%% checking the existence of bibkeys in the txt_data structure
if sum(strcmp(txtdatafields, 'bibkey')) == 0
  fprintf('The txt_data structure does not include the bibkeys. \n');
else
  bibkeyfields = fields(txt_data.bibkey);

  if length(bibkeyfields) > length(datafields)
    for i = 1:length(bibkeyfields)
      if sum(strcmp(datafields, bibkeyfields(i))) == 0
        fprintf(['There is a bibkey defined for ', bibkeyfields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(datafields)
      if sum(strcmp(datafields(i), bibkeyfields)) == 0
        fprintf(['There is no bibkey defined for data point/set ', datafields{i}, '. \n']);
      end
    end
  end
end

%% checking the existence of bibkeys in the biblist structure
if sum(strcmp(fields(metadata), 'biblist')) == 0
  fprintf('The metadata structure does not include the biblist. \n');
else
  biblistfields = fields(metadata.biblist);
  if length(bibkeyfields) > length(biblistfields)
    for i = 1:length(bibkeyfields)
      eval(['bibkeynm = txt_data.bibkey.', bibkeyfields{i}, ';']);
      if sum(strcmp(biblistfields, bibkeynm)) == 0
        fprintf(['The bibkey ', bibkeynm, ' defined for ', bibkeyfields{i}, ' has no corresponding reference in biblist. \n']);
      end
    end
  else
    for i = 1:length(biblistfields)
      if sum(strcmp(biblistfields(i), bibkeyfields)) == 0
        fprintf(['The reference ', bibkeynm, ' in biblist is not used for any data point/set. \n']);
      end
    end
  end
end

if info == 1
  fprintf('Due to the problems stated above only the my_data file was checked. \n');
  return;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Checking the pars_init file
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%

[par, metapar, txt_par, chem] = feval(['pars_init_', speciesnm], metadata);

parfields = fields(par);
txtparfields = fields(txt_par);

%% checking the existence of metapar fields
mtparfields = {'model', 'T_ref'};

for i = 1:length(mtparfields)
  if ~isfield(metapar, mtparfields{i})
    fprintf(['The field ', mtparfields{i}, ' is missing in metapar. \n']);
  end
end

%% checking the existence of metapar fields
possible_models = {'std', 'stf', 'stx', 'abj', 'hex'};

if sum(strcmp(metapar.model, possible_models)) == 0
  fprintf(['The model ', metapar.model, ' is not one of the predefined models. \n']);
end

%% checking the existence of par fields
Eparfields = {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hp', 'h_a', 's_G'};

for i = 1:length(Eparfields)
  if ~isfield(par, Eparfields{i})
    fprintf(['The parameter ', Eparfields{i}, ' is missing in the par structure. \n']);
  end
end

if strcmp(metapar.model, 'abj')
  if ~isfield(par, 'E_Hj')
    fprintf('The parameter E_Hj is missing in the par structure. \n');
  end
end

if strcmp(metapar.model, 'stx')
  if ~isfield(par, 'E_Hx')
    fprintf('The parameter E_Hx is missing in the par structure. \n');
  end
end

%% checking the existence of free in the par structure
if sum(strcmp(parfields, 'free')) == 0
  fprintf('The par structure does not include the free substructure. \n');
else
  parfields = parfields(~strcmp(parfields, 'free'));
  freefields = fields(par.free);

  if length(freefields) > length(parfields)
    for i = 1:length(freefields)
      if sum(strcmp(parfields, freefields(i))) == 0
        fprintf(['There are units defined for ', freefields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(parfields)
      if sum(strcmp(parfields(i), freefields)) == 0
        fprintf(['There are no units defined for data point/set ', parfields{i}, '. \n']);
      end
    end
  end
end

%% checking the existence of units in the txt_par structure
if sum(strcmp(txtparfields, 'units')) == 0
  fprintf('The txt_par structure does not include the parameter units. \n');
else
  unitsfields = fields(txt_par.units);

  if length(unitsfields) > length(parfields)
    for i = 1:length(unitsfields)
      if sum(strcmp(parfields, unitsfields(i))) == 0
        fprintf(['There are units defined for ', unitsfields{i}, ' but there is no corresponding data. \n']);
      end
    end
  else
    for i = 1:length(parfields)
      if sum(strcmp(parfields(i), unitsfields)) == 0
        fprintf(['There are no units defined for data point/set ', parfields{i}, '. \n']);
      end
    end
  end
end

%% checking the existence of labels in the txt_par structure
if sum(strcmp(txtparfields, 'label')) == 0
  fprintf('The txt_par structure does not include the parameter units. \n');
else
  labelfields = fields(txt_par.label);

  if length(labelfields) > length(parfields)
    for i = 1:length(labelfields)
      if sum(strcmp(parfields, labelfields(i))) == 0
        fprintf(['There is a label defined for ', labelfields{i}, ' but there is no corresponding parameter. \n']);
      end
    end
  else
    for i = 1:length(parfields)
      if sum(strcmp(parfields(i), labelfields)) == 0
        fprintf(['There is no label defined for data point/set ', parfields{i}, '. \n']);
      end
    end
  end
end


%% checking the existence of par fields
filternm = ['filter_', metapar.model];
[pass, flag]  = feval(filternm, par, chem);
if ~pass 
  fprintf('The seed parameter set is not realistic. \n');
  print_filterflag(flag);
  info = 1;
end

if info == 1
  fprintf('Due to the problems stated above only the my_data and pars_init files were checked. \n');
  return;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Checking the predict file
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%



