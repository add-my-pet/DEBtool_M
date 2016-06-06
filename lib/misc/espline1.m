%% espline1
% Finds all local extremes of first order spline

%%
function [x_min, x_max, i_min, i_max] = espline1(xy, Dy1, Dyk)
  %  created at 2007/03/29 by Bas Kooijman; modified 2009/09/29

  %% Syntax
  % [x_min, x_max, i_min, i_max] <../espline1.m *espline1*>(xy, Dy1, Dyk)

  %% Description
  %  The function espline finds all local extremes of spline1. 
  %
  % Input:
  %
  % * xy: (k,2)-matrix with point coordinates; k > 2
  % * DY1: optional scalar with derivative at first point
  % * DYk: optional scalar with derivative at last point
  %
  % Output:
  %
  % * x_min: (w,2)-matrix with x-values for which y has a local minimum
  % * x_max: (v,2)-matrix with x-values for which y has a local maximum
  % * i_min: (w,1)-vector with indices of local minima
  % * i_max: (v,1)-vector with indices of local maxima
  
  %% Remarks
  % cf <../html/slpine1.html *spline1*> for first order spline;
  %    <../html/rspline1.html *rspline1*> for roots;
  %    <../html/espline1.html *espline1*> for local extremes.

  %% Example of use
  % See <../mydata_smooth.m *mydata_smooth*>

[xy i_xy] = unique(xy,'rows');
x = xy(:,1); y = xy(:,2); k = length(x);

if exist('Dy1','var') == 0
    Dy1 = 0;
end
if exist('Dyk','var') == 0
    Dyk = 0;
end

if Dy1 > 0 & y(2) < y(1)
    x_max = [x(1) y(1)];
    i_max = i_xy(1);
else
    x_max = zeros(0,2);
    i_max = [];
end
if Dy1 < 0 & y(2) > y(1)
    x_min = [x(1) y(1)];
    i_min = i_xy(1);
else
    x_min = zeros(0,2);
    i_min = [];
end

for i = 2:(k - 1)
    if (y(i - 1) < y(i)) & (y(i + 1) < y(i))
      x_max = [x_max; [x(i) y(i)]];
      i_max = [i_max; i_xy(i)];
    end
    
    if (y(i - 1) > y(i)) & (y(i + 1) > y(i))
      x_min = [x_min; [x(i) y(i)]];
      i_min = [i_min; i_xy(i)];
    end
end
if Dyk > 0 & y(k - 1) > y(k)
    x_min = [x_min; [x(k) y(i)]];
    i_min = [i_min; i_xy(k)];
end
if Dyk < 0 & y(k - 1) < y(k)
    x_max = [x_max; [x(k) y(i)]];
    i_max = [i_max; i_xy(k)];
end