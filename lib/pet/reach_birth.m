%% reach_birth
% checks if parameters allow for reaching birth in the standard DEB model

%%
function info = reach_birth(g, k, v_Hb, f)
% created 2015/06/19 by Goncalo Marques; modified 2015/07/06
  
%% Syntax
% info = <../reach_birth.m *reach_birth*>(g, k, v_Hb, f)
  
%% Description
% Checks if parameters allow for reaching birth in the standard DEB model
%
% Input
%
% * g: energy investment ratio
% * k: ratio of maturity and somatic maintenance rate coeff
% * v_Hb: scaled maturity volume at birth
% * f: (opfional) functional response
%  
% Output
%
% * info: indicator equals 1 if reaches birth, 0 otherwise
  
  if ~exist('f', 'var') % if f is not given it is taken as 1
    f = 1;
  elseif isempty(f)
    f = 1;
  end  
  
  p = [g, k, v_Hb];
  [l_b, info] = get_lb(p, f);
  
  if l_b >= f || ~info % constraint required for reaching birth
    info = 0;    
    return;
  end
    
  if k * v_Hb >= f/ (g + f) * l_b^2 * (g + l_b) % constraint required for reaching birth
    info = 0;    
    return;
  end
  
  info = 1;
