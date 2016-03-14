%% rotate
% rotates a 2-vector

%%
function rxy = rotate(xy,angle)
  %  created 2005/10/05 by Bas Kooijman
  
  %% Syntax
  % rxy = <../rotate.m *rotate*> (xy,angle)

  %% Description
  % Rotates a 2-vector
  %
  % Input:
  %
  % * xy: (n,2) matrix with point coordinates
  % * angle: scaler with angle of rotation
  %
  % Output:
  %
  % * rxy: (n,2) matrix with rotate point coordinates
  
  ca = cos(angle); sa = sin(angle);
  rot = [ca sa; -sa ca];
  rxy = xy * rot';
