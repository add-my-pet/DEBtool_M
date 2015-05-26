%% compound parameters that typically occur in predict_my_pet files
% Selected copy-paste from parscomp & statistics
 
  if exist('z', 'var') == 1 && exist('p_M', 'var') == 1 && exist('kap', 'var') == 1
    p_Am = z * p_M/ kap;             % J/d.cm^2, {p_Am} max spec assimilation flux
  end
  if exist('p_Am', 'var') == 1  && exist('mu_E', 'var') == 1 
    J_E_Am = p_Am/ mu_E;             % mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux
  end
  if exist('p_M', 'var') == 1 && exist('E_G', 'var') == 1 
    k_M = p_M/ E_G;                  % 1/d, somatic maintenance rate coefficient
  end
  if exist('k_J', 'var') == 1 && exist('k_M', 'var') == 1 
    k = k_J/ k_M;                    % -, maintenance ratio
  end
  if exist('p_Am', 'var') == 1 && exist('kap_X', 'var') == 1 
    p_Xm = p_Am/ kap_X;            % J/d.cm^2, max spec feeding power
  end
  
  if exist('d_V', 'var') == 1 && exist('w_V', 'var') == 1 
    M_V = d_V/ w_V;                  % mol/cm^3, [M_V], volume-specific mass of structure
  end
  if exist('M_V', 'var') == 1 && exist('mu_V', 'var') == 1 && exist('E_G', 'var') == 1 
    kap_G = M_V * mu_V/ E_G;         % -, growth efficiency
  end
  if exist('mu_E', 'var') == 1 && exist('M_V', 'var') == 1 && exist('E_G', 'var') == 1 
    y_V_E = mu_E * M_V/ E_G;         % mol/mol, yield of structure on reserve
  end
  if exist('y_V_E', 'var') == 1 
    y_E_V = 1/ y_V_E;                % mol/mol, yield of reserve on structure
  end
  
  if exist('p_Am', 'var') == 1 && exist('v', 'var') == 1 
    E_m = p_Am/ v;                   % J/cm^3, [E_m] reserve capacity 
  end
  if exist('y_E_V', 'var') == 1 && exist('E_m', 'var') == 1 && exist('E_G', 'var') == 1 
    m_Em = y_E_V * E_m/ E_G;         % mol/mol, reserve capacity 
  end
  if exist('E_G', 'var') == 1 && exist('kap', 'var') == 1 && exist('E_m', 'var') == 1 
    g = E_G/ kap/ E_m;               % -, energy investment ratio
  end
  if exist('m_Em', 'var') == 1 && exist('w_E', 'var') == 1 && exist('w_V', 'var') == 1 
    w = m_Em * w_E/ w_V;             % -, contribution of reserve to weight
  end
  
  if exist('v', 'var') == 1 && exist('k_M', 'var') == 1 && exist('g', 'var') == 1 
    L_m = v/ k_M/ g;                 % cm, maximum structural length
  end
  if exist('p_T', 'var') == 1 && exist('p_M', 'var') == 1 
    L_T = p_T/ p_M;                  % cm, heating length (also applies to osmotic work)
  end
  if exist('L_T', 'var') == 1 && exist('L_m', 'var') == 1 
    l_T = L_T/ L_m;                  % -, scaled heating length
  end
  
  if exist('E_Hb', 'var') == 1 && exist('mu_E', 'var') == 1 
    M_Hb = E_Hb/ mu_E;               % mol, maturity at birth  
  end
  if exist('M_Hb', 'var') == 1 && exist('J_E_Am', 'var') == 1 
    U_Hb = M_Hb/ J_E_Am;             % cm^2 d, scaled maturity at birth
  end
  if exist('U_Hb', 'var') == 1 && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    u_Hb = U_Hb * g^2 * k_M^3/ v^2;  % -, scaled maturity at birth
  end
  if exist('U_Hb', 'var') == 1 && exist('kap', 'var') == 1 
    V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
  end
  if exist('V_Hb', 'var') == 1 && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    v_Hb = V_Hb * g^2 * k_M^3/ v^2;  % -, scaled maturity at birth
  end
  if exist('E_Hj', 'var') == 1 && exist('mu_E', 'var') == 1 
    M_Hj = E_Hj/ mu_E;               % mol, maturity at end acceleration 
  end
  if exist('M_Hj', 'var') == 1 && exist('J_E_Am', 'var') == 1 
    U_Hj = M_Hj/ J_E_Am;             % cm^2 d, scaled maturity at end acceleration 
  end
  if exist('U_Hj', 'var') == 1 && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    u_Hb = U_Hj * g^2 * k_M^3/ v^2;  % -, scaled maturity at end acceleration 
  end
  if exist('U_Hj', 'var') == 1 && exist('kap', 'var') == 1 
    V_Hj = U_Hj/ (1 - kap);          % cm^2 d, scaled maturity at end acceleration 
  end
  if exist('V_Hj', 'var') == 1 && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    v_Hj = V_Hj * g^2 * k_M^3/ v^2;  % -, scaled maturity at end acceleration 
  end
  if exist('E_Hp', 'var') == 1 && exist('mu_E', 'var') == 1 
    M_Hp = E_Hp/ mu_E;               % mol, maturity at puberty
  end
  if exist('M_Hp', 'var') == 1 && exist('J_E_Am', 'var') == 1 
    U_Hp = M_Hp/ J_E_Am;             % cm^2 d, scaled maturity at puberty 
  end
  if exist('U_Hp', 'var') == 1 && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    u_Hp = U_Hp * g^2 * k_M^3/ v^2;  % -, scaled maturity at puberty  
  end
  if exist('U_Hp', 'var') == 1 && exist('kap', 'var') == 1 
    V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
  end
  if exist('V_Hp', 'var') == 1  && exist('g', 'var') == 1 && exist('k_M', 'var') == 1 && exist('v', 'var') == 1 
    v_Hp = V_Hp * g^2 * k_M^3/ v^2;  % -, scaled maturity at puberty
  end