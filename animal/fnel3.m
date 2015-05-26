function del3dl = fnel3(l,el3)
  % created 2000/09/06 by Bas Kooijman
  % fnel3: d/dl el^3 = - 3 el^3(l+g)l^2/(el^3-l^4) for embryo
  % el3: e l^3
  global g;

  del3dl = - 3*el3*(l + g).*l.^2./(el3 - l^4);

