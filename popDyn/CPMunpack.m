%% CPMunpack
% unpack states of cohorts

%%
function [X, q, h_A, L, E, E_R, E_H, N] = CPMunpack(Xvars)
% created 2020/03/09 by Bob Kooi & Bas Kooijman
  
%% Syntax
% [X, q, h_A, L, E, E_R, E_H, N] = <../CPMunpack.m *CPMunpack*> (Xvars)
  
%% Description
%  unpack states of cohorts
%
% Input:
%
% * Xvars: vector with states of cohorts
%
% Output:
%
% * X: mol/L, scalar with food density
% * q: 1/d^2, vector with aging acceleration
% * h_A: 1/d, vector with aging hazard
% * L: cm, vector with struct length
% * E: J/cm^3, vector with reserve density [E]
% * E_R: J, vector with reprod buffer
% * E_H: J, vector with maturity
% * N: -, vector number of individuals

  n_c = (length(Xvars) - 1)/ 7; % #, current number of cohorts
  coh = 1:n_c; % cohorts 1 till n_c
  Xvars = Xvars(:);
  
  X = max(0,Xvars(1));           q = max(0,Xvars(1+coh));         h_A = max(0,Xvars(1+n_c+coh));   L = max(0,Xvars(1+2*n_c+coh));   
  E = max(0,Xvars(1+3*n_c+coh)); E_R = max(0,Xvars(1+4*n_c+coh)); E_H = max(0,Xvars(1+5*n_c+coh)); N = max(0,Xvars(1+6*n_c+coh));
end
