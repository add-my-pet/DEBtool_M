%% mydata_pets
% catenates mydata files for several species

%%
function [data, auxData, metaData, txtData, weights] = mydata_pets
  % created by Goncalo Marques at 2015/01/28
  
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

global pets toxs pseudodata_pets

for i = 1:length(pets)             % calls species mydata functions
  currentPet = pets{i};
  toxsnumber = length(toxs);
  if toxsnumber == 0
    [data.(currentPet), auxData.(currentPet), metaData.(currentPet), txtData.(currentPet), weights.(currentPet)] = feval(['mydata_', pets{i}]);
  else
    for j = 1:toxsnumber
      currentTox = toxs{j};
      [data.(currentPet).(currentTox), auxData.(currentPet).(currentTox), metaData.(currentPet).(currentTox), txtData.(currentPet).(currentTox), weights.(currentPet).(currentTox)] = feval(['mydata_', currentPet, '_', currentTox]);
    end
  end
end 

if pseudodata_pets == 1 % same pseudodata for the group
  % remove pseudodata from species structure
  data = rmpseudodata(data);
  txtData = rmpseudodata(txtData); 
  weights = rmpseudodata(weights);

  % set pseudodata and respective weights for the group
  if exist('addpseudodata_group.m', 'file')
      [dataG, unitsG, labelG, weightsG] = addpseudodata_group;
  else
      [dataG, unitsG, labelG, weightsG] = addpseudodata([], [], [], []);
      fprintf('No addpseudodata_group.m found, only default pseudodata and weights are considered for the group \n')
      
  end
  data.psd = dataG.psd;
  weights.psd = weightsG.psd;
  txtData.psd.units = unitsG.psd;
  txtData.psd.label = labelG.psd;
end
