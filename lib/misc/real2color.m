%% real2color
% gets RGB colours for a vector of reals using lava colour coding

%%
function [RGB range] = real2color(x, r)
  % created at 2016/10/19 by Bas Kooijman
  
  %% Syntax
  % [RGB range] = <../real2color.m *real2color*>(x, r)
  
  %% Description
  % Obtains RBG colors from reals using lava-colour coding (black, blue, magenta, red, white)
  % The smallest value gets black, the largest almost white.
  %
  % Input
  %
  % * x: n-vector real number
  % * r: optional scalar with range factor > 1 (default 1.1) 
  %
  % Output
  %
  % * (n,3)-matrix with RGB colours
  % * range: 2-vector with x-values that correspond with black and white
  
  %% Remarks
  % For r = 1, the largest value of x gets white.
  % Uses linear interpolation between colours
  
  %% Example of use
  % RGB = real2color(1:10);
  
  if ~exist('r', 'var')
    r = 1.1;
  elseif r<=1
    fprintf('Warning from real2colour: invalid range factor\n');
    RGB = zeros(0,3); range = zeros(0,2); return
  end
  
  map = [ ... % lava colour coding
    0 0 0
    0 0 1
    1 0 1
    1 0 0
    1 1 1];
  n_map = size(map,1);

  x_min = min(x); x_max = max(x); range = [x_min, r * x_max];
  x = 1 + (n_map - 1) * (x - x_min)/ (x_max - x_min)/ r; % scale input
  n = length(x); RGB = zeros(n,3); % prepare loop

  for i = 1:n % loop across input values
    j = floor(x(i)); w = x(i) - j;
    RGB(i,:) = (1 - w) * map(j,:) + w * map(j+1,:);
  end
