function [dyl] = fndembryo(t, yl)
  %% called from embryoEVO embryoEV embryoVO
  %% since e -> infty fot t -> 0, we work with y = e*l^3
  %% since start of development is not clear, we work backwards in time
  global g

  y = yl(1); l = yl(2); A = y + g * l^3;
  if l>1e-4
    dyl = [y * l^2 * (l + g); - (y - l^4)/ 3] * g/ A; % negative changes
  else
    dyl = [0;0];
  end
