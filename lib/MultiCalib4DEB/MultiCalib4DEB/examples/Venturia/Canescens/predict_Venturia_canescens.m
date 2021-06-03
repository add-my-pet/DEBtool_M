function [prdData, info] = predict_Venturia_canescens(par, data, auxData)
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);

  if s_j >= 1
    info = 0; prdData = []; return;
  end

  % compute temperature correction factors
  TC = tempcorr(temp.ab, T_ref, T_A); % all data at 25 C
  vT = v * TC; kT_J = k_J * TC; kT_M = k_M * TC; pT_M = p_M * TC; pT_Am = p_Am * TC; kT_EV = k_EV * TC; kT_E = k_E * TC;
  
  % zero-variate data

  % life cycle
  pars_tj = [g k v_Hb v_He s_j kap kap_V];
  [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(pars_tj, f);
  if info == 0
    prdData = []; return;
  end
  
  % initial
  pars_UE0 = [V_Hx; g; k_J; k_M; v]; % compose parameter vector
  E_0 = p_Am * initial_scaled_reserve(f, pars_UE0); % J, initial energy
  Wd_0 = w_E * E_0/ mu_E; % g, initial dry weight
 
  % pre-birth  (start of absorbption)
  pars_th = [g; k; l_T; v_Hx; v_Hb]; % compose parameter vector
  [t_h, t_x, l_h, l_x] = get_tp(pars_th, f); % -, scaled length at birth at f
  
  % hatch (start of feeding)
  L_h = L_m * l_h;                  % cm, structural length at hatch at f
  Wd_h = L_h^3 * d_V * (1 + f * w); % g, dry weight at hatch
  aT_h = t_h/ kT_M;                  % d, age at hatch at f and T

  % pupation
  L_j = L_m * l_j;                  % cm, structural length at metam
  tT_j = (t_j - t_b)/ kT_M;         % d, time since birth at metam
  Wd_j = L_j^3 * d_V * (1 + f * w); % g, dry weight at pupation, excluding reprod buffer at pupation
  E_Rj = v_Rj * (1 - kap) * g * E_m * L_j^3; % J, reproduction buffer at pupation
  Wd_j = Wd_j + E_Rj * w_E/ mu_E;   % g, dry weight including reprod buffer
  s_M = l_j/ l_b;                   % -, acceleration factor

  % emergence
  L_e = L_m * l_e;                      % cm, structural length at emergence
  E_e = E_Rj + u_Ee * g * E_m * L_m^3;  % J, reserve at emergence
  Wd_e = L_e^3 * d_V + w_E * E_e/ mu_E; % g, dry weight at emergence
  tT_e = (t_e - t_j)/ kT_M;             % d, time since pupation at emergence
 
  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC;                  % d, mean life span at T
  
  % pack to output
  prdData.ab = aT_h;
  prdData.tj = tT_j;
  prdData.te = tT_e;
  prdData.am = aT_m;
  prdData.Wd0 = Wd_0;
  prdData.Wdb = Wd_h;
  prdData.Wdj = Wd_j;
  prdData.Wde = Wd_e;
  
  % uni-variate data
  
  % time- weight data for larva
  ELE_0 = [f * E_m * L_h^3; L_h; 0]; % initial state vector
  pT_J = kT_J * E_Hb;                % J/d, maturity maintenance from birth till pupation
  [t ELE] = ode45(@dget_ELE, tWd(:,1), ELE_0, [], f, kT_M, vT/ L_h, pT_J, pT_Am/ L_h, E_m, g, kap);
  EWd = ELE(:,2).^3 * d_V  + (ELE(:,1)+ELE(:,3)) * w_E/ mu_E; % g, dry weight
  
  % time - weight data for pupa
  VHEL_0 = [L_j^3; 0; f * E_m * L_j^3; 1e-4];      % state at start pupation 
  [t VHEL] = ode45(@dget_VHEL, tWdj(:,1), VHEL_0, [], kT_J, kT_EV, vT, E_m, L_m * s_M, kap, g, kap_V);
  V_l = VHEL(:,1); E = VHEL(:,3); L = VHEL(:,4); V = L.^3; e = E ./ V/ E_m;  % -, scaled reserve density
  EWd_j = (V_l + V) * d_V + (E + E_Rj ) * w_E/ mu_E; % g, dry weight of pupa  
  
  % Reproduction, progeny since wasp emergence
%   pT_S = pT_M * L_e^3 + E_He * kT_J; % J/d, maint rate (som + mat)
%   pT_A = pT_S;                       % assim equals maint (see discussion)
%   EE_R0 = [E_e, 0];                  % reserves and number of eggs at emergence 
%   [t EE_R] = ode45(@dget_EE_R, tN(:,1), EE_R0, [], pT_A, pT_S, kT_E);
%   EN = EE_R(:,2) * kap_R/ E_0;       % #, cumulative number of eggs
  EN = kap_R * E_Rj * (1 - exp(- k_E * tN(:,1)))/ E_0; % #, cumulative number of eggs
  
  % pack to output
  prdData.tWd = EWd;
  prdData.tWdj = EWd_j;
  prdData.tN = EN;
  
end

%% subfunctions

function dELE = dget_ELE(t, ELE, f, k_M, k_E, p_J, p_Am, E_m, g, kap)
      % larval development
      % t: time since birth
      % p_Am: [p_Am] = {p_Am}/ L_b
      
      % unpack variables
      E  = ELE(1); % J, reserve
      L  = ELE(2); % cm, structural length
      %E_R = ELE(3); % J, reproduction buffer
      
      V = L^3;                          % cm^3, structural volume
      e = E/ V/ E_m;                    % -, scaled reserve density
      r = (e * k_E - g * k_M)/ (e + g); % 1/d, specific growth rate
      p_C = E * (k_E - r);             % J/d, mobilisation rate
      
      dE = f * p_Am * V - p_C;          % J/d, change in reserve
      dL = r * L/ 3;                    % cm/d, change in length
      dE_R = (1 - kap) * p_C - p_J;     % J/d, change in reprod buffer

      dELE = [dE; dL; dE_R];   
end
       
               
function dVHEL = dget_VHEL(t, VHEL, k_J, k_E, v, E_m, L_m, kap, g, kap_V)
      % pupal development
      % t: d, time since pupation
      %   y_EV: yield of reserve of imago on structure of larva
       
      % unpack variables
      V  = VHEL(1); % cm^3, structural volume of larva
      H  = VHEL(2); % J, maturity 
      E  = VHEL(3); % J, reserve of larva
      L  = VHEL(4); % cm, structural length of imago
            
      dV = - V * k_E;                     % cm^3/d, change larval structure
      e = E/ L^3/ E_m;                    % -, scaled reserve density
      r = v * (e/ L - 1/ L_m)/ (e + g);   % 1/d, specific growth rate
      p_C = E * (v/ L - r);               % J/d, mobilisation rate
      dE = dV * g * E_m * kap * kap_V - p_C; % J/d, change in reserve
      dL = r * L/ 3;                      % cm/d, change in length
      dH = (1 - kap) * p_C - k_J * H;     % J/d, change in maturity
      
      dVHEL = [dV; dH; dE; dL];
end
  

function dEE_R = dget_EE_R(a, EE_R, p_A, p_S, k_E)
        % change in reserves during the wasp life
        % a: d, time since wasp emergence
        
        %unpack variables
        E = EE_R(1); % J, reserves of imago
         
        dE = p_A - k_E * E;   % J/d, change in reserve
        dE_R = max(0,k_E * E - p_S); % J, cumulative investment in eggs
         
        dEE_R = [dE; dE_R];
end
 

