%% plot2i
% plot points in 2D where markers are specified of each point

%%
function [Hfig, Hleg] = plot2i(data, legend, txt)
% created 2021/06/14 by Bas Kooijman

%% Syntax
% [Hfig, Hleg] = <../plot2i.m *plot2i*> (data, legend, txt) 

%% Description
% plot data in 2D, using data-point-specific markers
%
% Input:
%
% * data: (n,2)-array with data points
% * legend: (n,2)-array with legend
% * txt: optional string with title
%
% Output:
%
% * no output

if ~exist('txt','var')
  txt = [];
end

Hfig = figure;
hold on
n = size(data,1);
for i=1:n
    marker = legend{i,1}; T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = marker{4}; MFC = marker{5};  
    plot(data(i,1), data(i,2), T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC);
end
title(txt);

if size(legend,2)>1
  h = datacursormode(Hfig);
  h.UpdateFcn = @(obj, event_obj)xylabels(obj, event_obj, legend(:,2), data);
  datacursormode on % mouse click on plot

  Hleg = shlegend(legend);
end

