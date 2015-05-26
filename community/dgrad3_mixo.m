function dX = dgrad3_mixo (t, X_t)
  %% created: 2002/03/15 by Bas Kooijman, modified 2009/01/05
  %% routine called from shgrad3_mixo
  %% Differential equations for closed mixotroph system with vertical gradient

  global upmix dwnmix nL nX Lh j_L_F J_L_F; 

  j_L_F = J_L_F; # restore original light intensity

  dX = zeros(nL*nX,1); % initiate state derivatives
  %% j_L_F = j_L_F * max(0, pi * sin(2*pi*t));  % diurnic forcing, t in days
  %%   the cyclic forcing factor equals 1 on average 

  %% surface layer (no light correction)
  dX(1:nX) = dstate3_mixo(t, X_t(1:nX)) - ...  %% local change
    dwnmix .* X_t(1:nX) +  ...            %% down flux
    upmix .* X_t(nX + (1:nX));            %% up flux

  %% deeper layers
  for i = 2: (nL-1)
    j_L_F = j_L_F/ exp(1/Lh);             %% light correction
    dX((i-1)*nX + (1:nX)) = dstate3_mixo(t, X_t((i-1)*nX + (1:nX))) - ...
      (upmix + dwnmix) .* X_t((i-1)*nX + (1:nX)) +  ...
      upmix .* X_t(i*nX+(1:nX)) + dwnmix .* X_t((i-2)*nX + (1:nX));
  end

  %% bottum layer
  j_L_F = j_L_F/ exp(1/Lh);               %% light correction
  dX((nL-1)*nX + (1:nX)) = dstate3_mixo(t, X_t((nL-1)*nX + (1:nX))) - ...
    upmix .* X_t((nL-1)*nX + (1:nX)) +  ...
    dwnmix .* X_t((nL-2)*nX + (1:nX));
