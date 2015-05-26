function [X, lim] = state0_mixo (Ctot, Ntot)
  %  routine called from shstate0_mixo
  %  Equilibria for closed 0-reserve mixotroph system

  global j_V_Am K_C K_N K_NV K_D rho_A rho_H ...
    k_A k_H z_C z_CH z_N y_DV k_M h n_NV L_m;

  %  help variables 
  j_V_A = k_M + h;
  a_A = 1 - h/(j_V_A * y_DV);
  k = a_A * k_A + (1 - a_A) * k_H;
  j_VA_AA = a_A/ (rho_A/ j_V_A - rho_A/ k);
  j_VH_AH = (1 - a_A)/ (rho_H/ j_V_A - rho_H/ k);

  a = (1 + 1/z_N + 1/z_CH - 1/(z_N + z_CH)) * j_V_Am/ j_VA_AA;
  f_CH = (sqrt(1 + 4/(a * z_N - z_N - 1)) - 1) * z_N/(2 * z_CH);
  f_N = (sqrt(1 + 4/(a * z_CH - z_CH - 1)) - 1) * z_CH/(2 * z_N);
  f_C = 1/((z_C + 1)/ f_CH - z_C);
  
  %  initial guesses for state variables   
  %  light limitation
      XL(3) = K_D/ (j_V_Am/j_VH_AH - 1);   % D, Detritus
      XL(4) = 0;                           % V, Structure 
      XL(1) = Ctot - XL(3);                % DIC
      XL(2) = Ntot - n_NV*XL(3);           % DIN

  %  carbon limitation
      XC(3) = K_D/ (j_V_Am/j_VH_AH - 1);   % D, Detritus
      XC(1) = K_C/ (1/ f_C - 1);           % DIC 
      XC(4) = Ctot - XC(1) - XC(3);        % V, Structure 
      XC(2) = Ntot - n_NV*(XC(3) + XC(4)); % DIN

  %  nitrogen limitation
      XN(3) = K_D/ (j_V_Am/j_VH_AH - 1);   % D, Detritus
      XN(2) = K_N/ (1/f_N - 1);            % DIN
      XN(4) = (Ntot -XN(2))/n_NV - XN(3);  % V, Structure 
      XN(1) = Ctot - XN(3) - XN(4);        % DIC 

  if length(XN) == sum (XN > 0)
    X = XN; lim = 3; % N limitation
  elseif length(XC) == sum (XC > 0)
    X = XC; lim = 2; % C limitation
  else
    X = XL; lim = 1; % L limitation
  end
