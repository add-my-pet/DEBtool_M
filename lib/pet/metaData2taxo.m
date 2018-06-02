%% metaData2taxo
% extracts phylum and class from metaData for a group 

%%
function [phylum, class] = metaData2taxo(metaData)
  % created by Bas Kooijman 2018/05/26
  
  %% Syntax
  % [phylum, class] = <../metaData2taxo.m *metaData2taxo*>(metaData)
  
  %% Description
  % extracts phylum and class from metaData for a group
  %
  % Input
  %
  % * metaData: structure with meta data for a group
  %  
  % Output
  %
  % * phylum: cell string with names of phyla for the pets
  % * class: cell string with names of classes for the pets
  
  global pets
  
  n_pets = length(pets);
  phylum = cell(n_pets,1); class = cell(n_pets,1);
  
  for i = 1:n_pets
    phylum{i} = metaData.(pets{i}).phylum;
    class{i}  = metaData.(pets{i}).class;
  end