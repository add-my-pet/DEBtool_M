%% mydata2predict
% writes a predict file from a mydat file

%%
function mydata2predict(speciesnm)
% created 2016/06/18 by Goncalo Marques

%% Syntax
% <../mydata2predict.m *mydata2predict*> (speciesnm) 

%% Description
% Makes a predict file from a mydata_'speciesnm' file
%
% Input:
%
% * speciesnm: string with the species name

%% Remarks
% Keep in mind that the files will be saved in your local directory; 
% use the cd command BEFORE running this function to save files in the desired place.

%% Example of use
% mydata2predict(speciesnm)

mydataFile = ['mydata_', speciesnm, '.m'];

% check that mydata actually exists
if exist(mydataFile, 'file') == 0
  fprintf([mydataFile, ' not found.\n']);
  return
end

predictFile = ['predict_', speciesnm, '.m'];

if exist(predictFile, 'file') == 2
  prompt = [predictFile, ' already exists. Do you want to overwrite it? (y/n) '];
  overwr = lower(input(prompt, 's'));
  if ~strcmp(overwr, 'y') && ~strcmp(overwr, 'yes')
    fprintf([predictFile, ' was not overwritten.\n']);
    return
  end
end

[data, auxData, metaData, txtData, weights] = feval(['mydata_', speciesnm]);

% open pars_init file
predict_id = fopen(['predict_', speciesnm, '.m'], 'w+'); % open file for reading and writing, delete existing content

fprintf(predict_id, ['%%%% predict_', speciesnm,'\n']);
fprintf(predict_id, '%% Obtains predictions, using parameters and data\n\n');
fprintf(predict_id, ['function [prdData, info] = predict_', speciesnm,'(par, data, auxData)\n\n']);
fprintf(predict_id, '  %% unpack par, data, auxData\n');
fprintf(predict_id, '  cPar = parscomp_st(par); vars_pull(par);\n');
fprintf(predict_id, '  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);\n\n');
fprintf(predict_id, '  %% area for customized filters for allowed parameters\n\n\n');

if isfield(auxData, 'temp')
  fprintf(predict_id, '  %% compute temperature correction factors\n');
  tempFields = fields(auxData.temp);
  for i = 1:length(tempFields)
    currentTemp = tempFields{i};
    fprintf(predict_id, ['  TC_', currentTemp, ' = tempcorr(temp.', currentTemp, ', T_ref, T_A);\n']);
  end
end
fprintf(predict_id, '\n\n');

dataFields = fields(data);

fprintf(predict_id, '  %% zero-variate data\n');
fprintf(predict_id, '\n\n\n\n');


fprintf(predict_id, '  %% pack to output\n');
fprintf(predict_id, '  %% the names of the fields in the structure must be the same as the data names in the mydata file\n');
for i = 1:length(dataFields)
  currentData = dataFields{i};
  if length(data.(currentData)) == 1
    fprintf(predict_id, ['  prdData.', currentData, ' = ????;\n']);
  end
end
fprintf(predict_id, '\n\n');

fprintf(predict_id, '  %% uni-variate data\n');
fprintf(predict_id, '\n\n\n\n');

fprintf(predict_id, '  %% pack to output\n');
fprintf(predict_id, '  %% the names of the fields in the structure must be the same as the data names in the mydata file\n');
for i = 1:length(dataFields)
  currentData = dataFields{i};
  if length(data.(currentData)) > 1
    fprintf(predict_id, ['  prdData.', currentData, ' = ????;\n']);
  end
end

fclose(predict_id);




