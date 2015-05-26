%% get_vHb
% Gets v_Hb for which lb = 1

%%
function vHb = get_vHb (p)
  % created 2014/01/23 by Bas Kooijman
  
  %% Syntax
  % vHb = <../get_vHb.m *get_vHb*> (p)
  
  %% Description
  % Obtains v_Hb for which lb = 1.
  %
  % Input
  %
  % * p: 2-vector with parameters: g, k
  %  
  % Output
  %
  % * vHv: scalar with scaled maturity at birth 
  %
  %% Remarks
  % The theory behind this boundary is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf *comments to DEB3*>.
  % It can be used as filter for <../get_lb.m *get_lb*>, where vHb should be less than this boundary

  %% Example of use
  %  get_vHb([1; 0.002])

  g = p(1); k = p(2); % unpack parameters
  xb = g/ (1 + g);
  alpha_b = 3 * g * xb^(1/3);
  uE0 = (3 * g / (alpha_b - beta0(0, xb)))^3;
  uEb = 1/ g;
  [uE vHl] = ode23s(@get_dvHl, [uE0; uEb], 1e-3 * [1e-20; 1], [], g, k);
  vHb = vHl(end,1);
end

% subfunction

function dvHl = get_dvHl(uE, vHl, g, k)
  % unpack states
  vH = vHl(1); % scaled maturity
  l = max(1e-10, vHl(2));  % scaled length
  
  dvH = k * vH * (uE + l^3)/ uE / l^2/ (g + l) - 1; % d/duE vH
  dl = - (g * uE - l^4)/ 3/ uE/ l^2/ (g + l);       % d/duE l
  
  % pack output
  dvHl = [dvH; dl];
end
