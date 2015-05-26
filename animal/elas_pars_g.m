%% elas_pars_g
% gets parameters & elasticities from data

%%
function [p, elas, Jac] = elas_pars_g(data)
  %  created 2006/09/30 by Bas Kooijman
  
  %% Syntax
  % [p, elas, Jac] = <../elas_pars_g.m *elas_pars_g*> (data)
  
  %% Description
  % Gets parameters & elasticities from data using <get_pars_g.hmtl *get_pars_g*>
  %
  % Input
  %
  % * data: 5-vector with quantities at fixed functional response
  %
  %     1 f, -, scaled functional response
  %     2 L_b, cm, length at birth
  %     3 L_m, cm, maximum length
  %     4 a_b, d, age at birth
  %     5 r_B, 1/d, von Bert growth rate
  %
  % Output
  %
  % * p: 4-vector with compound DEB parameters
  %
  %     1 VHb, d.mm^2, scaled maturity at birth
  %     2 g, -, energy investment ratio
  %     3 kM, 1/d, somatic maintenance rate coefficient
  %     4 v, cm/d, energy conductance
  %
  % * elas: (4,5)-matrix with elasticity coefficients:
  %    element (i,j): data(j) dp(i)/ (p(i) * ddata(j))
  %
  % * Jac: (4,5)-matrix with Jacobian:
  %    element (i,j): dp(i)/ ddata(j)

  %% Remarks
  % See also <elas_pars_r.html *elas_pars_r*>

  data = data(:); p = get_pars_g(data);

  del = 1e-6;
  q = data; q(1) = q(1) + del; p1 = get_pars_g(q); dp1 = (p1 - p)/del;
  q = data; q(2) = q(2) + del; p2 = get_pars_g(q); dp2 = (p2 - p)/del;
  q = data; q(3) = q(3) + del; p3 = get_pars_g(q); dp3 = (p3 - p)/del;
  q = data; q(4) = q(4) + del; p4 = get_pars_g(q); dp4 = (p4 - p)/del;
  q = data; q(5) = q(5) + del; p5 = get_pars_g(q); dp5 = (p5 - p)/del;

  Jac = [dp1, dp2, dp3, dp4, dp5];
  elas = [data,data,data,data]' .* Jac ./ [p,p,p,p,p];