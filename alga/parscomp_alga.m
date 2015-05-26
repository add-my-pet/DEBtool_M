% script for 'pars', called from 'alga';
% created: 2002/04/09 by Bas Kooijman

TC = tempcorr(T,T_1,Tpars);

jT_EN_Am = TC * j_EN_Am;      % mol/mol.d, temp corrected max spec N-res assim
jT_EP_Am = TC * j_EP_Am;      % mol/mol.d, temp corrected max spec P-res assim
kT_E = TC * k_E;              % 1/d, temp corrected reserve turnover
jT_EN_M = TC * k_MN * y_EN_V; % 1/d, temp corrected som maint costs for N-res
jT_EP_M = TC * k_MP * y_EP_V; % 1/d, temp corrected som maint costs for P-res

  