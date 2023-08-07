%% get_Lm_iso_21
% finds L_m for iso_221 model

%%
function [L_m, m_E1m, m_E2m, M_Vm, info] = get_Lm_iso_21 (p)
  % created: 2023/08/05 by Bas Kooijman

  %% Syntax
  % [L_m, m_E1, m_E2, M_Vm, info] = <../get_Lm_iso_21.m *get_Lm_iso_21*> (p)

  %% Description    
  % Finds L_m at max assimilation, i.e. L such that r = 0
  %
  % Input:
  %
  % * p, structure with parameters, see mydata_iso_221
  %
  % Output:
  %
  % * L_m:          cm,     max structural length 
  % * m_E1m, m_E2m  mol/mol max reserve densities
  % * M_Vm          mol     max body mass (incl reserves, excl reprod buffer)
  % * info          -       scalar with numerical failure (0) or success (1)

  J_E1Am = max(p.y_E1X1 * p.J_X1Am, p.y_E1X2 * p.J_X2Am); J_E2Am = max(p.y_E2X1 * p.J_X1Am, p.y_E2X2 * p.J_X2Am); % mol/d, max assim
  m_E1m = J_E1Am/ p.v/ p.MV; m_E2m = J_E2Am/ p.v/ p.MV; % mol/mol, max reserve densities

  [L_m, fval, info] = fzero(@(L) sgr_iso_21(m_E1m, m_E2m, p.j_E1M, p.j_E2M, p.y_VE1, p.y_VE2, p.mu_E1/ p.mu_V, p.v/L, p.kap, p.rho1), [1e-3 1e3]);
  M_Vm = p.MV * L_m^3; % mol, max mass of structure
  %
  % warning: if an initial value for fzero is used, rather than an interval, 
  %    next calls can have different results with large fval, but still with info = 1; clear all helps solving that problem 
  %    
  if abs(fval) > 1e-7; fprintf('Results from fzero: L_m = %g cm; fval = %g 1/d; info = %g\n', L_m, fval, info); info = 0; end
  if ~(info==1); fprintf('Warning from get_Lm_iso_21: max length not found\n'); end
  
%   L=linspace(.1,5,500); r=0*L;
%   for i=1:500; r(i)=sgr_iso_21(m_E1m, m_E2m, p.j_E1M, p.j_E2M, p.y_VE1, p.y_VE2, p.mu_E1/ p.mu_V, p.v/L(i), p.kap, p.rho1); end
%   plot(L,r,'b'); xlabel('struc length L, cm'); ylabel('spec growth rate r, 1/d')
  
end