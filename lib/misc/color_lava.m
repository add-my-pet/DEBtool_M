%% color_lava
% converts fractions to colors using the lava color map

%%
function color = color_lava(frac)
% created 2018/01/21 by Bas Kooijman

%% Syntax
% color = <../color_lava.m *color_lava*>(frac)

%% Description
% converts fractions to colors using the lava color map: black, blue, magenta, red, white
%
% Input:
%
% * frac: n-vector with fractions
%
% Output:
% 
% * color: (n,3)-matrix with rgb color settings

%% Example of use
% color_lava([.33; 0.81])

n = length(frac); color = zeros(n,3);
frac = max(0,frac); frac = min(1,frac);

for i=1:n
  if frac(i) < 0.25
    color(i,:) = [0, 0, 4 * frac(i)];
  elseif frac(i) < 0.5
    color(i,:) = [4 * (frac(i) - 0.25), 0, 1];
  elseif frac(i) < 0.75
    color(i,:) = [1, 0, 1 - 4 * (frac(i) - 0.5)];
  else
    color(i,:) = [1, [0 0] + 4 * (frac(i) - 0.75)];
  end
       
end

