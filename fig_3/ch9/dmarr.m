function dxy = dmarr(xy) % Marr-Pirt dynamics in chemostat
  global xr jXm Yg ld
	     
  f = xy(1)/ (1 + xy(1)); Y = Yg * (f - ld)/ f; 
  dxy = [xr - jXm * f * xy(2) - xy(1); ...
	 Y * jXm * f * xy(2) - xy(2)];
