%% get_lp
% Gest scaled length at puberty

%%
function [tp, tb, lp, lb, info] = get_tp_event (p, f)
  % created at 2019/02/02 by Bas Kooijman, 
  
  %% Syntax
  % [t_p, t_b, lp, lb, info] = <../get_tp_event.m *get_lp*> (p, f)
  
  %% Description
  % Obtains scaled age and length at puberty and birth at constant food density through integration in time with event detection for std model.
  % If scaled length at birth (second input) is not specified, it is computed (using automatic initial estimate); \  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with scaled functional responses (default 1)
  %  
  % Output
  %
  % * tp: scalar with scaled age at puberty
  % * tb: scalar with scaled age at birth
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Similar to <get_tp.html> 

  %% Example of use
  % get_tp_event([.5, .1, 0, .01, .2])
  
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}

  if ~exist('f', 'var')
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end
  s_M = 1; % acceleration factor
  
  [tb, lb, info] = get_tb([g; k; vHb], f);

  options = odeset('Events', @event_puberty); 
  [t, vHl, tbp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
  lp = vHlp(2); tp = tb + tbp;
  
  if lp > f - 1e-4
    fprintf('Warning in get_tp_event: l_p very close to l_i \n')      
  end

  if k * vHp >= f * (f - lT)^2 || vHp >=  f * lp^2 * tp % constraint required for reaching puberty
    info = 0; tp = []; lp = [];    
    fprintf('Warning in get_tp_event: vHp > f * (f - lT)^2/ k or f * lp^2 * tp; puberty cannot be reached \n') 
  end



end

function [value,isterminal,direction] = event_puberty(t, vHl, k, lT, g, f, s_M, vHp)
    % vHl: 2-vector with [vH; l]
    value = vHp - vHl(1);
    isterminal = 1;
    direction = 0; 
end