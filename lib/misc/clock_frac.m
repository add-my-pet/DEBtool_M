%% clock_frac
% plots a stylized clock to monitor progress

%%
function clock_frac(frac, xyz, r)
  %  created at 2007/03/29 by Bas Kooijman
  
  %% Syntax
  % <../clock_frac.m *clock_frac*>(frac, yx, r)

  %% Description
  % plot a clock with a blue-filled sector to monitor progress
  %
  % Input:
  %
  % * frac: fraction of the clock with a blue sector
  % * xyz: optional 3-vector with coordinates of clock center
  % * r: optional 3-vector with the radius of the clock in 3D
  %
  % Ouput:
  %
  % * hclock: figure handle of the clock
  
  %% Remarks
  % Meant to be applied in tri-variate data to monitor progress in time.
  
  %% Example of use
  % clock_frac(0.2, [5 0.5 90], [1 0 5])

  if ~exist('xyz','var') 
    xyz = [0.5;0.5;0.5];
  end
  if ~exist('r','var') 
    r = [1 0 1];
  end

  hold on
  
  % grey circle for the contours of the clock
  th = (0:pi/50:2*pi)'; nth=length(th);
  plot3(r(1)*sin(th)+xyz(1), zeros(nth,1)+xyz(2), r(3)*cos(th)+xyz(3), 'color',[.8 .8 .8], 'LineWidth',5);

  % blue sector
  th = th(th<=frac*2*pi); nth=length(th);
  plot3(r(1)*sin(th)+xyz(1), zeros(nth,1)+xyz(2), r(3)*cos(th)+xyz(3), 'color',[0 0 1], 'LineWidth',5);


