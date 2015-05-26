%% get_ue0
% gets initial scaled reserve

%%
function [uE0, lb, info] = get_ue0(p, eb, lb0)
  % created at 2007/07/27 by Bas Kooijman; modified 2010/05/02
  
  %% Syntax
  % [uE0, lb, info] = <../get_ue0.m *get_ue0*>(p, eb, lb0)
  
  %% Description
  % Obtains the initial scaled reserve given the scaled reserve density at birth. 
  % Function get_ue0 does so for eggs, get_ue0_foetus for foetuses. 
  % Specification of length at birth as third input by-passes its computation, 
  %   so if you want to specify an initial value for this quantity, you should use get_lb directly. 
  %
  % Input
  %
  % * p: 1 or 3 -vector with parameters g, k_J/ k_M, v_H^b, see get_lb
  % * eb: optional scalar with scaled reserbe density at birth 
  %   (default: eb = 1)
  % * lb0: optional scalar with scaled length at birth 
  %   (default: lb is optained from get_lb)
  %
  % Output
  %
  % * uE0: scaled with scaled reserve at t=0: $U_E^0 g^2 k_M^3/ v^2$ 
  %   with $U_E^0 = M_E^0/ \{J_{EAm}\}$
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_ue0_foetus.html *get_ue0_foetus*> for foetal development.
  % See <initial_scaled_reserve.html *initial_scaled_reserve*>, for a non-dimensionless scaling.
  
  %% Example of use
  % see <../mydata_ue0.m *mydata_ue0*>
    
  if exist('eb','var') == 0
    eb = 1; % maximum value as juvenile
  end

  if exist('lb0','var') == 0
    if length(p) < 3
      fprintf('not enough input parameters, see get_lb \n');
      uE0 = []; lb = []; info = 0;
      return;
    end
    [lb, info] = get_lb(p, eb);
  else
    lb = lb0; info = 1;
  end

  % unpack p
  g = p(1);  % energy investment ratio

  xb = g/ (eb + g);
  uE0 = (3 * g/ (3 * g * xb^(1/ 3)/ lb - beta0(0, xb)))^3;
