%% mydata_pets
% catenates mydata files for several species

%%
function [data, txt_data, metadata] = mydata_pets
  % created by Gonçalo Marques at 2015/01/28
  
  %% Syntax
  % [data, txt_data, metadata] = <../mydata_pets.m *mydata_pets*>
  
  %% Description
  % catenates mydata files for several species
  %
  % Output
  %
  % * data: caenated data structure
  % * txt_data: catenated text for data
  % * metadata: catenated metadata file

global pets pseudodata_pets

for i = 1:length(pets)             % calls species mydata functions
  ci = num2str(i); 
  eval(['[data.pet', ci,', txt_data.pet', ci, ', metadata.pet', ci,'] = mydata_', pets{i},';']);
end 

if pseudodata_pets == 1
  %% remove pseudodata from species struture
  data = rmpseudodata(data);
  txt_data = rmpseudodata(txt_data);  

  %% set pseudodata and respective weights
  [data.psduni, units, label, weight] = addpseudodata([], [], [], []);
  data.psduni.weight = weight;
  txt_data.psduni.units = units;
  txt_data.psduni.label = label;
end
