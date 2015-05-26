%% get_ue0_foetus
% gets initial scaled reserve for foetus

%%
function [uE0, lb, tb, info] = get_ue0_foetus(p, eb, lb0)
  % created at 2007/09/03 by Bas Kooijman, modified 2010/09/09
  
  %% Syntax
  % [uE0, lb, tb, info] = <../get_ue0_foetus.m *get_ue0_foetus*>(p, eb, lb0)
  
  %% Description
  % Obtains initial scaled reserve, length, age at birth for foetus, 
  % i.e. the total scaled investment till birth.
  %
  % Input
  %
  % * p: 1- or 3-vector with parameters g, k, v_H^b
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb0: optional scalar with scaled length at birth.
  %     Default: lb is obtained from get_lb
  %
  % Output
  %
  % * uE0: scalar with scaled reserve at t=0: U_E^0 g^2 k_M^3/ v^2 
  %   with U_E^0 = M_E^0/ {J_EAm}
  % * lb: scalar with scaled length at birth
  % * tb: scalar with scaled age at birth
  % * info: scalar with failure (0) or success (1) of convergence
  
  %% Remarks
  % See <get_ue0.html *get_ue0*> for egg development
  % See <initial_scaled_reserve_foetus.html *initial_scaled_reserve_foetus*>, for a non-dimensionless scaling.

  
  %% Example of use
  % see <../mydata_ue0_foetus.m *mydata_ue0_foetus*>

  % unpack p
  g = p(1);  % energy investment ratio

  if exist('eb','var') == 0
    eb = 1; % maximum value as juvenile
  end

  if exist('lb0','var') == 0
    if length(p) < 3
      fprintf('warning in get_ue0_foetus: not enough input parameters, see get_lb_foetus \n');
      uE0 = []; lb = []; info = 0;
      return;
    end
    [lb, tb, info] = get_lb_foetus(p);
  else
    lb = lb0; tb = 3 * lb/ g; info = 1;
  end

  uEb = eb * lb^3/ g;
  uE0 = uEb + lb^3 + 3 * lb^4/ 4/ g;
