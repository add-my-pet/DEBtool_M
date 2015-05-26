%% l2f
% Gets scaled functional response f given scaled age t and scaled length l

%%
function [f info] = l2f(p,tl,f0)
  % created at 2011/01/01 by Bas Kooijman
  
  %% Syntax
  % [f info] = <../l2f.m *l2f*> (p,tl,f0)
  
  %% Description
  % Calculates f given scaled age t and scaled length l at 2 scaled times
  %
  % Input
  %
  % * p  : scalar with g (energy investment ratio)
  % * tl : (2,2)-matrix with scaled age t = a * k_M and scaled length l = L/ L_m
  % * f0 : initial estimate for scaled functional response f 
  %
  % Output
  %
  % * f : scaled funct. response
  % * info : scalar with 1 fro success, 0 otherwise
  
  %% Example of use
  % l2f([1;1;0;1e-3], [2, .3; 4, .6])

  global g dt l0 ln

  % unpack parameters p
  g  = p(1);                   % energy investment ratio
  dt = abs(tl(2,1) - tl(1,1)); % growth period in scaled time
  l0 = min(tl(:,2));           % smallest scaled length
  ln = max(tl(:,2));           % lagest scaled length

  if exist('f0', 'var') == 0 % get initial estimate for f
    f0 = 0.5 * (1 + ln);
  end

  [f , flag, info] = fzero('fnl2f', f0);
  %[f info] = nmregr('fnl2f',f0, [0 0]);
