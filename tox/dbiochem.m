function dC = dbiochem (t, Ct)
  %  differential equations for the biochem model
  %  Martina Vijver/ Bas Kooijman
  %  2002/02/05

  global k_pi k_si k_ai k_as k_sa k_ap k_pa k_ps k_sp k_0 k_V k_e l V_p M_s

  %% unpack state vector
  l = Ct(1); C_Ms = Ct(2); C_Mp = Ct(3); C_Ma = Ct(4); C_Mi = Ct(5);

  dl = - k_V/ 3;
  
  dC_Ms = (k_ps/ V_p) * C_Mp - (k_sp/ M_s) * C_Ms;

  dC_Mp = -k_0 * C_Mp + (k_ap/ V_p) * C_Ma - (k_pa/ V_p) * C_Mp +\
      - (k_ps/ V_p) * C_Mp + (k_sp/ M_s) * C_Ms;
				% PS: think about flux to annelid
  dC_Ma = -k_0 * C_Ma - (k_ap/ V_p) * C_Ma + (k_pa/ V_p) * C_Mp;
				% PS: think about flux to annelid
  dC_Mi = (k_ai * C_Ma + k_pi * C_Mp + k_si * C_Ms - k_e * C_Mi - 3 * dl)/l ;

  % pack output
  dC = [dl dC_Ms dC_Mp dC_Ma dC_Mi];
