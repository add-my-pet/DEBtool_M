%%
%

%%
function [El1 El2 El3 ld info] = get_Eli(p, f, ld0)
  %  created at 2014/10/11 by Bas Kooijman
  
  %% Syntax
  % [El1 El2 El3 ld info] = <../get_Eli.m *get_Eli*> (p, f, ld0)

  %% Description
  % Obtains mean scaled length^i at constant food density. 
  %
  % Input:
  %
  % * p: 3-vector with parameters: g, k, v_H^d 
  % * f: optional scalar with scaled functional responses (default 1)
  % * ld0: optional scalar with scaled length at division
  %  
  % Output:
  %
  % * El1: scalar with mean scaled length
  % * El2: scalar with mean scaled squared length
  % * El3: scalar with mean scaled cubed length
  % * ld: scalar with scaled length at division
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Example of use
  % get_EL([.5, .1, .2], 1)
  
  %% Code
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHd = p(3); % v_H^d = U_H^d g^2 kM^3/ (1 - kap) v^2; U_H^d = M_H^d/ {J_EAm} = E_H^d/ {p_Am}

  if exist('f', 'var') == 0 
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end

  if exist('ld0', 'var') == 0
    ld0 = vHd^(1/3);
  elseif isempty(ld0)
    ld0 = vHd^(1/3);
  end
  
  [ld, info] = get_ld (p, f, ld0);
  
  El1 = quad(@fn_sld_1, ld/2^(1/3), ld, [], [], f, ld);
  El2 = quad(@fn_sld_2, ld/2^(1/3), ld, [], [], f, ld);
  El3 = quad(@fn_sld_3, ld/2^(1/3), ld, [], [], f, ld);
  
end

%% subfunctions
 
function fn = fn_sld_1(l, f, ld)
  lb = ld/ 2^(1/3);
  A = log((f - lb)/ (f - ld));
  fn = 1 + log((f - l)/ (f - lb))/ A;
  fn = l .* 2.^fn./ (f - l) * log(2)/ A;
end

function fn = fn_sld_2(l, f, ld)
  lb = ld/ 2^(1/3);
  A = log((f - lb)/ (f - ld));
  fn = 1 + log((f - l)/ (f - lb))/ A;
  fn = l.^2 .* 2.^fn./ (f - l) * log(2)/ A;
end

function fn = fn_sld_3(l, f, ld)
  lb = ld/ 2^(1/3);
  A = log((f - lb)/ (f - ld));
  fn = 1 + log((f - l)/ (f - lb))/ A;
  fn = l.^3 .* 2.^fn./ (f - l) * log(2)/ A;
end
