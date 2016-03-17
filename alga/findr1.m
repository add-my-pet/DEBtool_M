function r =findr1 (m)
  % created: 2000/10/03 by Bas Kooijman
  % called from dchem to find growth rate; see p169 of DEB-book
  
  global m_EN m_EP kT_E y_EN_V y_EP_V jT_EN_M jT_EP_M
  
   m_EN = m(1); m_EP = m(2);
   i=0; j = 0; ni = 20; norm = 1e-6; F = 1;
   r = 1/(1/((m_EN*kT_E - jT_EN_M)/y_EN_V) + ...
	      1/((m_EP*kT_E - jT_EP_M)/y_EP_V) - ...
        1/((m_EN*kT_E - jT_EN_M)/y_EN_V + ...
        (m_EP*kT_E - jT_EP_M)/y_EP_V));

    while F^2 > norm & i < ni 
      i = i+1;
      a = (m_EN*(kT_E - r) - jT_EN_M)/y_EN_V;
      dadr = - m_EN/y_EN_V;
      b = (m_EP*(kT_E - r) - jT_EP_M)/y_EP_V;
      dbdr = - m_EP/y_EP_V;
      F = 1/(1/a + 1/b - 1/(a+b)) - r;
      dFdr = 1 + (F+r)^2*((dadr+dbdr)/(a+b)^2 - dadr/a^2 - dbdr/b^2);
      r = r + F/dFdr
    end
    
  if F^2 > norm
    printf('warning: no convergence')
  end
    
        
