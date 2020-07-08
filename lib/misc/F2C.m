%% F2C
% computes Celsius from Farnheit

%%
function C = F2C(F)
  % created by Bas Kooijman 2015/01/30; modified 2015/07/28
  
  %% Syntax
  % C = <../F2C.m *F2C*>(F)
  
  %% Description
  % Obtains Celsius from temperatures defined in Farnheit
  %
  % Input
  %
  % * F: scalar or matrix in temperatures in degrees Farnheit
  %  
  % Output
  %
  % * C: temperature(s) in Celsiu
  
  %% Example 
  % C2K(20)

  C = (F - 32) * 5/9 ; % C, temperature in Celsius
end