function data = rand_data_9
  % created 2014/01/22 by Bas Kooijman
  %
  %% Description
  %  generates random data as input for filter_data_9 and get_pars_9
  %
  %% Output
  %  data: 9-vector with zero-variate data
  %    d_V, g/cm^3 specific density of structure
  %    a_b, d, age at birth
  %    a_p, d, age at puberty
  %    a_m, d, age at death due to ageing
  %    W_b, g, wet weight at birth
  %    W_j, g, wet weight at metamorphosis
  %    W_p, g, wet weight at puberty
  %    W_m, g,  maximum wet weight
  %    R_m, #/d, maximum reproduction rate
  %  
  %% Example of use
  %  data = rand_data_9
  
  %% Code

  d_V = rand(1)/ rand(1);
  a_m = 1e4;
  a_p = a_m * rand(1);
  a_b = a_p * rand(1);
  W_m = 1e8 * rand(1);
  W_p = W_m * rand(1);
  W_j = W_p * rand(1);
  W_b = W_j * rand(1);
  R_m = rand(1)/ rand(1);
    
  % pack data
  data = [d_V; a_b; a_p; a_m; W_b; W_j; W_p; W_m; R_m];