function d = del (t, el)
  %  created 2000/08/21 by Bas Kooijman
  %  differential equations for change in scaled reserve and length
  %    during the embryonic period; time is scaled with k_M
  %    d = [d/dtau e*l^3, d/dtau l]; el = [e*l^3, l]
  %    the first element is not d/dt e, because e -> infty for t -> 0
  
  global g; d = zeros(2,1);
  
  l3 = el(2)^3;
  d(2) = (g/3)*(el(1) - el(2)*l3)/(el(1) + g*l3);
  d(1) = (3*d(2) - g)*el(1)/el(2);
