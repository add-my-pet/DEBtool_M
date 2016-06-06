%% curator_report
% Produces a report to help curators analyse a submission

%%
function curator_report(speciesnm)
  % created 2015/08/01 by Goncalo Marques
  % modified 2015/08/06 Dina Lika
  
  %% Syntax 
  % <../curator_report.m *curator_report*> (speciesnm)

  %% Description
  % Produces a report to help curators analyse a submission.
  %
  % Follows :
  %
  %   - runs check_my_pet
  %   - displays data_0, data_1 and data fields
  %   - compares par, metaPar and txtPar in pars_init and .mat
  %
  % Input
  %
  % * speciesnm: string with species name
  %  
  % Output is printed to screen

  %% Example of use
  % curator_report('my_pet') 

info = 0;

if ~isempty(strfind(speciesnm, ' '))
  fprintf('The species name in input should not have spaces.\n');
  fprintf('The standard species name follow the form ''Genus_species''.\n');
  return;
end

pointNumber = 1;

% check_my_pet
fprintf('\n%d. Warnings from check_my_pet:\n\n', pointNumber);
check_my_pet(speciesnm);

[data, auxData, metaData, txtData, weights] = feval(['mydata_', speciesnm]);

pointNumber = pointNumber + 1;

pause

% check data_0 and data_1
fprintf('\n%d. Data types:\n\n', pointNumber);

dataFields = fields(data);
if sum(strcmp(dataFields, 'psd'))
  dataFields = dataFields(~strcmp(dataFields, 'psd'));
end

dataFields0 = {};
dataFields1 = {};
for i = 1:length(dataFields)
  if length(data.(dataFields{i})) == 1
    dataFields0{end + 1} = dataFields{i};
  else
    dataFields1{end + 1} = dataFields{i};
  end
end

fprintf('data_0: ');
fprintf('%s, ', metaData.data_0{1:end-1}); fprintf('%s \n', metaData.data_0{end});
fprintf('zero-variate data: \n');
for i = 1:length(dataFields0)
  fprintf([dataFields0{i}, ', ', txtData.label.(dataFields0{i}), '\n']);
end

fprintf('\ndata_1: ');
if isfield(metaData, 'data_1') && ~isempty(metaData.data_1)
  fprintf('%s, ', metaData.data_1{1:end-1}); fprintf('%s \n', metaData.data_1{end});
else
  fprintf('There is no data_1 vector with univariate data information.\n');
end
fprintf('univariate data: \n');
for i = 1:length(dataFields1)
  fprintf([dataFields1{i}, ', ', txtData.label.(dataFields1{i}){2},  ' vs. ', txtData.label.(dataFields1{i}){1}, '\n']);
end

fprintf('\nCheck the consistency between metaData and data.\n');
fprintf('Check that the labels for each data type are used and consistent with the contents.\n');
fprintf('Contact the web administrator with any new labels that should be added to the table (http://www.debtheory.org/wiki/index.php?title=Add-my-pet_Introduction)\n');

pause

% ---------------------------------------

pointNumber = pointNumber + 1;

% check url
mydataText = fileread(['mydata_', speciesnm, '.m']);
expression = 'url{\S*}';
urls = regexp(mydataText,expression,'match');
if isempty(urls)
  fprintf('\n%d. There are no urls in mydata to check.\n\n', pointNumber);  
else
  fprintf('\n%d. Check the following list of urls found in mydata:\n\n', pointNumber);
  for i = 1:length(urls)
    if strcmp(urls{i}(end-1),'}')
      fprintf('%s\n', urls{i}(5:end-2));
    else
      fprintf('%s\n', urls{i}(5:end-1));
    end
  end
end

pause



pointNumber = pointNumber + 1;

% compare values in pars_init with values in the .mat
fprintf('\n%d. Comparison of parameters in pars_init with .mat file:\n\n', pointNumber);

[infoPar, infoMetaPar, infoTxtPar] = matisinit(speciesnm);

if infoPar
  fprintf('The parameter values are the same in pars_init and .mat.\n');
else
  fprintf('The parameter values are different in pars_init and .mat.\n');
end

if infoMetaPar
  fprintf('The metaPar is equal in pars_init and .mat.\n');
else
  fprintf('The metaPar is different in pars_init and .mat.\n');
end

if infoTxtPar
  fprintf('The txtPar is equal in pars_init and .mat.\n');
else
  fprintf('The txtPar is different in pars_init and .mat.\n');
end

pointNumber = pointNumber + 1;

pause

% check extra parameters
fprintf('\n%d. Checking extra parameters:\n\n', pointNumber);

[par, metaPar, txtPar] = feval(['pars_init_', speciesnm], metaData);
standChem = addchem([], [], [], [], metaData.phylum, metaData.class);

parFields = fields(par);        standChemFields = fields(standChem);
parFields  = setdiff(parFields, {'free'});
nonChemParFields = setdiff(parFields, standChemFields);

EparFields = get_parfields(metaPar.model);
extraParFields = setdiff(nonChemParFields, EparFields);
extraParFields = setdiff(extraParFields, {'T_ref', 'T_A', 'f'});

fprintf('Extra parameters\n');
for i = 1:length(extraParFields)
  fprintf([extraParFields{i}, ', ', txtPar.label.(extraParFields{i}), '\n']);
end

fprintf('\nCheck if these are all used in predict.\n');
fprintf('Check if there should exist customized filters involving these parameters.\n');

pointNumber = pointNumber + 1;

pause

% check freeing of parameters
fprintf('\n%d. Checking choice of free parameters:\n\n', pointNumber);

freeFixedFields = fields(par.free);

freeFields = freeFixedFields(structfun(@(s) s==1, par.free));
fixedFields = setdiff(freeFixedFields, freeFields);

fprintf('Fixed parameters (excluding standard chemical pars with standard values)\n');
for i = 1:length(fixedFields)
  if ~ismember(fixedFields{i}, standChemFields) || par.(fixedFields{i}) ~= standChem.(fixedFields{i}) % print if is not standard chemical or if it standard but with non-standard value
    fprintf([fixedFields{i}, ' = ', num2str(par.(fixedFields{i})), ' ', txtPar.units.(fixedFields{i}), ', ' , txtPar.label.(fixedFields{i}), '\n'])
  end
end

fprintf('\nCheck if the values above are standard or have been substantiated.\n\n');

fprintf('Free parameters\n');
for i = 1:length(freeFields)
  fprintf([freeFields{i}, ' = ', num2str(par.(freeFields{i})), ' ', txtPar.units.(freeFields{i}), ', ' , txtPar.label.(freeFields{i}), '\n']);
end

fprintf('\nCheck if the values above are reasonable and if there is enough data to estimate them.\n\n');

pointNumber = pointNumber + 1;

pause; pointNumber = pointNumber + 1;

% check implied properties 
fprintf('\n%d. Check implied model properties and parameter values of my_pet. Creates my_pet.html.\n\n', pointNumber);
prnt = input('Enter: 0 to print on the screen or 1 to create my_pet.html: ');

if prnt
  if strcmp(metaPar.model,'ssj')
    print_my_pet_under_construction(metaData, metaPar, par, txtPar)
  else
    print_my_pet_html(metaData, metaPar, par, txtPar)
  end
elseif strcmp(metaPar.model,'std')
  [stat, txt_stat] = statistics_std(par, metaData.T_typical, 1, metaPar.model)
elseif strcmp(metaPar.model,'abj') || strcmp(metaPar.model,'ssj')
  [stat, txt_stat] = statistics_abj(par, metaData.T_typical, 1, metaPar.model)
end



%%
pointNumber = pointNumber + 1;

% check bibliography
fprintf('\n%d. Generate a .bib. \n Then upload bib_my_pet.bib in References ''my_pet'' project in Overleaf.\n\n', pointNumber);
 
print_bib_my_pet(metaData.species,metaData.biblist)

% save figures
% global pets
% pets = {speciesnm};
% 
% estim_options('default');
% estim_options('pars_init_method', 0);
% estim_options('results_output', 2);
% 
% load(['results_', speciesnm, '.mat']);
% clear data auxData metaData txtData weights
% [data.pet1, auxData.pet1, metaData.pet1, txtData.pet1, weights.pet1] = feval(['mydata_', speciesnm]);
% results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);

pause; pointNumber = pointNumber + 1;
% check if the parameter set was obtained after continuation from .mat 
fprintf('\n%d. Please after the curation process execute the run file with estim_option, results_output=2 \n\n', pointNumber);


pause; pointNumber = pointNumber + 1;
% check if the parameter set was obtained after continuation from .mat 
fprintf('\n%d. Check if the parameter set was obtained after continuation from .mat.\n\n', pointNumber);

fprintf('Copy results_my_pet.mat to results_my_pet_author.mat\n\n', pointNumber);

filenm1 = ['results_', speciesnm, '.mat']; 
filenm2 = ['results_', speciesnm, '_author.mat'];
copyfile(filenm1,filenm2)

fprintf('Run estimation, check if there is successful convergence:\n\n');

autoEst = input('Do you want to run estimation automatically? - if so enter 1, otherwise enter 0: ');

if autoEst
  eval(['run_', speciesnm]);

  fprintf('Restart from .mat after first convergence. Press enter:\n\n');

  pause

  eval(['run_', speciesnm]);

  [info_par, info_metaPar, info_txtPar] = matismat(speciesnm, [speciesnm, '_author']);

  if info_par
    fprintf('The parameter values were obtained after continuation from .mat file.\n');
  else
    fprintf('The parameter values were not obtained after continuation from .mat file.\n');
  end

end

% 

