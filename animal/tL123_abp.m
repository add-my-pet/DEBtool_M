%% tL123_abp(par, t0, tm)
% Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the abp DEB model

%%
function [tL1, tL2, tL3] = tL123_abp(par, t0, tm)
  % created 2026/05/16 by Bas Kooijman
  
  %% Syntax
  % [tL1, tL2, tL3] = <../tL123_abp.m *tL123_abp*> (par, t0, tm)

  %% Description
  % Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the abj DEB model
  %
  % Input:
  %
  % * par: (5)-vector with parameters 
  %   - L0 (length at start), 
  %   - Lp (length at puberty), 
  %   - rj (exp growth rate), 
  %   - tp (time since birth at puberty)
  % * t0: scalar with time at start (birth)
  % * tm: scalar with time since start at end
  %
  % Output:
  %
  % * tL1: scalar with \int_t0^tm L(t) dt
  % * tL2: scalar with \int_t0^tm L^2(t) dt
  % * tL3: scalar with \int_t0^tm L^3(t) dt
  
  %% Example of use
  % [tL1 tL2, tL3] = tL123_abp([0.1 0.3 10 15], 0, 1000)
  
  % unpack par
  L0 = par(1); Lp = par(2); rj = par(3); tp = par(4);

  L1 = @(t,L0,Lp,rj,tp) (t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp)*Lp;
  tL1 = integral(@(t) L1(t,L0,Lp,rj,tp), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

  L2 = @(t,L0,Lp,rj,tp) ((t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp)*Lp).^2;
  tL2 = integral(@(t) L2(t,L0,Lp,rj,tp), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);
  
  L3 = @(t,L0,Lp,rj,tp) ((t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp)*Lp).^3;
  tL3 = integral(@(t) L3(t,L0,Lp,rj,tp), t0, tm, 'AbsTol',1e-10, 'RelTol',1e-10);

end
