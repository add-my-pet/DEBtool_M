function r =findr0 (m)
  % created: 2000/10/03 by Bas Kooijman
  % called from dchem to find growth rate; see p169 of DEB-book
  
  global m_EN m_EP kT_E y_EN_V y_EP_V jT_EN_M jT_EP_M
  
   m_EN = m(1); m_EP = m(2);
   r = 0; n =1; i=0; j = 0; nj = 8; ni = 20; norm = 1e-6;
  while j<nj
    while n > norm & i < ni 
    r0 = r; i = i+1;
    r = 1/(1/((m_EN*(kT_E - r) - jT_EN_M)/y_EN_V) + ...
	      1/((m_EP*(kT_E - r) - jT_EP_M)/y_EP_V) - ...
        1/((m_EN*(kT_E - r) - jT_EN_M)/y_EN_V + ...
        (m_EP*(kT_E - r) - jT_EP_M)/y_EP_V));
    n = (r - r0)^2;   
    end
    if n > norm
      j = j+1; i = 0; % j is number of trials from an initial value
      r = j/10; % try new initial value
    else
      break % norm is reached
    end
  end
  if j == nj
    'warning: no convergence'
  end
    
        
