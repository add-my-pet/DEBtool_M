%% cdPet
% cd to the DEBtool_M/lib/pet directory

function WD = cdPet
% created 2020/06/06 by Bas Kooijman

%% Syntax
% <../cdPet.m *cdPet*>

%% Description
% cd to the DEBtool_M/lib/pet directory
%
% Output
%
% * WD: current path 

%% Remarks
% Intended use: WD = cdPet; ..code.. cd(WD)

WD = pwd; path = which('cdPet'); 
if ismac
 ind = strfind(path,'/'); 
else
 ind = strfind(path,'\');
end
cd(path(1:ind(end)));
