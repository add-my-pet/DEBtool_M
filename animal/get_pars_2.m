%% get_pars_2
% Obtains 2 DEB parameters from 2 data points at abundant food

%%
function par = get_pars_2(data, fixed_par, chem_par)
  % created 2015/01/16 by Bas Kooijman
  
  %% Syntax
  % par = <../get_pars_2.m *get_pars_2*> (data, fixed_par, chem_par)
  
  %% Description
  % Obtains 2 DEB parameters from 2 data points at abundant food
  %
  % Input
  %
  % * data: 2-vector with zero-variate data
  %
  %    d_V: g/cm^3, specific density of structure
  %    W_m: g, maximum wet weight
  %
  % * fixed_par: optional 4 vector with v, kap, p_M, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * par: 2-vector with DEB parameters
  %
  %    p_Am: J/d.cm^2, {p_Am}, max specific assimilation rate
  %    E_G: J/cm^3, [E_G] specific cost for structure
    
  %% Remarks
  % Assumes absence of acceleration
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See also 
  %  <get_pars_2a.html *get_pars_2a*>,
  %  <get_pars_3.html *get_pars_3*>,
  %  <get_pars_4.html *get_pars_4*>,
  %  <get_pars_5.html *get_pars_5*>,
  %  <get_pars_6.html *get_pars_6*>,
  %  <get_pars_6a.html *get_pars_6a*>,
  %  <get_pars_7.html *get_pars_7*>,
  %  <get_pars_8.html *get_pars_8*>,
  %  <get_pars_9.html *get_pars_9*>.
  
  %% Example of use
  %  See <../mydata_get_par_2_9.m *mydata_get_par_2_9*>
  
  %  assumptions:
  %  abundant food (f=1)
  %  absence of acceleration
  %  {p_T} = 0     % J/d.cm^2, surf-spec som maint
  if ~exist('fixed_par', 'var')
     v = 0.02;            % cm/d, energy conductance
     kap = 0.8;           % -, allocation fraction to soma = growth + somatic maintenance
     p_M = 18;            % J/d.cm^3, [p_M], vol-specific somatic maintenance
     kap_G = 0.80;        % -, growth efficiency
  else % v; kap; p_M; E_G; k_J
     v    = fixed_par(1); % cm/d, energy conductance
     kap  = fixed_par(2); % -, allocation fraction to soma = growth + somatic maintenance
     p_M  = fixed_par(3); % J/d.cm^3, [p_M], vol-specific somatic maintenance
     kap_G= fixed_par(4); % -, growth efficiency
  end
  
  if exist('chem_par', 'var') == 0
  %  C:H:O:N = 1:1.8:0.5:0.15
     w_V = 23.9;   % g/C-mol, molecular weight of structure
     w_E = 23.9;   % g/C-mol, molecular weight of reserve
     mu_V = 5E5;   % J/C-mol, chemical potential of structure
     mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
  else
     w_V = chem_par(1); w_E = chem_par(2); mu_V = chem_par(3); mu_E = chem_par(4);
  end

  % unpack data 
  d_V = data(1); % g/cm^3, specific density of structure
  W_m = data(2); % g, maximum wet weight
  
  E_G = d_V * mu_V/ kap_G/ w_V; % J/cm^3, [E_G] costs for structure
  p_Am0 = W_m^(1/3) * p_M/ kap; % J/d.cm^2, starting value for p_Am
  A = p_M^3 * W_m/ kap^3; B = w_E/ v/ d_V/ mu_E; % set compound pars
  p_Am = fzero(@(p_Am) A - p_Am^3 * (1 + B * p_Am), p_Am0); % solve W_m = L_m^3 (1 + w)
  par = [p_Am; E_G]; % pack output 

end