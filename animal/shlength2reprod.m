function shlength2reprod
  %  created 2000/09/05 by Bas Kooijman, modified 2011/02/03
  %  plot reproduction rate as a function of length
  %   run pars_animal before running this function
  global kap kap_R g kT_J kT_M L_m L_T vT U_Hb U_Hp ep_min
  
  hold on
  
  pars_R = [kap; kap_R; g; kT_J; kT_M; L_T; vT; U_Hb; U_Hp];    
  f = 1;               % -, initiate scaled functional response

  while f > ep_min  % f at which maturation ceases at puberty

    L_i = f * L_m - L_T;                   % cm, ultimate length
    L = linspace(1e-4, L_i, 75);           % cm, lengths
    R = reprod_rate(L, f, pars_R);         % #/d

    %% actual plotting
    plot(L, R, 'r');
       
    f = f - 0.2;        % -, decrease functional response

  end
  title ('reproduction rate for f = 1, 0.8, 0.6, ..');
  xlabel('length, mm'); ylabel('reproduction rate, 1/d');
