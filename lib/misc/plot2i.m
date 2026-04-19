%% plot2i
% plot points in 2D where markers  texts are specified of each point

%%
function Hfig = plot2i(data, legend, Title, Hfig)
% created 2021/06/14 by Bas Kooijman, modified 2026/04/12

%% Syntax
% [Hfig, Hleg] = <../plot2i.m *plot2i*> (data, legend, Title) 

%% Description
% plot data in 2D, using data-point-specific markers or texts.
% For markers, the legend should specify, 'MarkerType', 'MarkerSize', 'LineWidth', 'MarkerFaceColor', 'MarkerEdgeColor'.
% For text, the legend should specify, 'String', 'FontSize' (default 10), 'FontColor' (default black).
%
% Input:
%
% * data: (n,2)-array with data points
% * legend: (n,2)-array with legend for markers or texts
% * Title: optional string with title
% * Hfig: optional figure handle
%
% Output:
%
% * no output

%% Example of use
% plot2i([1 1.2 2; 2 3.1 3]', {{'bla';'?';'str'},8*ones(3,1),ones(3,1)*[0 0 1]}, 'ref2026')

if exist('Hfig', 'var')
  figure(Hfig)
else
  Hfig = figure;
end
if ~exist('Title','var')
  Title = [];
end
hold on
n = size(data,1);
if size(legend(1,1)) > 4 % marker mode
  for i=1:n
    marker = legend{i,1}; T = marker{1}; MS = marker{2}; LW = marker{3}; MEC = marker{4}; MFC = marker{5};  
    plot(data(i,1), data(i,2), T, 'MarkerSize', MS, 'LineWidth', LW, 'MarkerFaceColor', MFC, 'MarkerEdgeColor', MEC);
  end
else % text mode
  m = size(legend,2); 
  switch m
    case 1
      str = legend; 
    case 2
      str = legend{1}; FS = legend{2}; 
    case 3
      str = legend{1}; FS = legend{2}; color = legend{3};
  end
  for i=1:n
    plot(data(i,1), data(i,2), '.w'); % necessary to show result of text
    switch m
      case 1
        if isnumeric(str(i)); stri = num2str(str(i)); else stri = str(i); end
        text(data(i,1), data(i,2), stri, 'HorizontalAlignment','center', 'VerticalAlignment','middle');
      case 2
        if isnumeric(str(i)); stri = num2str(str(i)); else stri = str(i); end
        text(data(i,1), data(i,2), stri, 'FontSize',FS(i), 'HorizontalAlignment','center', 'VerticalAlignment','middle');
      case 3
        if isnumeric(str(i)); stri = num2str(str(i)); else stri = str(i); end
        text(data(i,1), data(i,2), stri, 'FontSize',FS(i), 'Color',color(i,:), 'HorizontalAlignment','center', 'VerticalAlignment','middle');
    end
  end
end
title(Title);

if size(legend,2)>1
  h = datacursormode(Hfig);
  h.UpdateFcn = @(obj, event_obj)xylabels(obj, event_obj, legend(:,2), data);
  datacursormode on % mouse click on plot

  %Hleg = shlegend(legend);
end

