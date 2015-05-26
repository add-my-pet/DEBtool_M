function int = pH_interval(V,p)
%% V: n-vector with cell volumes in mu m^3 = 10^-18 m^3 = 10^-15 dm^3 = 10^-12 cm^3
%% p: scalar with confidence level (between 0 and 1)
%% int: (n,2)-matrix with 0.5 - p/2 and 0.5 + p/2 percentiles
%% Theory:
%%  Specific density of a watery cell d_V = 1 g/cm^3
%%  Cell of volume V weighs  V 10^-12 g and has V 10^-12/18 mol water
%%  N_A = 6.02 10^23 per mol
%%  Number of water molecules N = N_A V 10^-12/18 = V 10^11/3
%%  Mean number of protons m = sqrt(N k1/k2); k1 = 2.4 10^-5; k2 = 10^3
%%    At pH = 7: m = V * 10^-15 * N_A * 10^-7 = 60.2 * V
%%  Number of free protons
%%   P_n = (m^n/n!)^2/ I_0(2m), I_0(x) is modified Bessel function
%%   Linear interpolation in distribution function:
%%      F = [0 0; .5 P_0; 1.5 (P_0 + P_1); 2.5 (P_0 + P_1 + P_2); ...] 
%%   pH = - log10(n/ N_A/ (10^-15 V) = - log10(n/ (6.02 10^8) / V)

n = length(V);
int = zeros(n,2);
m = V * 60.2; % given pH = 7
Fl = 0.5 - p/2; % lower boundary for distribution function
Fu = 0.5 + p/2; % upper boundary for distribution function
for i=1:n
  I0 = besseli(0, 2 * m(i));
  
  j = 0; F1 = 0; 
  while F1 < Fl
     F0 = F1;
     F1 = F0 + (m(i)^j/ gamma(j + 1))^2/ I0;
     j = j + 1;
  end
  if j == 1
      jF = .5 * Fl/ F1;
  else
      jF = j - .5 + (Fl - F1)/(F1 - F0);
  end
  int(i,1) = 8 - log10(jF/ 6.02/ V(i)); 
     
  
  while F1 < Fu
     F0 = F1;
     F1 = F0 + (m(i)^j/ gamma(j + 1))^2/ I0;
     j = j + 1;
  end
  if j == 1
      jF = .5 * Fu/ F1;
  else
      jF = j - .5 + (Fu - F1)/(F1 - F0);
  end
  int(i,2) = 8 - log10(jF/ 6.02/ V(i)); 

end