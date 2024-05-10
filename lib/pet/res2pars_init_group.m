%% res2pars_init_group
% creates results_group.mat from results_my_pet.mat-files and
% res2pars_init_group.m from results_group.mat

%%
function [par, metaData, metaPar, txtPar] = res2pars_init_group
  % created 2024/05/10 by Bas Kooijman, 
  
  %% Syntax 
  % [par, metaData, metaPar, txtPar] =  <../res2pars_init_group.m *res2pars_init_group*>(pets)
  
  %% Description
  % loads results_my_pet.mat-files to write results_group.mat for multi-species par estimation.
  % Then uses results_group.mat to write pars_inti_group.m and load this file in the Matlab editor.
  % Assumes that global pets exists as cell string with names of species.
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
  % requires that all results_my_pet.mat-files are locally available
  %
  %% example of use
  % global pets; pets = {'Daphnia_magna','Daphnia_pulex'}; res2pars_init_group;
  
  
% pets = {'Argopecten_purpuratus', 'Mimachlamys_varia', 'Nodipecten_subnodosus', 'Pecten_maximus', 'Placopecten_magellanicus'};

global pets

n = length(pets); metaParGrp.model = cell(1,n); units = {}; label = {};
for i=1:n
   load(['results_',pets{i}])
   parGrp.(pets{i}) = par; 
   metaParGrp.model{i} = metaPar.model;
   metaDataGrp.(pets{i}) = metaData;
   flds = fields(txtPar.units); m = length(flds);
   for j=1:m; units.(flds{j}) = txtPar.units.(flds{j}); label.(flds{j}) = txtPar.label.(flds{j}); end
end
if exist('pars_init_group.m','file') == 2; delete('pars_init_group.m'); end
    
parGrp = parPets2Grp(parGrp, metaData);
par = parGrp; metaPar = metaParGrp; txtPar.units = units; txtPar.label = label; metaData = metaDataGrp;

save('results_group.mat','par','metaPar','txtPar','metaData') % create results_group.mat
mat2pars_init('group') % create pars_init_group.m
edit pars_init_group.m

