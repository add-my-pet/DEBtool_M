%% mat2pars_init
% writes a pars_init file from a .mat file

%%
function mat2pars_init(speciesnm, varargin)
% created 2015/09/21 by  Goncalo Marques, modified 2016/02/17, 2016/06/18
% modified 2017/07/19 by Bas Kooijman

%% Syntax
% <../mat2pars_init.m *mat2pars_init*> (speciesnm) 

%% Description
% Makes a pars_init file from a results_'speciesnm'.mat file
%
% Input:
%
% * speciesnm: optional string with the species name (default pets{1})
% * varargin: 1 to fix all parameters, empty or otherwise to use free/fix information from .mat file

%% Remarks
% Keep in mind that the files will be saved in your local directory; 
% use the cd command BEFORE running this function to save files in the desired place.

%% Example of use
% mat2pars_init(speciesnm)

global pets

if ~exist('speciesnm','var')
  speciesnm = pets{1}; 
  fix = 0;
elseif nargin > 2
  error('Too many inputs in mat2pars_init');
elseif isempty(varargin) || varargin{1} ~= 1
  fix = 0;  % free/fix parameters as in .mat file
else
  fix = 1;  % all parameters fixed 
end

matFile = ['results_', speciesnm, '.mat'];

% check that mydata actually exists
if exist(matFile, 'file') == 0
  fprintf([matFile, ' not found.\n']);
  return
end

pars_initFile = ['pars_init_', speciesnm, '.m'];

if exist(pars_initFile, 'file') == 2
  prompt = [pars_initFile, ' already exists. Do you want to overwrite it? (y/n) '];
  overwr = lower(input(prompt, 's'));
  if ~strcmp(overwr, 'y') && ~strcmp(overwr, 'yes')
    fprintf([pars_initFile, ' was not overwritten.\n']);
    return
  end
end

load(matFile);

% open pars_init file
pars_init_id = fopen(['pars_init_', speciesnm, '.m'], 'w+'); % open file for reading and writing, delete existing content

fprintf(pars_init_id, ['function [par, metaPar, txtPar] = pars_init_', speciesnm,'(metaData)\n\n']);
fprintf(pars_init_id, ['metaPar.model = ''', metaPar.model,'''; \n\n']);

free = par.free;
par = rmfield(par, 'free');
parFields = fields(par);

% checking the existence of metapar fields
EparFields = get_parfields(metaPar.model);

fprintf(pars_init_id, '%%%% reference parameter (not to be changed) \n');

currentPar = 'T_ref';
write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar), 1);

parFields = setdiff(parFields, {currentPar});

fprintf(pars_init_id, '\n%%%% core primary parameters \n');

for i = 1:length(EparFields)
  currentPar = EparFields{i};
  if isfield(par,currentPar)
  write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar), fix);
  end
end 

fprintf(pars_init_id, '\n%%%% other parameters \n');

parFields = setdiff(parFields, EparFields);

% separate chemical parameters from other
par_auto = addchem([], [], [], [], metaData.phylum, metaData.class);
chemParFields = fields(par_auto);
otherParFields = setdiff(parFields, chemParFields);

for i = 1:length(otherParFields)
  currentPar = otherParFields{i};
  write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar), fix);
end

fprintf(pars_init_id, '\n%%%% set chemical parameters from Kooy2010 \n');
fprintf(pars_init_id, '[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class);');

for i = 1:length(chemParFields)
  currentPar = chemParFields{i};
  if par.(currentPar) ~= par_auto.(currentPar)
    write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar), fix);
  end
end

fprintf(pars_init_id, '\n\n%%%% Pack output: \n');
fprintf(pars_init_id, 'txtPar.units = units; txtPar.label = label; par.free = free; \n');

fclose(pars_init_id);


function write_par_line(file_id, parName, parValue, freeValue, unitsString, labelString, fix)

  if ~isempty(strfind(parName,'E_H'))
    fprintf(file_id, ['par.', parName,' = %1.3e; '], parValue);
  elseif ~isempty(strfind(parName,'h_a'))
    fprintf(file_id, ['par.', parName,' = %1.3e;  '], parValue);
  else    
    fprintf(file_id, '%-*s', 22, ['par.', parName,' = ', num2str(parValue), ';  ']);
  end
  fprintf(file_id, '%-*s', 10, ['free.', parName]);
  if fix
    fprintf(file_id, ' = 0;   ');
  else
    fprintf(file_id, [' = ', num2str(freeValue), ';   ']);
  end
  fprintf(file_id, '%-*s', 26, ['units.', parName,' = ''', unitsString, ''';  ']);
  fprintf(file_id, ['label.', parName,' = ''', labelString, '''; \n']);


