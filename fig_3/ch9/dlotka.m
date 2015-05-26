function dxy = dlotka(xy) % Lotka-Volterra dynamics in chemostat
  global xr jXm Yg
  
  dxy = [xr - jXm * prod(xy) - xy(1); ...
	 Yg * jXm * prod(xy) - xy(2)];
