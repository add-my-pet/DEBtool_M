%% get_Lm_iso_21_var
% finds L_m for iso_221_var model

%%
function [L_m, m_E1m, m_E2m, M_Vm] = get_Lm_iso_21_var (p)
  % created: 2023/08/05 by Bas Kooijman

  %% Syntax
  % [L_m, m_E1, m_E2, M_Vm] = <../get_Lm_iso_21_var.m *get_Lm_iso_21_var*> (p)

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

  J_E1Am = max(p.y_E1X1 * p.J_X1Am, p.y_E1X2 * p.J_X2Am); J_E2Am = max(p.y_E2X1 * p.J_X1Am, p.y_E2X2 * p.J_X2Am); % mol/d, max assim
  m_E1m = J_E1Am/ p.v/ p.MV; m_E2m = J_E2Am/ p.v/ p.MV; % mol/mol, max reserve densities

  L_m = p.kap * p.v * max((p.mu_E1 * m_E1m + p.mu_E2 * m_E2m)/ (p.mu_E2 * p.j_E2M), m_E1m/ p.j_E1M + m_E2m/ p.j_E2M); % cm, max struc length
  M_Vm = p.MV * L_m^3; % mol, max struc mass
  
end