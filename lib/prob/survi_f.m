%% survi_f
% calculates the inverse survivor probability of the F distribution

%%
function [x info] = survi_f (nu, F)
  % created 2005/10/02 by Bas Kooijman; modified 2008/08/08
  
  %% Syntax
  % [x info] = <../survi_f.m *survi_f*> (nu, F)

  %% Description
  % Calculates the inverse survivor probability of the F distribution
  %
  % Input:
  %
  % * nu: (2,1)-vector with parameters (degrees of freedom; integers)
  % * F: vector with survivor probabilities
  %
  % Output
  %
  % * x: vector with argument values for which the survivor function equals F
  % * info: indicator for success (1); 0 otherwise
  
  %% Remarks
  % This function is inverse to <surv_f.html *surv_f*>.
  
  %% Example of use
  % survi_f([1;5], [.9 .8 .7]) or survi_f([3;2],surv_f([3;2],1:4))
    
  F = F(:); n = length(F); x = zeros(n,1); info = 0;
  
  for i=1:n
   [x(i) flag info_i] = fzero(@(x)surv_f(nu,x) - F(i),.5);
   info = info + info_i;
  end
  
  info = info > 0;
