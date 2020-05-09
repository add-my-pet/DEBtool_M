%% cdEBTtool
% cd to the DEBtool_M/EBTtool directory

function WD = cdEBTtool
% created 2020/04/25 by Bas Kooijman

%% Syntax
% <../cdEBTtool.m *cdEBTtool*>

%% Description
% cd to the DEBtool_M/EBTtool directory
%
% Output
%
% * WD: current path 

%% Remarks
% Intended use: WD = cdEBTtool; ..code.. cd(WD)

WD = pwd; path = which('cdEBTtool'); ind = strfind(path,'\'); cd(path(1:ind(end)));
