%% FAS2ss
% computes supply stress s_s from Factorial Aerobic Scope

%%
function ss = FAS2ss(FAS)
  % created by Bas Kooijman 2025/08/09
  
  %% Syntax
  % ss = <../FAS2ss.m *FAS2ss*>(FAS)
  
  %% Description
  % Computes supply stress s_s from Factorial Aerobic Scope.
  % Range limit for FAS (10^0.5,10^1.5)
  %
  % Input
  %
  % * FAS: scalar or matrix with Factorial Aerobic Scope
  %  
  % Output
  %
  % * s_s: supply stress
  %
  %% Remarks
  % see ss2FAS for the reverse transformation

  %% Example 
  % FAS2ss(0.5)

  if any(FAS<10^0.5,'all') || any(FAS>10^1.5,'all')
    fprintf('Warning from FAS2ss: some values of FAS are out of range\n');
  end

  ss = 4/27*(log10(FAS)-0.5); % -, supply stress
end

