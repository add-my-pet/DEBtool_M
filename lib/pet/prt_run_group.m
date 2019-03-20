%% prt_run_group
% writes file run_group.m for multi-species estimation 

%%
function prt_run_group(petsGrp)
% created 2019/03/20 by  Bas Kooijman

%% Syntax
% <../prt_run_group.m *prt_run_group*> (petsGrp) 

%% Description
% Writes file run_group.m as subfunction of pars_init2mat, since the
% sequence of in vector-valued parameters in pars_init_group depends on the sequence specified in run_group
%
% Input:
%
% * petsGrp: cell string with the species names

if exist('run_group.m', 'file') == 2
  prompt = 'run_group already exists. Do you want to overwrite it? (y/n)';
  overwr = lower(input(prompt, 's'));
  if ~strcmp(overwr, 'y') && ~strcmp(overwr, 'yes')
    fprintf('run_group was not overwritten, but the pars_init_group file assumes pet sequence.\n');
    petsGrp    
    return
  end
end

fid = fopen('run_group.m', 'w+'); % open file for reading and writing, delete existing content

fprintf(fid, 'close all;\n');
fprintf(fid, 'global pets\n\n');

fprintf(fid, 'pets = { ...\n'); n_pets = length(petsGrp);
for i = 1:n_pets
fprintf(fid,['         ''', petsGrp{i}, ''', ...\n']); 
end
fprintf(fid, '       };\n\n'); 

fprintf(fid, 'estim_options(''default'');\n');
fprintf(fid, 'estim_options(''max_step_number'', 1e3);\n');
fprintf(fid, 'estim_options(''max_fun_evals'',5e3);\n\n');
 
fprintf(fid, 'estim_options(''pars_init_method'', 2);\n');
fprintf(fid, 'estim_options(''results_output'', 3);\n');
fprintf(fid, 'estim_options(''method'', ''no'');\n\n');
 
fprintf(fid, 'estim_pars;\n\n');
fclose(fid);







