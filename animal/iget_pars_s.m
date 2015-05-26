%% iget_pars_s
% Obtains growth and reprod data from compound parameters for multiple feeding levels 

%%
function [p, U] = iget_pars_s(par,f)
  %  created by Bas Kooijman at 2006/10/08
  
  %% Syntax
  % [p, U] = <../iget_pars_s.m *iget_pars_s*> (par,f)
  
  %% Description
  % Obtains growth and reprod data from compound parameters for multiple feeding levels 
  % Maturity and somatic maitenance rate coefficients might differ.
  %
  % Input
  %
  % * par: 8-vector with
  %     1 kap, -, fraction allocated to som maint + growth
  %     2 kapR, -, fraction of energy allocated to reprod fixed in embryo
  %                this parameter is set in fnget_pars_s
  %     3 g, -, energy investment ratio
  %     4 kJ, d^-1, maturity maintenance rate coefficient
  %     5 kM, d^-1, somatic maintenance rate coefficient
  %     6 v, mm/d, energy conductance
  %     7 Hb, d.mm^2, scaled maturity at birth M_H^b/{J_EAm}
  %     8 Hp, d.mm^2, scaled maturity at puberty M_H^p/{J_EAm}
  %
  % * f: n-vector with scaled functional responses
  %
  % Output
  %
  % * p: (n,7)-matrix with quantities (n > 1). The columns are:
  %
  %    1 f, -, scaled functioal response
  %    2 L_b, mm, length at birth
  %    3 L_p, mm, length at puberty
  %    4 L_i,mm, ultimate length
  %    5 \dot{r}_B, d^-1, von Bertalanffy growth rate
  %    6 \dot{R}_i, d^-1, maximum reproduction rate
  %    7 kapR, -, reproduction efficiency
  %
  % * U:(n,3)-matrix with columns 
  %    U^0 = M_E^0/\{\dot{J}_{EAm}\},
  %    U^b = M_E^b/\{\dot{J}_{EAm}\},
  %    U^p = M_E^p/\{\dot{J}_{EAm}\}.
  
  %% Remarks
  % See <get_pars_s.html *get_pars_s*> for inverse mapping
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>
  
  n = length(f);
  p = zeros(n,7); U = zeros(n,3); % initiate output

  for i = 1:n
    [pn, Un] = iget_pars_r(par,f(i)); % pn: f Lb Lp Li ab rB Ri kapR
    p(i,:) = pn([1 2 3 4 6 7 8])'; U(i,:) = Un';
  end
