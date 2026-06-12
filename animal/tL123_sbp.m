%% tL123_sbp(par, t0, tm)
% Calculates \int_tb^tm L^i(t) dt for i=1,2,3 for the sbp DEB model

%%
function [tL1, tL2, tL3] = tL123_sbp(par, t0, tm)
  % created 2026/03/28 by Bas Kooijman
  
  %% Syntax
  % [tL1, tL2, tL3] = <../tL123_sbp.m *tL123_sbp*> (par, t0, tm)

  %% Description
  % Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the sbp DEB model
  %
  % Input:
  %
  % * par: (4)-vector with parameters L0 (length at start), Lp (length at puberty), Li (ultimate length), rB (von Bert growth rate)
  % * t0: scalar with time since start (birth)
  % * tm: scalar with time since birth at end
  %
  % Output:
  %
  % * tL1: scalar with \int_t0^tm L(t) dt
  % * tL2: scalar with \int_t0^tm L^2(t) dt
  % * tL3: scalar with \int_t0^tm L^3(t) dt
  
  %% Example of use
  % [tL1 tL2, tL3]=tL123_sbp([0.1 .6 10 0.02], 0, 1000)

  % unpack par
  L0 = par(1); Lp = par(2); Li = par(3); rB = par(4); 

  L1 = @(t,L0,Lp,Li,rB) min(Lp,Li-(Li-L0)*exp(-rB*t));
  tL1 = integral(@(t) L1(t,L0,Lp,Li,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

  L2 = @(t,L0,Lp,Li,rB) (min(Lp,Li-(Li-L0)*exp(-rB*t))).^2;
  tL2 = integral(@(t) L2(t,L0,Lp,Li,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);
  
  L3 = @(t,L0,Lp,Li,rB) (min(Lp,Li-(L0-Li)*exp(-rB*t))).^3;
  tL3 = integral(@(t) L3(t,L0,Lp,Li,rB), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

end
