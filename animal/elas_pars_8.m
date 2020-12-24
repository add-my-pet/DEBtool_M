%% elas_pars_8
% gets parameters & elasticities from data with std model

%%
function [p, elas, Jac] = elas_pars_8(data, fixed_par, chem_par)
  %  created 2020/12/24 by Bas Kooijman
  
  %% Syntax
  % [p, elas, Jac] = <../elas_pars_8.m *elas_pars_8*> (data)
  
  %% Description
  % Gets parameters & elasticities from data using <get_pars_8.hmtl *get_pars_8*> for std model at abundant food
  %
  % Input
  %
  % * data: 8-vector
  %
  %    d_V: g/cm^3 specific density of structure
  %    a_b: d, age at birth
  %    a_p: d, age at puberty
  %    a_m: d, age at death due to ageing
  %    W_b: g, wet weight at birth
  %    W_p: g, wet weight at puberty
  %    W_m: g,  maximum wet weight
  %    R_m: #/d, maximum reproduction rate
  %
  % * fixed_par: optional 4 vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %
  % Output
  %
  % * p: 8-vector with  DEB parameters
  %
  %   p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v: cm/d, energy conductance
  %   kap: -, allocation fraction to soma 
  %   p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G: J/cm^3, [E_G] specific cost for structure
  %   E_Hb: J, E_H^b, maturity at birth 
  %   E_Hp: J, E_H^p, maturity at puberty 
  %   h_a: 1/d^2, ageing acceleration
  %
  % * elas: (8,8)-matrix with elasticity coefficients:
  %
  %     element (i,j): data(j) dp(i)/ (p(i) * ddata(j))
  %
  % * Jac: (8,8)-matrix with Jacobian:
  %
  %     element (i,j): dp(i)/ ddata(j)
  
  %% Remarks
  % See also <elas_pars_9.html *elas_pars_9*>
  
  %% Example of use
  % [par, elas, Jac] = elas_pars_8(iget_pars_8([3500 0.02 0.8 2500 7800 180 1800 1e-10]))
  
  if exist('fixed_par','var') == 0 
    fixed_par = [];
  end
  %
  if exist('chem_par','var') == 0 
    chem_par = [];
  end

  data = data(:); 
  np = size(data,1);
  if np~=8
    fprintf('Warning from elas_pars_8: number of data is not equal to 8\n')
    p = []; elas = [];  Jac = []; return
  end
  p = get_pars_8(data);

  del = 1e-4;
  q = data; q(1) = q(1) + del; p1 = get_pars_8(q, fixed_par, chem_par); dp1 = (p1 - p)/del;
  q = data; q(2) = q(2) + del; p2 = get_pars_8(q, fixed_par, chem_par); dp2 = (p2 - p)/del;
  q = data; q(3) = q(3) + del; p3 = get_pars_8(q, fixed_par, chem_par); dp3 = (p3 - p)/del;
  q = data; q(4) = q(4) + del; p4 = get_pars_8(q, fixed_par, chem_par); dp4 = (p4 - p)/del;
  q = data; q(5) = q(5) + del; p5 = get_pars_8(q, fixed_par, chem_par); dp5 = (p5 - p)/del;
  q = data; q(6) = q(6) + del; p6 = get_pars_8(q, fixed_par, chem_par); dp6 = (p6 - p)/del;
  q = data; q(7) = q(7) + del; p7 = get_pars_8(q, fixed_par, chem_par); dp7 = (p7 - p)/del;
  q = data; q(8) = q(8) + del; p8 = get_pars_8(q, fixed_par, chem_par); dp8 = (p8 - p)/del;

  Jac = [dp1, dp2, dp3, dp4, dp5, dp6, dp7, dp8];
  elas = [data,data,data,data,data,data,data,data]' .* Jac ./ [p,p,p,p,p,p,p,p];
