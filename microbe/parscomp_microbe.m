%% script for 'pars', called from 'animal'; See: Kooijman 2000:

TC = tempcorr(T,T_1,Tpars);

jT_X_Am = TC*j_X_Am;   % mol/mol.d, temp corrected max spec feeding rate
kT_E = TC*k_E;         % 1/d, temp corrected reserve turnover
kT_M = TC*k_M;         % 1/d, temp corrected som maint costs
hT_a = TC*h_a;         % 1/d, temp corrected aging rate

w_O = n_O.'*[12; 1; 16; 14]; % g/mol, mol-weights for org. compounds

m_Em = y_E_X*jT_X_Am/kT_M;   % mol/mol, max reserve density
g = y_E_V/(kap*m_Em);        % -, energy investment ratio
l_d = g*kT_M/kT_E;           % -, scaled length at division

j_E_M = kT_M*y_E_V;    % mol/mol.d, spec somatic  maint costs
kT_J  = kT_M*(1 - kap)/kap;  % 1/d, spec maturity maint coeff 
j_E_J = kT_J*y_E_V;    % mol/mol.d, spec maturity maint costs

r_m = (kT_E - kT_M*g)/(1 + g);  % 1/d, max spec growth rate
h_m = (kT_E - hT_a*(1 + g) - g*kT_M*(1 + K/X_r))/(1 + g*(1 + K/X_r));
		                % 1/d, max throughput rate
mu_O = (mu_T + mu_M)*(n_M\n_O); % kJ/mol, chemical potentials of organics

eta_O= zeros(4,3);                % mass-energy couplers
eta_O(1,1) = -y_X_E/mu_O(3);      % mol/kJ, substrate/assim
eta_O(2,3) = -y_V_E/mu_O(3);      % mol/kJ, structure/growth
eta_O(3,:) = [1 -1 -1]/mu_O(3);   % mol/kJ, res/(assim, dissip, growth)
eta_O(4,:) = zeta/(m_Em*mu_O(3)); % mol/kJ, prod/(assim, dissip, growth)
	