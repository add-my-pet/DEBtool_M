%% shcolor_lava
% shows color strip with values

%%
function Hcol = shcolor_lava(range, txt)
% created 2018/01/21 by Bas Kooijman

%% Syntax
% Hfig = <../shcolor_lava.m *shcolor_lava*>(range, txt)

%% Description
% shows vertical color strip with values
%
% Input:
%
% * range: optional 2-vector with lower and upper boundaries (default [0 1])
% * txt: optional character string with title above color code figure
%
% Output:
%
% * Hfig: handle of figure for color coding

%% Example
% shcolor_lava

if ~exist('range', 'var') || isempty(range)
  range = [0 1];
end

Hcol = figure('Position', [200, 200, 75, 900]);
hold on

plot([0 .5 .5 0 0], [0 0 1.1 1.1 0], 'w', 'LineStyle', 'none')

  x = 0;
for i = 1:100 % color strip
  plot(x + [0; 0], [i - 1; i]/ 100, 'Linewidth', 20, 'Color', color_lava((i-1)/100))
end
  
  % tick = [.1 .5]; x = .3;
  %plot (tick, [0.00 0.00], 'LineWidth', 2, 'Color', [0 0 0]); 
    text(0, 0.00, num2str(range(1)));
  %plot (tick, [0.25 0.25], 'LineWidth', 2, 'Color', [0 0 0]); 
    text(0, 0.25, num2str(range(1) + 0.25 * (range(2) - range(1))));
  %plot (tick, [0.50 0.50], 'LineWidth', 2, 'Color', [0 0 0]); 
    text(0, 0.50, num2str(range(1) + 0.50 * (range(2) - range(1))));
  %plot (tick, [0.75 0.75], 'LineWidth', 2, 'Color', [0 0 0]); 
    text(0, 0.75, num2str(range(1) + 0.75 * (range(2) - range(1))));
  %plot (tick, [1.00 1.00], 'LineWidth', 2, 'Color', [0 0 0]); 
    text(0, 1.00, num2str(range(2)));
 
axis('off');

if exist('txt', 'var') && ~isempty(txt)
  title(txt);
end


