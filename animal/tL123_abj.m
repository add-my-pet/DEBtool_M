%% tL123_abj(par, t0, tm)
% Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the abj DEB model

%%
function [tL1, tL2, tL3] = tL123_abj(par, t0, tm)
  % created 2026/05/16 by Bas Kooijman
  
  %% Syntax
  % [tL1, tL2, tL3] = <../tL123_abj.m *tL123_abj*> (par, t0, tm)

  %% Description
  % Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the abj DEB model
  %
  % Input:
  %
  % * par: (5)-vector with parameters L0 (length at start), Lj (length at metam), Li (ultimate length), rj (exp growth rate), rB (von Bert growth rate)
  % * t0: scalar with time since start (birth)
  % * tm: scalar with time since start at end
  %
  % Output:
  %
  % * tL1: scalar with \int_t0^tm L(t) dt
  % * tL2: scalar with \int_t0^tm L^2(t) dt
  % * tL3: scalar with \int_t0^tm L^3(t) dt
  
  %% Example of use
  % [tL1 tL2, tL3] = tL123_abj([0.1 0.3 10 0.01 0.02], 0, 1000)

  % unpack par
  L0 = par(1); Lj = par(2); Li = par(3); rj = par(4); rB = par(5); 
  tj = 3*log(Lj/L0)/rj; % d, time since birth at metam 

  L1 = @(t,tj,L0,Li,rj,rB) (t<tj).*L0.*exp(rj*t/3)+(t>=tj).*(Li-(Li-Lj).*exp(-rB*(t-tj)));
  tL1 = integral(@(t) L1(t,tj,L0,Li,rj,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

  L2 = @(t,tj,L0,Li,rj,rB) (t<tj).*L0.*exp(rj*t/3)+(t>=tj).*(Li-(Li-Lj).*exp(-rB*(t-tj))).^2;
  tL2 = integral(@(t) L2(t,tj,L0,Li,rj,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);
  
  L3 = @(t,tj,L0,Li,rj,rB) (t<tj).*L0.*exp(rj*t/3)+(t>=tj).*(Li-(Li-Lj).*exp(-rB*(t-tj))).^3;
  tL3 = integral(@(t) L3(t,tj,L0,Li,rj,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

end
