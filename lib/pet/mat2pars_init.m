%% mat2pars_init
% writes a pars_init file from a .mat file

%%
function mat2pars_init(speciesnm)
% created 2015/09/21 by  Goncalo Marques

%% Syntax
% <../mat2pars_init.m *mat2pars_init*> (speciesnm) 

%% Description
% Makes a pars_init file from a results_'speciesnm'.mat file
%
% Input:
%
% * speciesnm: string with the species nama

%% Remarks
% Keep in mind that the files will be saved in your local directory; use
% the cd command BEFORE running this function to save files in the desired
% place.
% NOTE: This function is not yet finalised !

%% Example of use
% mat2pars_init(speciesnm)

matFile = ['results_', speciesnm, '.mat'];

% check that mydata actually exists
if exist(matFile, 'file') == 0
  fprintf([matFile, ' not found\n']);
  return
end  

load(matFile);

% open pars_init file
pars_init_id = fopen(['pars_init_', speciesnm, '.m'], 'w+'); % open file for reading and writing, delete existing content

fprintf(pars_init_id, ['%%%% pars_init_', speciesnm,'\n']);
fprintf(pars_init_id, '%% sets (initial values for) parameters\n\n');
fprintf(pars_init_id, ['function [par, metaPar, txtPar] = pars_init_', speciesnm,'(metaData)\n\n']);
fprintf(pars_init_id, ['metaPar.model = ''', metaPar.model,'''; \n\n']);

free = par.free;
par = rmfield(par, 'free');
parFields = fields(par);

for i = 1:length(parFields)
  currentPar = parFields{i};
  fprintf(pars_init_id, ['par.', currentPar,' = ', num2str(par.(currentPar)), ';  ']);
  fprintf(pars_init_id, ['free.', currentPar,' = ', num2str(free.(currentPar)), ';  ']);
  fprintf(pars_init_id, ['units.', currentPar,' = ''', txtPar.units.(currentPar), ''';  ']);
  fprintf(pars_init_id, ['label.', currentPar,' = ''', txtPar.label.(currentPar), '''; \n']);
end


fprintf(pars_init_id, '\n\n%%%% Pack output: \n');
fprintf(pars_init_id, 'txtPar.units = units; txtPar.label = label; par.free = free; \n');

fclose(pars_init_id);


