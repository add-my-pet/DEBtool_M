%% shapecorr
% Calculates the shape correction factor

%%
function M = shapecorr(L, L_ref, Mpars)
  
  %% Description
  % Calculates the shape correction factor with which quantities with dimension `per surface area' should be multiplied 
  %  to account for change in shape. 
  % Shape correction function M = 1 for L = L_ref
  %
  % Input:
  %
  % * L: n-vector of lengths
  % * L_ref: value of L for which M = 1
  % * Mpars: vector with parameters
  %
  %     - Lj: Length at metamorphosis
  %     - x: optional morph parameter for power of (L/Lref), default 1
  %
  % Output:
  %
  % * M: n-vector with shape correction function
  
  %% Example of use
  % shapecorr([.9; 1; 1.5], .8, [2.5; 1.5]). 

  L_j = Mpars(1);
  if length(M) == 1
    x = 1;
  else
    x = Mpars(2);
  end

  M = (max(L_ref, min(L_j, L)) ./ L_ref) .^ x;