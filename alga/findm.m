function f = findm (m)
  %  created: 2000/10/03 by Bas Kooijman
  %  called from shbatch to find first guess for res densities
  %   when dilution by growth is not taken into account
  %   prepares for findrm, which has narrow attraction domain
  
  global kT_E y_EN_V y_EP_V jT_EN_Am jT_EP_Am jT_EN_M jT_EP_M ...
      X_N X_P K_N K_P kap_EN kap_EP
    
  m_EN = m(1); m_EP = m(2);
  a = (m_EN.*kT_E - jT_EN_M)/y_EN_V;
  b = (m_EP.*kT_E - jT_EP_M)/y_EP_V;
  r = 1./(1./a + 1./b - 1./(a+b));
   
  j_EN_A = jT_EN_Am*X_N/(K_N + X_N);
  f1 = j_EN_A - (1 - kap_EN)*(kT_E - r).*m_EN - ...
      kap_EN*(jT_EN_M + y_EN_V*r) - r.*m_EN;
    
  j_EP_A = jT_EP_Am*X_P/(K_P + X_P);
  f2 = j_EP_A - (1 - kap_EP)*(kT_E - r).*m_EP - ...
      kap_EP*(jT_EP_M + y_EP_V*r) - r.*m_EP;
  
  f = f1^2 + f2^2;

