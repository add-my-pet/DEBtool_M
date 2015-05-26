function [jO2 jCO2] = expo2(p, tO2, tCO2)
  
  %% unpack parameters
  jO20 = p(1); jCO20 = p(2); vL = p(3);
  jO2 = jO20 * exp( - tO2(:,1) * vL);
  jCO2 = jCO20 * exp( - tCO2(:,1) * vL);