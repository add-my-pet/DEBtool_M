%% res_time
% Gets reserve residence times as function of length

%%
function tE  = res_time(l, f, p)
  %  created 2009/01/15 by Bas Kooijman
  
  %% Syntax
  % tE  = res_time(l, f, p)
  
  %% Description
  % Obtains the mean residence times of molecules in the reserve at scaled functional responses f = 1, 0.8, 0.6, .. 
  %    as functions of scaled lengths: 
  % E/pC, where pC is the mobilisation power. 
  % Applies to juvenile and adult stages.
  %
  % Input
  %
  % * l: n-vector with scaled length
  % * f: scalar with functional response
  % * p: 3-vector with parameters: kM g lT
  %
  % Output
  %
  % * tE: n-vector with residence times of reserve "molecules" in reserve
  
  %% Example of use
  % res_time(1,1,[.01; 1; 0])

  % unpack parameters
  kM   = p(1);  % 1/d, somatic maint rate coeff
  g    = p(1);  % -, energy investment ratio
  lT   = p(2);  % -, scaled heating length
  
  pC = f * l .^ 2 .* (g + l + lT)/ (g + f);   % -, scaled mobilisation power
  tE = f * l .^3 ./ pC/ g/ kM;