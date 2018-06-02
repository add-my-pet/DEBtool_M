%% setweights
% Sets automatically the weights for the data (to be used in a regression)  

%%
function weight = setweights(data, weight) 
% created 2015/01/16 by Goncalo Marques and Bas Kooijman; modified 2015/03/30, 2016/02/11, 2016/05/06 by Goncalo Marques

%% Syntax
% weight = <../setweights.m *setweights*> (data, weight)

%% Description
% computes weights for given data and adds it to the weight structure:
% for the zero-variate data y the weight will be 1,
% for the uni-variate data y the weight will be 1/N
%
% Inputs:
%
% * data : structure with data 
% * weight : structure with weights
%
% Output: 
%
% * weight : structure with added weights from data 

%% Example of use
% weight = setweights(data, [])
% computes the data weights for all data and outputs a new structure weight with the results 
% weight = setweights(data, weight)
% computes the missing data weights in structure weight and adds them to it 


nm = fieldnames(data); % vector of cells with names of data sets

for i = 1:numel(nm)
  [~, nvar] = size(data.(nm{i}));
  if ~isfield(weight, nm{i}); 
    if nvar == 1 % zero-variate data
      weight.(nm{i}) = 1; 
    else % uni-variate data
      N = length(data.(nm{i}));
      weight.(nm{i}) = ones(N, 1)/ N;
    end
  end
end
