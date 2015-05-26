%% get_pars_98
% Obtains 9 DEB parameters from 8 data points at abundant food

%%
function [par W_j info] = get_pars_98(data, fixed_par, chem_par)
  % created 2015/03/10 by Bas Kooijman
  
  %% Syntax
  % par = <../get_pars_9.m *get_pars_98*> (data, fixed_par, chem_par)
  
  %% Description
  % Obtains 9 DEB parameters from 8 data points at abundant food.
  % Accounts for minimum type M acceleration such that a_b is within data boundary
  %
  % Input
  %
  %  data: 8-vector with zero-variate data
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
  % * fixed_par: optional  vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * par: 9-vector with DEB parameters
  %
  %   p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v: cm/d, energy conductance
  %   kap: -, allocation fraction to soma 
  %   p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G: J/cm^3, [E_G] specific cost for structure
  %   E_Hb: J, E_H^b, maturity at birth 
  %   E_Hj: J, E_H^j, maturity at metamorphosis 
  %   E_Hp: J, E_H^p, maturity at puberty 
  %   h_a: 1/d^2, ageing acceleration
  
  %% Remarks
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See <iget_pars_9.html *iget_pars_9*> for the inverse mapping and 
  %  <get_pars_2a.html *get_pars_2a*>,
  %  <get_pars_3.html *get_pars_3*>,
  %  <get_pars_4.html *get_pars_4*>,
  %  <get_pars_5.html *get_pars_5*>,
  %  <get_pars_6.html *get_pars_6*>,
  %  <get_pars_6a.html *get_pars_6a*>,
  %  <get_pars_7.html *get_pars_7*>,
  %  <get_pars_8.html *get_pars_8*>,
  %  <get_pars_9.html *get_pars_9*>.
  
  %% Example of use
  %  See <../mydata_get_par_9.m *mydata_get_par_9*>
  
data = data([1 2 3 4 5 5 6 7 8]); % extend data with data(6) = W_j = W_b

while ~filter_data_9(data, fixed_par, chem_par) && data(6) < data(7)
  data(6) = 1.05 * data(6); % increase W_j till a_b is inside boundary
end

if ~filter_data_9(data, fixed_par, chem_par) % exclude that W_j > W_p
  fprintf('warning from get_pars_98: data outside boundary \n');
  par = []; W_j = data(5); info = 0; 
else
  par = get_pars_9(data, fixed_par, chem_par); W_j = data(6); info = 1;
end
