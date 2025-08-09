%% ss2FAS
% computes Factorial Aerobic Scope from supply stress s_s
%%
function  FAS = ss2FAS(ss)
  % created by Bas Kooijman 2025/08/09
  
  %% Syntax
  % FAS = <../ss2FAS.m *ss2FAS*>(ss)
  
  %% Description
  % Computes Factorial Aerobic Scope from supply stress s_s.
  % Range limit for s_s (0,4/27)
  %
  % Input
  %
  % * s_s: scalar or matrix with supply stress
  %  
  % Output
  %
  % * FAS: Factorial Aerobic Scope
  %
  %% Remarks
  % see FAS2ss for the reverse transformation
  
  %% Example 
  % FAS2ss(0.5)
  
  if any(ss<0,'all') || any(ss>4/27,'all')
    fprintf('Warning from ss2FAS: some values of ss are out of range\n');
  end

  FAS = 10.^(0.5+ss*27/4); % -, supply stress
end

