%% res2pars_init_group
% creates results_group.mat from results_my_pet.mat-files and
% res2pars_init_group.m from results_group.mat

%%
function [par, metaData, metaPar, txtPar] = res2pars_init_group
  % created 2024/05/10 by Bas Kooijman, 
  
  %% Syntax 
  % [par, metaData, metaPar, txtPar] =  <../res2pars_init_group.m *res2pars_init_group*>(pets)
  
  %% Description
  % Assumes that global pets exists as cell string with names of species.
  % Assumes that results_my_pet.mat-files exists locally or in sister dirs 'my_pet':
  %  loads results_my_pet.mat-files to write results_group.mat for multi-species par estimation.
  %  Then uses results_group.mat to write pars_inti_group.m and load this file in the Matlab editor.
  % If mydata_my_pet.m and/or predict_my_pet.m-files do not exist locally, it tries to copy them from sister dirs 'my_pet'
  % If run_group.m file does not exist locally, it writes one and loads it in the Matlab editor.
  %
  % Input
  %
  % * pets: cell string with species names
  %  
  % Output
  %
  % * par: structure with parameters
  % * metaData: structure with phylum, class
  % * metaPar: structure with model
  % * txtPar: structure with units, label, free
  
  %% Remarks
  % requires that all results_my_pet.mat-files are locally available or in sister dirs my_pet
  %
  %% example of use
  % global pets; pets = {'Daphnia_magna','Daphnia_pulex'}; res2pars_init_group;
  
global pets

n = length(pets); metaParGrp.model = cell(1,n); parFlds = {}; EparFlds = {}; 
for i=1:n
   fnm = ['results_',pets{i},'.mat'];
   if exist(fnm,'file')
     load(['results_',pets{i}])
   else
     try
       load(['../', pets{i},'/',fnm])  
     catch
       fprintf(['warning from res2pars_init_group: ', fnm, ' not found locally or in sister-dir ', pets{i}, '\n'])
       return
     end
   end
   
   fnm = ['mydata_',pets{i},'.m'];
   if ~exist(fnm,'file')
     try
       copyfile(['../', pets{i},'/',fnm])  
     catch
       fprintf(['warning from res2pars_init_group: ', fnm, ' not found locally or in sister-dir ', pets{i}, '\n'])
     end
   end
   
   fnm = ['predict_',pets{i},'.m'];
   if ~exist(fnm,'file')
     try
       copyfile(['../', pets{i},'/',fnm])  
     catch
       fprintf(['warning from res2pars_init_group: ', fnm, ' not found locally or in sister-dir ', pets{i}, '\n'])
     end
   end
   
   fnm = 'run_group.m';
   if ~exist(fnm,'file')
     prt_run_group
   end
   
   parGrp.(pets{i}) = par; 
   parFlds = [parFlds; fields(par)];
   metaParGrp.(pets{i}).model = metaPar.model;
   metaParGrp.model{i} = metaPar.model;
   EparFlds = [EparFlds, get_parfields(metaPar.model)];
   metaDataGrp.(pets{i}) = metaData;
   flds = fields(txtPar.units);
   for j=1:length(flds); units.(flds{j}) = txtPar.units.(flds{j}); label.(flds{j}) = txtPar.label.(flds{j}); end
end
if exist('pars_init_group.m', 'file') == 2; delete('pars_init_group.m'); end
    
par = parPets2Grp(parGrp, metaData);  metaPar = metaParGrp; txtPar.units = units; txtPar.label = label; metaData = metaDataGrp;
% extra info for grp estimation
metaPar.weights.p_M = 3; metaPar.weights.v = 2; 
% separate chem pars in mat2pars_init
metaData.phylum = metaDataGrp.(pets{1}).phylum; metaData.class = metaDataGrp.(pets{1}).class;

% reduce vector to scalar specification for unique non-chem pars and T_ref
chemParFlds = fields(addchem([], [], [], [], metaData.(pets{1}).phylum, metaData.(pets{1}).class));
parFlds = setdiff(unique(parFlds), chemParFlds); parFlds = setdiff(parFlds, unique(EparFlds));
n_parFlds = length(parFlds); parOcc = zeros(n_parFlds,n);
for i=1:n
  for j=1:n_parFlds; parOcc(j,i) = isfield(parGrp.(pets{i}), parFlds{j}); end % booleans for occurence of par
end
sel =  1 == sum(parOcc,2); sel(end) = 0; parFlds = parFlds(sel); parOcc = parOcc(sel,:); n_parFlds = length(parFlds); ind = 1:n;
for j=1:n_parFlds
  in = sum(ind.*parOcc(j,:));
  par.(parFlds{j}) = par.(parFlds{j})(in); par.free.(parFlds{j}) = par.free.(parFlds{j})(in); 
end
par.T_ref = par.T_ref(1); par.free.T_ref = 0; % assumes that all T_ref's are the same

save('results_group.mat','par','metaPar','txtPar','metaData') % create results_group.mat
mat2pars_init('group') % write pars_init_group.m
edit pars_init_group.m % load pars_init_group file in editor
edit run_group.m % load run_group file in editor
end

function prt_run_group
  global pets
  
  id_run_group = fopen('run_group.m', 'w+'); % open file for reading and writing, delete existing content
  fprintf(id_run_group, 'close all\n');
  fprintf(id_run_group, 'global pets\n\n');
  
  fprintf(id_run_group, 'pets = { ...\n');
  for i=1:length(pets) 
    fprintf(id_run_group, '        ''%s'', ...\n', pets{i});    
  end
  fprintf(id_run_group, '       };\n\n');

  fprintf(id_run_group, 'estim_options(''default'')\n');
  fprintf(id_run_group, 'estim_options(''max_step_number'', 1e3)\n');
  fprintf(id_run_group, 'estim_options(''max_fun_evals'',5e3)\n\n');   

  fprintf(id_run_group, 'estim_options(''pars_init_method'', 2)\n');
  fprintf(id_run_group, 'estim_options(''results_output'',3)\n');
  fprintf(id_run_group, 'estim_options(''method'', ''no'')\n\n');

  fprintf(id_run_group, 'estim_pars\n\n'); 
  fclose(id_run_group);
end
