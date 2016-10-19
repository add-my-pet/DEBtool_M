%% plotscatter
% creates a scatter plot

%%
function Hfig = plotscatter(xy, M)
  % created at 2016/10/19 by Bas Kooijman
  
  %% Syntax
  % Hfig = <../plotscatter.m *plotscatter*>(x, y, M)
  
  %% Description
  % Creates scatter plot that allows setting of MarkerType, MarkerSize and Color
  %
  % Input
  %
  % * xy: (n,2)-matrix with x,y-values
  % * M:  (n,1)-array of 5-cells with marker specs: MarkerType; MarkerSize; LineWidth; MarkerEdgeColor; MarkerFaceColor
  %
  % Output
  %
  % * Hfig: scalar with figure handle
  
  %% Remarks
  % See <select_marker.html *select_marker*> for marker specs.
  % Differs from scatter.m by allowing for setting each marker separately
  
  %% Example of use
  % see <../mydata_plotscatter.m *mydata_plotscatter*>
    
 hold on
 n = size(xy,1);
 for i = 1:n
   m = M{i};
   Hfig = plot(xy(i,1), xy(i,2), m{1}, ...
     'MarkerSize', m{2}, 'LineWidth', m{3} , ...
     'MarkerEdgeColor', m{4}, 'MarkerFaceColor', m{5});
 end