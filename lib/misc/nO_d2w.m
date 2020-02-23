%% nO_d2w
% Gets chemical coefficient of wet from dry mass

%%
function n_O = nO_d2w(n_O, d)
  % created 2020/02/17 by Bas Kooijman
  
  %% Syntax
  % n_O = <../nO_d2w.m *nO_d2w*>(n_O, d)
  
  %% Description
  % Obtains chemical coefficient of wet from dry mass: 
  %
  % Input
  %
  % * n_O: (4,n)-array with chemical coefficients of dry mass
  % * d: n-vector with specific densities, corresponding with cols of n_O
  % 
  % Output
  %
  % * n_O: (4,n)-array with chemical coefficients of wet mass
  

  x = (1 - d)/ 18;
  n_O(2,:) = n_O(2,:) + 2 * x;
  n_O(3,:) = n_O(3,:) + x;