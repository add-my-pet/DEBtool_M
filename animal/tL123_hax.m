%% tL123_hax(par, t0, tm)
% Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the hax DEB model

%%
function [tL1, tL2, tL3] = tL123_hax(par, t0, tj)
  % created 2026/05/16 by Bas Kooijman
  
  %% Syntax
  % [tL1, tL2, tL3] = <../tL123_hax.m *tL123_hax*> (par, t0, tj)

  %% Description
  % Calculates \int_t0^tm L^i(t) dt for i=1,2,3 for the hax DEB model
  %
  % Input:
  %
  % * par: (5)-vector with parameters 
  %   - L0 (length at start), 
  %   - Lj (length at metam), 
  %   - Li (ultimate length), 
  %   - rj (exp growth rate), 
  %   - rB (von Bert growth rate)
  %   - tp (time since birth at puberty)
  % * t0: scalar with time at start (birth)
  % * tj: scalar with time since start at pupation
  %
  % Output:
  %
  % * tL1: scalar with \int_t0^tj L(t) dt
  % * tL2: scalar with \int_t0^tj L^2(t) dt
  % * tL3: scalar with \int_t0^tj L^3(t) dt
  
  %% Example of use
  % [tL1 tL2, tL3] = tL123_hax([0.1 0.3 10 0.01 0.02 4], 0, 1000)

  % unpack par
  L0 = par(1); Lp = par(2); Li = par(3); rj = par(4); rB = par(5); tp = par(6); 

  L1 = @(t,L0,Lp,Li,rj,rB,tp) (t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp).*(Li-(Li-Lp)*exp(-rB*(t-tp)));
  tL1 = integral(@(t) L1(t,L0,Lp,Li,rj,rB,tp), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);

  L2 = @(t,L0,Lp,Li,rj,rB,tp) ((t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp).*(Li-(Li-Lp)*exp(-rB*(t-tp)))).^2;
  tL2 = integral(@(t) L2(t,L0,Lp,Li,rj,rB,tp), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);
  
  L3 = @(t,L0,Lp,Li,rj,rB,tp) ((t<tp)*L0.*exp(rj*min(t,tp+.1)/3)+(t>=tp).*(Li-(Li-Lp)*exp(-rB*(t-tp)))).^3;
  tL3 = integral(@(t) L3(t,L0,Lp,Li,rj,rB,tp), t0, tj, 'AbsTol',1e-10, 'RelTol',1e-10);

end
