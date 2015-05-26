function f = fnknot(y, data)
  % created at 2002/05/26 by Bas Kooijman
  % subroutine for 'knot' to find smoothing spline ordinates
  global X DY1 DYk
  f = spline(data(:,1),[X,y],DY1, DYk);