%% tL123_hex(par, t0, tm)
% Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the hex DEB model

%%
function [tL1, tL2, tL3] = tL123_hex(par, t0, tj)
  % created 2026/05/16 by Bas Kooijman
  
  %% Syntax
  % [tL1, tL2, tL3] = <../tL123_hex.m *tL123_hex*> (par, t0, tj)

  %% Description
  % Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the hex DEB model
  %
  % Input:
  %
  % * par: (2)-vector with parameters L0 (length at start), rj (exp growth rate)
  % * t0: scalar with time at start (birth)
  % * tj: scalar with time since start at pupation
  %
  % Output:
  %
  % * tL1: scalar with \int_t0^tj L(t) dt
  % * tL2: scalar with \int_t0^tj L^2(t) dt
  % * tL3: scalar with \int_t0^tj L^3(t) dt
  
  %% Example of use
  % [tL1 tL2, tL3] = tL123_hex([0.1 3], 0, 35)

  % unpack par
  L0 = par(1); rj = par(2); 

  L1 = @(t,L0,rj) L0.*exp(rj*t/3);
  tL1 = integral(@(t) L1(t,L0,rj), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);

  L2 = @(t,L0,rj) (L0.*exp(rj*t/3)).^2;
  tL2 = integral(@(t) L2(t,L0,rj), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);
  
  L3 = @(t,L0,rj) (L0.*exp(rj*t/3)).^3;
  tL3 = integral(@(t) L3(t,L0,rj), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);

end
