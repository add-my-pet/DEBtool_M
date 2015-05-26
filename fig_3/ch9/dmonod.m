function dxy = dmonod(xy) % Monod dynamics in chemostat
  global xr jXm Yg
  
  f = xy(1)/ (1 + xy(1)); 
  dxy = [xr - jXm * f * xy(2) - xy(1); ...
	 Yg * jXm * f * xy(2) - xy(2)];
