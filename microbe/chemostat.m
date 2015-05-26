function [X_out, p_out, J_O, J_M] = chemostat (h, X_r)
  %% created 2000/10/20 by Bas Kooijman
  %% calculates chemostat equilibria, 
  %%    powers and organic and mineral fluxes
  %%  at throughput rates (vector h),
  %%  and a fixed concentration of substrate in the feed (scalar X_r)

  global w_O m_Em jT_X_Am j_E_M j_E_J K kT_M kT_E g hT_a;
  global zeta mu_O mu_M eta_O y_E_X y_E_V kap n_M n_O;
  
  n_h = max(size(h)); h = h(:);
  
  f = g*(h+kT_M)./(kT_E - hT_a*(1 + g) - h); % -, scaled func. response
  X = K*f./(1 - f);                % M, substrate
  X_V = (X_r - X).*h./(jT_X_Am*f); % M, structure
  X_E = X_V.*f*m_Em;               % M, reserve
  h_d = hT_a*f*(1 + g)./(f + g);   % 1/d, spec death rate
  X_DV = X_V.*h_d./h;              % M, dead structure
  X_DE = X_E.*h_d./h;              % M, dead reserve
  X_P = [kT_E*f, kT_M*g*ones(n_h,1), (h + h_d)*g]*zeta'.*X_V./h;
                                   % M, product
  X_W =  w_O(2)*X_V + w_O(3)*X_E;  % g/l, living biomass
  X_DW = w_O(2)*X_DV + w_O(3)*X_DE;% g/l, dead biomass

  X_out = [X, X_V, X_E, X_P, X_DV, X_DE, X_W, X_DW];
				   % pack densities for output
  
  p_A = mu_O(3)*jT_X_Am*y_E_X*f.*X_V;     % kJ/d, assimilation power
  p_G = mu_O(3)*y_E_V*h.*X_V;             % kJ/d, growth power
  p_D = mu_O(3)*(j_E_M + j_E_J)*X_V + p_G*(1 - kap)/kap;
                                          % kJ/d, dissimilation power
  p = [p_A, p_D, p_G];                    % kJ/d, basic powers
  p_T = -(mu_O - mu_M*(n_M\n_O))*eta_O*p';% kJ/d, dissipating heat

  p_out = [p_T', p];            % pack powers for output

  J_O = [-(X_r - X).*h, (X_V + X_DV).*h, (X_E + X_DE).*h, X_P.*h];
				% pack organic fluxes for output
  J_M = - J_O*(n_M\n_O)';       % pack mineral fluxes for output
  