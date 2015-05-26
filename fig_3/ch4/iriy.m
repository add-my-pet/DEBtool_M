function f = iriy(p,xy)
  %% xy(:,1): inverse dilution rate
  %% xy(:,2),f: inverse yield

  Yg = p(1); kE = p(2); ldg = p(3); %% ldg = l_d/g 

  f = (kE/Yg) * (1 + kE * ldg * xy(:,1)) ./ (kE - 1 ./ xy(:,1));
