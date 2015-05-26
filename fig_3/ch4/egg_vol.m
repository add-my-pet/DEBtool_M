function V = egg_vol(data)
  %% V = egg_vol(data)
  %% data: (n,6)- data matrix with o.a. length and width of egg
  %% V: (n,2)-matrix with egg-volume
  n = size(data,1);
  V = (pi/6) * data(:,4) .* data(:,5).^ 2;
  V = [V, V, ones(n,1)]; % dummy, volume, weight coeff

