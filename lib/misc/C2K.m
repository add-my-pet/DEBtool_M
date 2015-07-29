%% C2K
% computes Kelvin from Celsius

%%
function K = C2K(C)
  % created by Bas Kooijman 2015/01/30; modified 2015/07/28
  
  %% Syntax
  % K = <../C2K.m *C2K*>(C)
  
  %% Description
  % Obtains Kelvin from temperatures defined in Celsius
  %
  % Input
  %
  % * C: scalar or matrix in temperatures in degrees Celsius
  %  
  % Output
  %
  % * K: temperature(s) in Kelvin
  
  %% Example 
  % C2K(20)

  K = C + 273.15; % K, temperature in Kelvin
end

