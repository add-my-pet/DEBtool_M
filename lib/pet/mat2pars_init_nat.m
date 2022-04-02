%% mat2pars_init_nat
% writes a pars_init file from a .mat file

%%
function mat2pars_init_nat
% created 202022/01/28 by Bas , modified 2022/03/15

%% Syntax
% <../mat2pars_init_nat.m *mat2pars_init_nat*> 

%% Description
% Writes a pars_init_my_pet.m file from a results_my_pet.mat file
% by copying the pars_init file and replace the parameter values.
%
% Input:
%
% * my_pet: optional string with the species name (default pets{1} for single species

%% Remarks
% Keep in mind that the files will be saved in your local directory; 
% use the cd command BEFORE running this function to save files in the desired place.

%% Example of use
% mat2pars_init_nat
  
global pets

n_pets = length(pets);
if ~exist('results_group.mat','file')
  my_pet = pets{1};
  matFile = ['results_', my_pet, '.mat'];
  if n_pets > 1
    fprintf('Warning from mat2pars_init_nat: global pets has several names, only the first is considered\n');
  end
else
  my_pet = 'group';
  matFile = 'results_group.mat';
end

% check that mydata actually exists
if exist(matFile, 'file') == 0
  fprintf([matFile, ' not found.\n']);
  return
else
  load(matFile, 'par');
end

pars_init = ['pars_init_', my_pet, '.m'];
if exist(pars_init, 'file') == 2
  prompt = [pars_init, ' already exists. Do you want to overwrite it? (y/n) '];
  overwr = lower(input(prompt, 's'));
  if ~strcmp(overwr, 'y') && ~strcmp(overwr, 'yes')
    fprintf([pars_init, ' was not overwritten.\n']);
    return
  end
end
pars_initFile = fileread(pars_init);

if contains(pars_initFile, 'addchem')
  fprintf('Warning from mat2pars_init_nat: addchem detected while model = nat\n')
  fprintf('No values copied from mat-file to pars_init\n')
  return
end

fieldsPar = fields(par); fieldsPar = fieldsPar(~strcmp(fieldsPar, 'free'));
n_fieldsPar = length(fieldsPar);

% replace parameter values
for i = 1:n_fieldsPar
  in = strfind(pars_initFile, ['par.',fieldsPar{i}, ' ']); n = strfind(pars_initFile(in(1):end), '=');
  in0 = in(1) + n(1); n = strfind(pars_initFile(in0:end), ';'); in1 = in0 + n(1) -1;
  if length(par.(fieldsPar{i})) > 1
    pars_initFile = [pars_initFile(1:in0), '[', num2str(par.(fieldsPar{i})), ']', pars_initFile(in1:end)];
  else
    pars_initFile = [pars_initFile(1:in0), num2str(par.(fieldsPar{i})), pars_initFile(in1:end)];
  end
end

% open and overwrite pars_init file
pars_initId = fopen(pars_init, 'w+'); % open file for reading and writing, delete existing content
fprintf(pars_initId, '%s', pars_initFile); fclose(pars_initId);

end
