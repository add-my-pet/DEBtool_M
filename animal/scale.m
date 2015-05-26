%% scale
% Gets quantities as function of the zoom factor

%%
function R = scale (z,j)
  % created 2000/11/02 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % function R = <../scale.m *scale*> (z,j)
  
  %% Description
  % Gets body weight, structural volume, egg weight, O2-flux, N-waste flux, min food density,
  % max ingestion rate, max growth rate, von Bert growth rate, min incubation time, 
  % min juvenile period, max starvation time, max reproduction rate as function of the zoom factor.
  %
  % Input
  %
  % * z: vector of zoom factors,
  % * j: optional scalar with variable identification to reduce computation time
  %
  % Output
  %
  % * matrix with the zoom factor in the rows and in the columns:
  % *  (:,1)  weight                     (:,2)  structural volume
  % *  (:,3)  egg weight                 (:,4)  dioxygen flux
  % *  (:,5)  N-waste flux               (:,6)  min food density
  % *  (:,7)  max ingestion rate         (:,8)  max growth rate
  % *  (:,9)  von Bert growth rate       (:,10) min incubation period
  % *  (:,11) min juv period             (:,12) max starvation time
  % *  (:,13) max reproduction rate
  
  %% Remark
  % Run pars_animal to fill globals, but
  % make sure that report_animal in pars_animal is outcommented
  
  %% Example of use
  % pars_animal; result = scale (5, 1)

  global L_m L_T l_T JT_E_Am R_m JT_X_Am  
  global d_O w_O vT n_O n_M eta_O 
  global pT_M pT_Am K k kT_J kT_M
  global kap kap_R E_G m_Em V_Hb v_Hb v_Hp U_Hb U_Hp
  
  g = E_G * vT/ kap/ pT_Am;
  
  if ~exist('j','var')
    j = 0;
  end
  
  z = z(:); nz = max(size(z)); % unravel the nz zoom factors
  R = zeros(nz,13); % initialize output

  f = 1; % -, set scaled functional response to maximum
  
  % structural volume, cm^3
  l = f - l_T ./ z; % set scaled length to maximum
  L = z * L_m .* l; V = L.^3; 
  R(:,2) = V;
  
  % body weight, g
  W_m = V * d_O(2) .* (1 + z * f * m_Em * w_O(3)/ w_O(2)); % g, maximum dry weight
  R(:,1) = W_m; % g, body dry weight

  if j == 0 || j == 2 || j == 12
    %% egg weight, g
    for i = 1:nz
      pars_E0 = [V_Hb * z(i)^2; g/ z(i); kT_J; kT_M; vT];
      [U_E0 L_b info] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
      if info ~= 1
        fprintf('warning: invalid parameter value combination for egg \n')
      end
      M_E0 = z(i) * JT_E_Am .* U_E0;  % mol, initial reserve (of embryo)
      W_0 = M_E0 * w_O(3);            % g, initial reserve (of embryo)
      R(i,3) = w_O(3) * W_0;
    end

    %% max reproduction rate, #/d 
    for i = 1:nz
      pars_R = [kap; kap_R; g/ z(i); kT_J; kT_M; L_T; vT; U_Hb * z(i)^2; U_Hp * z(i)^2];
      R_m = reprod_rate(L(i), f, pars_R); % d^-1
      R(i,13) = R_m; % #/d
    end
  end
  
  if j == 0 || j == 3 || j == 4
    % powers, kJ/d
    for i = 1:nz
      p_ref = z(i)^3 * pT_Am * L_m^2;        % max assimilation power at max size
      pars_pow = [kap; kap_R; g/ z(i); kT_J; kT_M; L_T; vT; U_Hb * z(i)^2; U_Hp * z(i)^2];
      pACSJGRD = p_ref * scaled_power(L(i), f, pars_pow, 1e-4, 1e-4); % powers
      pADG = pACSJGRD(:,[1 7 5])';  % assimilation, dissipation, growth power
      J_O = eta_O * pADG;     % J_X, J_V, J_E, J_P in rows, A, D, G in cols
      J_M = - (n_M\n_O) * J_O;      % J_C, J_H, J_O, J_N in rows, A, D, G in cols
      R(i,[4 5]) = [-J_M(3), J_M(4)];  % mol/d, dioxygen, N-waste flux    
    end
  end
  
  if j == 0 || j == 5
    % min food density, mol/cm^3
    R(:,6) = z * K .* L * pT_M/ pT_Am ./ (z - L * pT_M/ pT_Am);
  end
  
  if j == 0 || j == 6
    % max ingestion rate, mol/d
    R(:,7) = JT_X_Am * L .* L .* z;
  end
  
  if j == 0 || j == 7
    % max growth rate
    R(:,8) = (4/ 27) * kT_M * g./ (z + g) .* (L_m * (z - l_T)) .^ 3; % cm^3/d
  end
  
  if j == 0 || j == 8 || j == 9 || j == 10
    % von Bertalanffy growth rate, 1/d
    r_B = 1./ (3/ kT_M + 3 * L_m/ vT .* z);
    R(:,9) = r_B; % 1/d

    % juvenile period, d
    for i = 1:nz
      pars_tp = [g/ z(i); k; l_T; v_Hb; v_Hp];
      [t_p t_b] = get_tp(pars_tp, f); % -, scaled age at puberty
      R(i,[10 11]) = [t_b t_p]/ kT_M;
    end
  end
  
  if j == 0 || j == 11
    % starvation time, d
    t = L/(vT * kap);
    R(:,12) = t;
  end