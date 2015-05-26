%% elas_pars_r
% gets parameters & elasticities from data

%%
function [p, elas, Jac] = elas_pars_r(data)
  %  created 2006/09/30 by Bas Kooijman
  
  %% Syntax
  % [p, elas, Jac] = <../elas_pars_r.m *elas_pars_r*> (data)
  
  %% Description
  % Gets parameters & elasticities from data using <get_pars_r.hmtl *get_pars_r*>
  %
  % Input
  %
  % * data: 7 or 8-vector with quantities at constant scaled functional response
  %
  %     1 f, -, scaled functional response
  %     2 L_b, mm, length at birth
  %     3 L_p, mm, at puberty
  %     4 L_m, mm, ultimate length
  %     5 a_b, d, age at birth
  %     6 r_B, 1/d, von Bertalanffy growth rate
  %     7 R_m, 1/d, maximum reproduction rate
  %     8 kapR, -, fraction allocated to reprod that is fixed in embryo's
  %
  %           this parameter is optional. If not specified kapR = 0.95
  %
  % Output
  %
  % * p: 8-vector with compound DEB parameters
  %
  %     1 kap, -, fraction allocated to som maint + growth
  %     2 kapR, -,fraction of energy allocated to reprod fixed in embryo
  %     3 g, -, energy investment ratio
  %     4 kJ, d^-1, maturity maintenance rate coefficient
  %     5 kM, d^-1, somatic maintenance rate coefficient
  %     6 v, mm/d, energy conductance
  %     7 Hb, d.mm^2, scaled maturity at birth M_H^b/{J_EAm}
  %     8 Hp, d.mm^2, scaled maturity at puberty M_H^p/{J_EAm}
  %
  % * elas: (8,8)-matrix with elasticity coefficients:
  %
  %     element (i,j): data(j) dp(i)/ (p(i) * ddata(j))
  %
  % * Jac: (8,8)-matrix with Jacobian:
  %
  %     element (i,j): dp(i)/ ddata(j)
  
  %% Remarks
  % See also <elas_pars_g.html *elas_pars_g*>
  
  data = data(:); np = size(data,1);
  if np == 7
    data = [data; 0.95];
  end
  p = get_pars_r(data);

  del = 1e-6;
  q = data; q(1) = q(1) + del; p1 = get_pars_r(q); dp1 = (p1 - p)/del;
  q = data; q(2) = q(2) + del; p2 = get_pars_r(q); dp2 = (p2 - p)/del;
  q = data; q(3) = q(3) + del; p3 = get_pars_r(q); dp3 = (p3 - p)/del;
  q = data; q(4) = q(4) + del; p4 = get_pars_r(q); dp4 = (p4 - p)/del;
  q = data; q(5) = q(5) + del; p5 = get_pars_r(q); dp5 = (p5 - p)/del;
  q = data; q(6) = q(6) + del; p6 = get_pars_r(q); dp6 = (p6 - p)/del;
  q = data; q(7) = q(7) + del; p7 = get_pars_r(q); dp7 = (p7 - p)/del;
  q = data; q(8) = q(8) + del; p8 = get_pars_r(q); dp8 = (p8 - p)/del;

  Jac = [dp1, dp2, dp3, dp4, dp5, dp6, dp7, dp8];
  elas = [data,data,data,data,data,data,data,data]' .* Jac ./ [p,p,p,p,p,p,p,p];
