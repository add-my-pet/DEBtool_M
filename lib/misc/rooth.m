%% rooth
% root based on hermite interpolation

%%
function [g info] = rooth (h,u,y0,f0,y1,f1)
  % created at 2002/05/22 by Bas Kooijman
  
  %% Syntax
  % [g info] = <../rooth.m *rooth*> (h,u,y0,f0,y1,f1)

  %% Description
  % Root based on hermite interpolation
  %
  % Input:
  %
  % * h: scalar, length of interval for x in (0,h)
  % * u: scalar, value for y(x), typically y0<u<y1 or y1>u>y0
  % * y0: scalar, y0 = y(0)
  % * f0: scalar, f0 = d/dx y(0)
  % * y1: scalar, y1 = y(h)
  % * f1: scalar, f1 = d/dx y(h)
  %
  % Output:
  %
  % * g: scalar, g = y(h) and typically 0 < g < h
  
  %% Example of use
  % rooth(1,2,1.5,1,2.5,1).

  % routine test: this should generate the input values
  % [h+0,\
  % c(1)*g^3 + c(2)*g^2 + c(3)*g + c(4) + u,\
  % u+c(4),\
  % c(3),\
  % u+c(1)*h^3 + c(2)*h^2 + c(3)*h + c(4),\
  % 3*c(1)*h^2 + 2*c(2)*h + c(3)]
  
  c = [(f1 + f0)/ h^2 - 2 * (y1 - y0)/ h^3;
       3 * (y1 - y0)/ h^2 - (f1 + 2 * f0)/ h ;
       f0; y0 - u];
  g = roots3(c,1);
   
  if 1 < length(g)
    g = g(1); info = 2;
  end
  if length(g) == 1
    info = 1;
  else
    info = 0;
  end


