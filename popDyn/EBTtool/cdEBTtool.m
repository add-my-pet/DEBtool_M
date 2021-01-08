%% cdEBTtool
% cd to the DEBtool_M/popDyn/EBTtool directory

function WD = cdEBTtool
% created 2020/04/25 by Bas Kooijman

%% Syntax
% <../cdEBTtool.m *cdEBTtool*>

%% Description
% cd to the DEBtool_M/popDyn/EBTtool directory
%
% Output
%
% * WD: current path 

%% Remarks
% Intended use: WD = cdEBTtool; ..code.. cd(WD)

WD = pwd; path = which('cdEBTtool'); 
if ismac
 ind = strfind(path,'/'); 
else
 ind = strfind(path,'\');
end
cd(path(1:ind(end)));
