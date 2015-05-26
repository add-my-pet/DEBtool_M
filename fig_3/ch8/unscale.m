function D = unscale(d, lx, ly, ux, uy)
  %% d: (r,2) matrix with scaled x,y numbers
  %% lx: 2-vector with scaled & unscaled lower x
  %% ly: 2-vector with scaled & unscaled lower y
  %% ux: 2-vector with scaled & unscaled upper x
  %% uy: 2-vector with scaled & unscaled upper y
  %% D: (r,2) matrix with unscaled x,y numbers
  D = d(:,[1 2]);
  D(:,1) = lx(2) + (D(:,1) - lx(1))*(ux(2) - lx(2))/(ux(1) - lx(1));
  D(:,2) = ly(2) + (D(:,2) - ly(1))*(uy(2) - ly(2))/(uy(1) - ly(1));
