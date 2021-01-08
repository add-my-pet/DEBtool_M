%% cdIBMnlogo
% cd to the DEBtool_M/popDyn/IBMnlogo directory

function WD = cdIBMnlogo
% created 2021/01/08 by Bas Kooijman

%% Syntax
% <../cdIBMnlogo.m *cdIBMnlogo*>

%% Description
% cd to the DEBtool_M/popDyn/IBMnlogo directory
%
% Output
%
% * WD: current path 

%% Remarks
% Intended use: WD = cdIBMnlogo; ..code.. cd(WD)

WD = pwd; path = which('cdIBMnlogo'); 
if ismac
 ind = strfind(path,'/'); 
else
 ind = strfind(path,'\');
end
cd(path(1:ind(end)));
