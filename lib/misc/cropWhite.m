%% cropWhite
% removes white borders and makes white transparent in png image
%%
function cropWhite(imgIn, imgOut, transparent)
% created 2026/03/19 by Bas Kooijman
 
%% Syntax
% <../cropWhite.m *cropWhite*> (imgIn, imgOut, transparent)
 
%% Description
% Removes white borders in png image and makes white transparent in png image.
% Transparency requires program magick (with path to it); see https://imagemagick.org/script/download.php
%
% Input:
%
% * imgIn: string with name of png input image, optionally containing '.'
% * imgOut: optional string with name of png output image (default: imgIn)
% * transparent: optional boolean to replace white by transparent (default: true)
%
% Output:
%
% * no explicit output, but output file imgOut.png is written
 
%% Example of use
%
% * legend = select_legend; shlegend(legend, [], [], 'example');
% * shlegend(legend,[],[0.9 0.2]); saveas(gcf,'legend.png'); cropWhite('legend');
 
%% Strip extensions from input/output names
if contains(imgIn, '.')
  parts = strsplit(imgIn, '.'); imgIn = parts{1};
end
 
if nargin < 2 || isempty(imgOut)
  imgOut = imgIn;
elseif contains(imgOut, '.')
  parts = strsplit(imgOut, '.'); imgOut = parts{1};
end
 
if nargin < 3
  transparent = true;
end
 
%% Read and crop image
try
  img = imread([imgIn, '.png']);
 
  % Build mask of non-white pixels
  if size(img, 3) == 4
    % Use alpha channel if present
    mask = img(:, :, 4) > 0;
  else
    % Detect near-white pixels via grayscale
    tolerance = 5;
    grayImg = rgb2gray(img(:, :, 1:3));
    mask = grayImg < (255 - tolerance);
  end
 
  % Find bounding box of content
  [rows, cols] = find(mask);
  if isempty(rows) || isempty(cols)
    error('No non-white content found in the image.');
  end
 
  % Crop and save
  croppedImg = img(min(rows):max(rows), min(cols):max(cols), :);
  imwrite(croppedImg, [imgOut, '.png']);
  fprintf('cropWhite: white borders removed, saved as %s.png\n', imgOut);
 
catch ME
  fprintf('Warning from cropWhite: %s\n', ME.message);
  return
end
 
%% Optionally convert white to transparent via ImageMagick
if transparent
  [status, ~] = system(['magick mogrify -transparent white ', imgOut, '.png']);
  if status == 0
    fprintf('cropWhite: white converted to transparent\n');
  else
    fprintf(['Warning from cropWhite: magick not found or failed; ' ...
             'white not replaced by transparent.\n' ...
             'See https://imagemagick.org/script/download.php\n']);
  end
end
 
