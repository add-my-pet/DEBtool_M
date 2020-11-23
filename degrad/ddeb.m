function dxy = ddeb (xy)
  global xr jXm Yg g ld
  
  %% cf Eq (9.11-12) {315}
  f = xy(1)/ (1 + xy(1)); Y = Yg * (g/ f) * (f - ld)/ (f + g); 
  dxy = [xr - jXm * f * xy(2) - xy(1); ...
	 Y * jXm * f * xy(2) - xy(2)];

