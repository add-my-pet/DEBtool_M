%% cpm_unpack
% unpack states of cohorts

%%
function [X, q, h_A, L, L_max, E, E_R, E_H, N] = cpm_unpack(Xvars)
% created 2020/03/09 by Bob Kooi & Bas Kooijman
  
%% Syntax
% [X, q, h_A, L, L_max, E, E_R, E_H, N] = <../cpm_unpack.m *cpm_unpack*> (Xvars)
  
%% Description
%  unpack states of cohorts
%
% Input:
%
% * Xvars: vector with states of cohorts
%
% Output:
%
% * X: scalar with food density
% * q: vector with aging acceleration
% * h_A: vector with aging hazard
% * L: vector with struct length
% * L_max: vector with struc length (for shrinking)
% * E: vector with reserve density [E]
% * E_R: vector with reprod buffer
% * E_H: vector with maturity
% * N: vector number of individuals

  n_c = (length(Xvars) - 1)/ 8; % #, current number of cohorts
  coh = 1:n_c; % cohorts 1 till n_c
  Xvars = Xvars(:);
  
  X = max(0,Xvars(1)); 
  q = max(0,Xvars(1+coh));       h_A = max(0,Xvars(1+n_c+coh));   L = max(0,Xvars(1+2*n_c+coh));   L_max = max(0,Xvars(1+3*n_c+coh)); 
  E = max(0,Xvars(1+4*n_c+coh)); E_R = max(0,Xvars(1+5*n_c+coh)); E_H = max(0,Xvars(1+6*n_c+coh)); N = max(0,Xvars(1+7*n_c+coh));
end
