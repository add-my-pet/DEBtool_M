function f = timeL(p,L)
  %% gut residence time is proportional to length
  f = p * L(:,1);
