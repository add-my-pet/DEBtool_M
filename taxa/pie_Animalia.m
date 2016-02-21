%% pie_Animalia
% counts number of entries in Animalia and presents a pie of it

%%
function [x taxa] = pie_Animalia
%% created 2016/02/21 by Bas Kooijman

%% Syntax
% x = <../pie_Animalia.m *pie_Animalia*> 

%% Description
% The kingdom Animalia can be partitioned into 6 taxa. 
% The number of species in the add_my_pet collection are counted for these entries and the result is presented in a pie
%
% Input:
%
% * no input
%
% Output:
% 
% * x: 6-vector containing species counts in taxa
% * taxa: 6-vector with names of taxa

%% Remarks
% sum(x) = total number of animal species in the add_my_pet collection

%% Example of use
% pie_Animalia

  taxa = {'Radiata'; 'Chaetognatha'; 'Gnathifera'; 'Platytrochozoa'; 'Ecdysozoa'; 'Deuterostomata'};
  n = length(taxa); x = zeros(n, 1);
  for i = 1:n
    x(i) = length(select(taxa{i}));
  end
  pie3(x, zeros(n, 1), taxa);
end

