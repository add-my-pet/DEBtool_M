function [dv, isterm, dir] = eb_min_stop (t, ulv)
 % stop integrating ulv till d/dt v = 0
 % used for dget_ulv in get_eb_min

 global g k 
 
 % unpack state variables
 u = ulv(1); % scaled reserve u = E/(g [E_m] L_m^3)
 l = ulv(2); % scaled structural length l = L/ L_m
 v = ulv(3); % scaled maturity v = E_H/ (g [E_m] L_m^3 (1 - kap)

 ul3 = u + l^3;
 dv = u * l^2 * (g + l)/ ul3 - k * v; % dv/dt = 0
  
 isterm = 1;
 dir = [];