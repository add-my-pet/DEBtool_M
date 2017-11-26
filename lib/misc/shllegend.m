%% shllegend
% plots line legend 

%%
function Hlegend = shllegend(llegend, pos, space, txt, i_legend)
% created 2017/04/20 by Bas Kooijman

%% Syntax
% Hlegend = <../shllegend.m *shllegend*> (llegend, pos, space, txt, i_legend)

%% Description
% plots line legend
%
% Input:
%
% * llegend: (n,2)-cell matrix with with line (3-vector of cells), item (string)
% * pos: optional 2-vector with position of lower-left corner of legend within box
% * space: optinal 2-vector with space between marker and item (horizontal) space between marker and marker (vertical)
% * txt: optional character string with title above legend figure
% * i_legend: optional integer with highlighter (from 1 till n)
%
% Output: 
% 
% * Hlegend: handle of figure

%% Remarks
% create llegend with select_llegend; press any key when done with select_llegend

%% Example of use
% shllegend(select_llegend) or 
%   llegend = select_llegend; shllegend(llegend, [], [], 'example');

if ~exist('pos', 'var') || isempty(pos)
  pos = [.7 .2];
end

if ~exist('space', 'var') || isempty(space)
  space_MT = 0.9; space_MM = 0.45;
else
  space_MT = space(1); space_MM = space(2);
end
  
n = size(llegend,1); width = 0;

for i = 1:n
  width = max(width, length(llegend{i,2}));
end

width = 1 + width * 0.5;
height = n * .45; 

Hlegend = figure('Position', [300, 400, 29 * width, 150 * height]);

plot([0 width width 0 0], [0 0 height height 0], 'w', 'LineStyle', 'none')
%set(gca, 'FontSize', 35, 'Box', 'off')
hold on

for i = 1:n
  line = llegend{n-i+1,1}; item = llegend(n-i+1,2);
  T = line{1}; LW = line{2}; LC = line{3};   
  plot(pos(1) + [-1 1]/2, pos(2)+ [0 0], T, 'LineWidth', LW, 'Color', LC); axis('off');
  text(space_MT + pos(1), pos(2), strrep(item, '_', '\_'), 'Interpreter', 'tex');
  if exist('i_legend', 'var') && i_legend == n-i+1
    text(pos(1) - 1.5, pos(2), '>');
  end
  pos(2) = pos(2) + space_MM;
end

if exist('txt', 'var') && ~isempty(txt)
  title(txt);
end

