%% C2F
% computes Fanrheit from Celsius

%%
function F = C2F(C)
  % created by Bas Kooijman 2023/06/04
  
  %% Syntax
  % F = <../C2F.m *C2F*>(C)
  
  %% Description
  % Obtains Farnheit from temperatures defined in Celsius
  %
  % Input
  %
  % * F: scalar or matrix in temperatures in degrees Celsius
  %  
  % Output
  %
  % * C: temperature(s) in Farnheit
  
  %% Example 
  % C2F(23)

  
  F = C * 9/5 + 32; % F, temperature in Farnheit
end