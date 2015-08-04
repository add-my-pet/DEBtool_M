%% curator_report
% Produces a report to help curators analyse a submission

%%
function curator_report(speciesnm)
  % created 2015/08/01 by Goncalo Marques
  
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
fprintf('%s, ', metaData.data_1{1:end-1}); fprintf('%s \n', metaData.data_1{end});
fprintf('univariate data: \n');
for i = 1:length(dataFields1)
  fprintf([dataFields1{i}, ', ', txtData.label.(dataFields1{i}){1},  ' vs. ', txtData.label.(dataFields1{i}){2}, '\n']);
end

fprintf('\nCheck the consistency between metaData and data.\n');
fprintf('Check that the labels for each data type are used and consistent with the contents.\n');
fprintf('Contact the web administrator with any new labels that should be added to the table (http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/manual/index_data.html)\n');

pointNumber = pointNumber + 1;

% check data_0 and data_1
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

