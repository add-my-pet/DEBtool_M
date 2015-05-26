function [J_O, J_M, p_T]= flux (r)
  %% created 2000/10/20 by Bas Kooijman
  %% calculates fluxes, given the column-vector of specific growth rates r
  %%  admissible range: 0 < r < r_m as calculated in 'parscomp'
  %%  J_O matrix of organic fluxes (substrate, structure, reserve, product)
  %%    composition defined by n_O in 'par.m'
  %%  J_M matrix of mineral fluxes
  %%    composition defined by n_M in 'par.m'
  %%  p_T vector of dissipating heat

  global w_O m_Em jT_X_Am j_E_M j_E_J K kT_M kT_E g;
  global zeta mu_O mu_M eta_O y_E_X y_E_V kap n_M n_O;
  
  n_r = max(size(r)); 
  X_r = K*1e6;                     % substrate in feed set to large
  hT_a = 0;                        % aging set to zero

  f = g*(r+kT_M)./(kT_E - hT_a*(1 + g) - r); % -, scaled func. response
  X = K*f./(1 - f);                % M, substrate
  X_V = (X_r - X).*r./(jT_X_Am*f); % M, structure
  X_E = X_V.*f*m_Em;               % M, reserve
  h_d = hT_a*f*(1 + g)./(f + g);   % 1/d, spec death rate
  X_DV = X_V.*h_d./r;              % M, dead structure
  X_DE = X_E.*h_d./r;              % M, dead reserve
  X_P = [kT_M*g*ones(n_r,1), kT_E*f, (r + h_d)*g]*zeta'.*X_V./r;
                                   % M, product
  X_W =  w_O(2)*X_V + w_O(3)*X_E;  % g/l, living biomass
  X_DW = w_O(2)*X_DV + w_O(3)*X_DE;% g/l, dead biomass

  p_A = mu_O(3)*jT_X_Am*y_E_X*f.*X_V;     % kJ/d, assimilation power
  p_G = mu_O(3)*y_E_V*r.*X_V;             % kJ/d, growth power
  p_D = mu_O(3)*(j_E_M + j_E_J)*X_V + p_G*(1 - kap)/kap;
                                          % kJ/d, dissimilation power
  p = [p_A, p_D, p_G];                    % kJ/d, basic powers
  p_T = -((mu_O - mu_M*(n_M\n_O))*eta_O*p')'; % kJ/d, dissipating heat
  p_T = p_T;

  J_X = -(X_r-X).*r;                   % mol/d, flux of substrate
  J_V = X_V.*r;                        % mol/d, flux of structure
  J_E = X_E.*r;                        % mol/d, flux of reserves
  J_P = X_P.*r;                        % mol/d, flux of product
  
  J_O = [J_X, J_V, J_E, J_P];      % mol/d, fluxes of organic compounds
  J_M = J_O*(n_M\n_O)';            % mol/g, fluxes of mineral compounds

