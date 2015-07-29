%% K2C
% computes Celsius from Kelvin

%%
function C = K2C(K)
  % created by Bas Kooijman 2015/01/30; modified 2015/07/28
  
  %% Syntax
  % K = <../C2K.m *C2K*>(C)
  
  %% Description
  % Obtains Kelvin from temperatures defined in degrees Celsius
  %
  % Input
  %
  % * K: scalar or matrix in temperatures in Kelvin
  %  
  % Output
  %
  % * C: temperature(s) in degrees Celsius
  
  %% Example 
  % K2C(280)

  C = K - 273.15; % K, temperature in Kelvin
end

