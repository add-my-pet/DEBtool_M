%% cropWhite
% removes white borders and makes white transparent in png image

%%
function  cropWhite(imgIn,imgOut,transparent)
% created 2026/03/19 by Bas Kooijman
  
%% Syntax
% <../cropWhite.m *cropWhite*> (imgIn,imgOut,transparent)
  
%% Description
% Removes white borders in png image and make white transparent in png image;
% Transparency requires program magick (with path to it); see https://imagemagick.org/script/download.php
%
% Input:
%
% * imgIn: string with name of png input image, not containing '.'
% * imgOut: optional string with name of png output image (default: imgIn)
% * transparent: optional boolean to replace white by transparent (default 1)
%
% Output:
%
% * no explicit output, but output file imgOut.png is written

%% Example of use
%
% * legend = select_legend; shlegend(legend, [], [], 'example'); 
% * shlegend(legend,[],[0.9 0.2]); saveas(gcf,'legend.png'); cropWhite('legend'); 

if contains(imgIn,'.')
  imgIn = strsplit(imgIn,'.'); imgIn = imgIn(1);
end

if ~exist('imgOut','var') || isempty(imgOut)
  imgOut = imgIn;
elseif contains(imgOut,'.')
  imgOut = strsplit(imgOut,'.'); imgOut = imgOut(1);
end
if ~exist('transparent','var') 
  transparent = 1;
end

try
    % Read the image (supports transparency)
    img = imread([imgIn, '.png']);

    % If image has an alpha channel, use it to detect content
    if size(img, 3) == 4
      alpha = img(:, :, 4) > 0; % Non-transparent pixels
      mask = alpha;
    else
      % Convert to grayscale for white detection
      grayImg = rgb2gray(img(:, :, 1:3));

      % Create mask for non-white pixels
      % White is 255 in uint8, so allow tolerance for near-white
      tolerance = 5;
      mask = grayImg < (255 - tolerance);
    end

    % Find bounding box of non-white area
    [rows, cols] = find(mask);
    if isempty(rows) || isempty(cols)
      error('Warning from cropWhite: No non-white content found in the image.');
    end
    
    rowMin = min(rows);
    rowMax = max(rows);
    colMin = min(cols);
    colMax = max(cols);

    % Crop the image
    croppedImg = img(rowMin:rowMax, colMin:colMax, :);
    
    % save
    imwrite(croppedImg, [imgOut, '.png']);
    fprintf('cropWhite: White borders removed. Saved as %s.png\n', imgOut);

    if transparent % Convert white to transparent
      try
        system(['magick mogrify -transparent white ', imgOut, '.png']);
        fprintf('cropWhite: White converted to transparent\n');
      catch
        fprintf('Warning from cropWhite: magick was not found on this computer; see https://imagemagick.org/script/download.php\n');
        fprintf('Warning from cropWhite: white not replaced by transparent\n');
      end
    end

  catch 
    fprintf('Warning from cropWhite: Error occured\n');
end
