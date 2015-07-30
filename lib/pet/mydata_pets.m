%% mydata_pets
% catenates mydata files for several species

%%
function [data, auxData, metaData, txtData, weights] = mydata_pets
  % created by Gonçalo Marques at 2015/01/28
  
  %% Syntax
  % [data, auxData, metaData, txtData, weights] = <../mydata_pets.m *mydata_pets*>
  
  %% Description
  % catenates mydata files for several species
  %
  % Output
  %
  % * data: catenated data structure
  % * auxData: catenated auxiliary data structure
  % * txtData: catenated text for data
  % * metaData: catenated metadata structure
  % * weights: catenated weights structure

global pets pseudodata_pets

for i = 1:length(pets)             % calls species mydata functions
  currentPet = sprintf('pet%d',i);
  [data.(currentPet), auxData.(currentPet), metaData.(currentPet), txtData.(currentPet), weights.(currentPet)] = feval(['mydata_', pets{i}]);
end 

if pseudodata_pets == 1
  %% remove pseudodata from species struture
  data = rmpseudodata(data);
  txtData = rmpseudodata(txtData); 
  weights = rmpseudodata(weights);

  %% set pseudodata and respective weights
  [dataTemp, unitsTemp, labelTemp, weightTemp] = addpseudodata([], [], [], []);
  data.psd = dataTemp.psd;
  weights.psd = weightTemp.psd;
  txtData.psd.units = unitsTemp.psd;
  txtData.psd.label = labelTemp.psd;
end
