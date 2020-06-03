%% prt_run_my_pet
% writes file run_my_pet.m 
%%
function prt_run_my_pet(my_pet)
% created 2020/06/02 by  Bas Kooijman

%% Syntax
% <../prt_run_my_pet.m *prt_run_my_pet*> (my_pet) 

%% Description
% Writes file run_my_pet.m in your local directory.
%
% Input:
%
% * my_pet: character string with the species name
%
% Output:
%
% * no explicit output, but writes run_my_pet.m

%% Remarks
% The file will be saved in your local directory; 
% use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% Out comment "method, no" to start running esptimation, if mydata_my_pet, pars_init_my_pet and predict_my_pet exist

fnm = ['run_', my_pet, '.m'];
fid = fopen(fnm, 'w+'); % open file for reading and writing, delete existing content

fprintf(fid, 'close all;\n');
fprintf(fid, 'global pets\n\n');

fprintf(fid, 'pets = {''%s''};\n', my_pet); 
fprintf(fid, 'check_my_pet(pets);\n\n');

fprintf(fid, 'estim_options(''default'');\n');
fprintf(fid, 'estim_options(''max_step_number'', 5e2);\n');
fprintf(fid, 'estim_options(''max_fun_evals'',5e3);\n\n');
 
fprintf(fid, 'estim_options(''pars_init_method'', 2);\n');
fprintf(fid, 'estim_options(''results_output'', 3);\n');
fprintf(fid, 'estim_options(''method'', ''no'');\n\n');
 
fprintf(fid, 'estim_pars;\n\n');
fclose(fid);







