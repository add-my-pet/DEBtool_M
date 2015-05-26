function f = vol(p,L)
  %% volume is proportional to cubed length
  f = p * L(:,1).^3;
