function dxy = ddeb(xy) % DEB dynamics in chemostat
  global xr jXm Yg g ld
	    
  f = xy(1)/ (1 + xy(1)); Y = Yg * (g/ f) * (f - ld)/ (f + g); 
  dxy = [xr - jXm * f * xy(2) - xy(1); ...
	 Y * jXm * f * xy(2) - xy(2)];
