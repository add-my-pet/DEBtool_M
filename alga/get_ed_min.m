%% get_ed_min
% Obtains minimum scaled reserve density for wich division can be reached

%%
function ed = get_ed_min (p)
  % created at 2014/10/11 by Bas Kooijman
  
  %% Syntax
  % ed = <../get_ed_min.m *get_ed_min*> (p)

  %% Description
  % Obtains minimum scaled reserve density for wich division can be reached. 
  %
  % Input:
  %
  % * p: 3-vector with parameters: g, k, v_H^d 
  %  
  % Output:
  %
  % * ed: scalar with minimum scaled reserve density
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Example of use
  % get_ed_min([.5, .1, .2])
  
  % unpack pars
  g   = p(1); % -, energy investment ratio (not used)
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHd = p(3); % v_H^d = U_H^d g^2 kM^3/ (1 - kap) v^2; U_H^d = M_H^d/ {J_EAm} = E_H^d/ {p_Am}

  ed = (k * vHd)^(1/3);