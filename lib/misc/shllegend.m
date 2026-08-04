%% shllegend
% plots line legend 

%%
function Hlegend = shllegend(llegend, pos, space, txt, i_legend, file)
% created 2017/04/20 by Bas Kooijman, modified 2026/07/23

%% Syntax
% Hlegend = <../shllegend.m *shllegend*> (llegend, pos, space, txt, i_legend, file)

%% Description
% plots line legend
%
% Input:
%
% * llegend: (n,2)-cell matrix with line (3-vector of cells), label (string)
% * pos: optional 2-vector with position of lower-left corner of legend within box
% * space: optinal 2-vector with space between marker and item (horizontal) space between marker and marker (vertical)
% * txt: optional character string with title above legend figure
% * i_legend: optional integer with highlighter (from 1 till n)
% * file: optional png-file name; if given, the legend figure is saved to it and cropped (white border removed, white made transparent). The '.png' extension is optional.
%
% Output:
%
% * Hlegend: handle of figure (returned whether or not file is written, so it can still be edited)

%% Remarks
%
% * create llegend with select_llegend; press any key when done with select_llegend
% * use cropWhite to remove white border and white made transparent; shllegend does this directly

%% Example of use
% shllegend(select_llegend) or 
%   llegend = select_llegend; shllegend(llegend, [], [], 'my_legend');

if ~exist('pos', 'var') || isempty(pos)
  pos = [.7 .2];
end

if ~exist('space', 'var') || isempty(space)
  space_MT = 0.9; space_MM = 0.2;
else
  space_MT = space(1); space_MM = space(2);
end
  
n = size(llegend,1); width = 0;

for i = 1:n
  width = max(width, length(llegend{i,2}));
end

width = 1 + width * 0.5;
height = (n+1) * .45; 

Hlegend = figure('Position', [300, 400, 29 * width, 150 * height]);

plot([0 width width 0 0], [0 0 height height 0], 'w', 'LineStyle','none')
%set(gca, 'FontSize', 35, 'Box', 'off')
hold on


for i = 1:n
  line = llegend{n-i+1,1}; item = llegend(n-i+1,2);
  T = line{1}; LW = line{2}; LC = line{3};   
  plot(pos(1) + [-1 1]/2, pos(2)+ [0 0], T, 'LineWidth',LW, 'Color',LC); axis('off');
  text(space_MT + pos(1), pos(2), strrep(item, '_', '\_'), 'Interpreter', 'tex');
  if exist('i_legend', 'var') & i_legend == n-i+1
    text(pos(1) - 1.5, pos(2), '>');
  end
  pos(2) = pos(2) + space_MM;
end

if exist('txt', 'var') && ~isempty(txt)
  text(pos(1)-0.5*space_MT,pos(2),txt, 'FontSize',15, 'FontWeight','normal');
end

% optionally save the legend to a png-file, cropped and with white made transparent
if exist('file', 'var') && ~isempty(file)
  if ~endsWith(file, '.png'), file = [file, '.png']; end
  exportgraphics(Hlegend, file, 'BackgroundColor','none', 'Resolution',300)
end

