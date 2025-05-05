%% get_kapRtot
% calculates the overall conversion efficiency mother to neonate

%%
function kap_Rtot = get_kapRtot(p, f)
  % created 2024/07/17 by Bas Kooijman
  %
  %% Syntax
  % [kap_Rtot, info] = <../get_kapRtot.m *get_kapRtot*> (p, f)
  
  %% Description
  % calculates overall conversion efficiency from mother to neonate: kapRtot = kap_R * L_b^3 * ([M_V] * mu_V + [E_m])/ E_0
  %
  % Input
  %
  % * p: (n,6)-matix with parameters in columns: [E_0,kap_R,L_b,E_m,mu_V,M_V'] 
  % * f: optional scalar with scaled functional response (default 1)
  %
  % Output
  %
  % * kap_Rtot: (n,1) matrix with overall conversion efficiency from mother to neonate
  
  %% Remarks
  %
  
  %% Example of use
  %  kap_Rtot = get_kapRtot(read_stat(select('Aves'),{'E_0','kap_R','L_b','E_m','mu_V','M_V'}));
  %  shstat_options('default');shstat_options('x_transform','none');shstat_options('y_label','on'); 
  %  shstat(kap_Rtot,'','overall reprod efficiency'); xlabel('kap_R^{tot}, -'); 

    
  if ~exist('f','var') || isempty(f)
    f = 1; % abundant food
  end
  n = size(p,1); kap_Rtot = NaN(n,1);

  for i = 1 : n
    % unpack parameters
    E_0   = p(i,1); % J, initial reserve
    kap_R = p(i,2); % -, reproduction efficiency
    L_b   = p(i,3); % cm, struct length at birth
    E_m   = p(i,4); % J/cm^3, max reserve capacity
    mu_V  = p(i,5); % J/mol, chemical potential of structure
    M_V   = p(i,6); % mol/cm^3, [M_V] molar density of 

    kap_Rtot(i) = kap_R * L_b^3 * (M_V * mu_V + E_m)/ E_0;
  end
end