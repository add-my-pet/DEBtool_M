function dX = dgrigrowth(t, X)
  %  created 2002/02/18 by Bas Kooijman, modified 2006/10/07
  %
  %  routine called by grigrowth
  %  growth effects on growth of ectotherm: target is y_VE
  %   fast first order toxico kinetics kinetics with dilution by growth
  %     elimination not via reproduction
  %  spec growth costs linear in internal concentration
  %   abundant food, reserve and internal conc are hidden variables
  %
  %% Input
  %   t: time (not used)
  %   X: (2 * nc,1) vector with
  %      (1:nc) structural length
  %      (nc + 1:nc) time-surface (= scaled reserve)
 
  global C nc c0 cG kM v g 
  
  %  unpack state vector
  L = X(1:nc);                % length
  U = X(nc + (1:nc));         % time-surface U = M_E/{J_EAm}
 
  s = max(0,(C - c0)/ cG);    % stress function
  %  we here apply the factor (1 + s) to y_EV, or (1 + s)^-1 to y_VE so
  %  since g = v [M_V]/(\kap {J_EAm} y_VE) we have
  gs = g * (1 + s);           % stressed value for energy conductance
  %  since k_M = j_EM y_VE
  kMs = kM./ (1 + s);         % stressed value for energy conductance
  
  Lm = v ./ (kMs .* gs);       % maximum length
  es = U  * v./ L.^3;         % scaled reserve density
  eg = es .* gs ./ (es + gs); 
  SC = L.^2 .* eg .* (1 + L ./ (gs .* Lm));    % SC = J_EC/{J_AEm}

  dL = (v/ 3) .* (es - L/ Lm) ./ (es + gs);      % change in scaled length
  dU = L.^2 - SC;             % change in time-surface U = M_E/{J_EAm}

  dX = [dL; dU]; % catenate derivatives in output
