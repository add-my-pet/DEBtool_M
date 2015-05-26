function f = fnknot_p(y, data)
  % created at 2003/03/18 by Bas Kooijman
  % subroutine for "knot_p" to find smoothing periodic spline ordinates
  global X

  f = spline_p(data(:,1),[X,y]);
end

