function data = rand_pars_9
  % created 2014/01/22 by Bas Kooijman
  %
  %% Description
  %  generates random parameters as input for filter_pars_9 and iget_pars_9
  %
  %% Output
  %  par: 9-vector with DEB parameters
  %   p_Am, J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v, cm/d, energy conductance
  %   kap, -, allocation fraction to soma 
  %   p_M, J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G, J/cm^3, [E_G] specific cost for structure
  %   E_Hb, J, E_H^b, maturity at birth 
  %   E_Hj, J, E_H^j, maturity at metamorphosis 
  %   E_Hp, J, E_H^p, maturity at puberty 
  %   h_a, 1/d^2, ageing acceleration
  %  
  %% Example of use
  %  data = rand_pars_9
  
  %% Code

  p_Am = rand(1)/ rand(1);
  v = rand(1)/ rand(1);
  kap = rand(1);
  p_M = rand(1)/ rand(1);
  E_G = rand(1)/ rand(1);
  E_Hp = 2e9 * rand(1);
  E_Hj = E_Hp * rand(1);
  E_Hb = E_Hj * rand(1);
  h_a = rand(1)^10;
    
  % pack parameters
  data = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hj; E_Hp; h_a];
