%% Gamma
% incomplete Gamma function

%%
function G = Gamma(x, a)
  % created at 2009/08/04 by Bas Kooijman
  
  %% Syntax
  % G = <../Gamma.m *Gamma*> (x, a)
  
  %% Description
  % incomplete Gamma function: Gamma(a,x) = int_x^\infty exp(-t) t^(a-1) dt
  %
  % Input:
  %
  % * x: scalar with parameter
  % * a: scalar with parameter
  %
  % Output:
  %
  % * G: scalar with incomplete gamma function
  
  if exist('a','var') == 0
    a = 0;
  end
    
  G = gamma(a) * (1 - gammainc(x, a));