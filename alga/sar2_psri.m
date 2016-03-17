%% sar2_psri
% obtains specific assimilation rate of carbohydrates for oxygenic photosynthesis and flux of captured, but not-processed, photons

%%
function [j_HCO j_L_ info] = sar2_psri(j_L, X_C, X_O, r, p, n_V, j_H)
  % created 2011/07/09 by Bas Kooijman, modifoed 2011/07/18
  
  %% Syntax
  % [j_HCO j_L_ info] = <../sar2_psri.m *sar2_psri*> (j_L, X_C, X_O, r, p, n_V, j_H)

  %% Description
  % The function obtains the specific assimilation rate of carbohydrates for oxygenic photosynthesis and the flux of captured, 
  %    but not processed photons, which fuel fluorescense. 
  % It accounts for photo-synthesis, photo-respiration and photo-inhibition. 
  % Photons and carbon dioxide, as well as photons and dioxygen, are treated as parallelly processed complemantary compounds, 
  %    while carbon dioxide and dioxygen are substitutable compounds. 
  % Photo-inhbition occurs when photons bind to a photon-SU complex; 
  %  recovery from this situation occurs when one of the photons is released. 
  % The intracellular concentration of carbon dioxide and dioxygen is affected by growth and maintenance. 
  % Maintenance is fuelled by corbohydrates only, in terms of O2 and CO2. 
  % The stoichiometry of the growth process assumes NO3 as complementary compound.
  %
  % Input:
  %
  % * j_L, X_C, X_O, X_N: scalars with light flux (times absorption eff.), CO2, O2 and nitrogen concentrations
  % * r: scalar with initial estimate for r
  % * p: 10-vector with parameters
  %
  %    -1  affinity for carbon dioxide (dm^3/d.mol V)
  %    -2  affinity for dioxygen (dm^3/d.mol V)
  %    -3  maximum net specific carbon fixation (1/d)
  %    -4  maximum net specific photo respiration (1/d)
  %    -5  rate of carbon dioxide exchnage with environment (1/d)
  %    -6  rate of dioxygen exchnage with environment (1/d)
  %    -7  inhibition repair rate (1/d)
  %    -8  specific maintenance for carbohydrate (mol/d.mol)
  %    -9  yield of structure on hydrocarbon (mol/mol)
  %    -10 volume-specific mass of structure, mol/cm^3
  %
  % * n_V: 4-vector with chemical indices of structure; n_V(1) = 1
  % * j_H: optional scalar with initial estimate for j_H
  %
  % Output:
  %
  % * j_HCO: 3-vector with spec assimilation fluxes of CH2O, CO2, O2
  % * j_L_: salar with non-processed photons that are captured by the antenna
  % * info: scalar with numerical failure (0) or success (1)
  
  %% Example of use
  % see <../mydata_sar_psri.m *mydata_sar_psri*>

  b_C      = p( 1); % dm^3/d.mol V, affinity for CO2
  b_O      = p( 2); % dm^3/d.mol V, affinity for O2
  k_H      = p( 3); % 1/d, max net spec carbon fixation
  k_C      = p( 4); % 1/d, max net spec photo respiration
  k_C_env  = p( 5); % 1/d, rate of CO2 exchange with environment
  k_O_env  = p( 6); % 1/d, rate of O2 exchange with environment
  k_L      = p( 7); % 1/d, inhibition-repair rate
  j_HM     = p( 8); % mol/d.mol, maint for carbohydrates; zero maint for NO3
  y_VH     = p( 9); % mol/mol, yield of structure on CH2O
  M_V      = p(10); % mol/cm^3, [M_V] vol-spec mass of structure

  n_HV = n_V(2); n_OV = n_V(3); n_NV = n_V(4); % -, chemical indices of structure

  % set help quantities
  y_CV = 1 - y_VH; % mol/mol, yield of CO2 on structure
  y_OV = y_CV - (n_HV - 2 * n_OV + 6 * n_NV)/ 4; % mol/mol, yield of O2 on structure with NO_3 and CH_2O as reserves
  dj_C = - M_V * b_C/ (k_O_env + r); % d j_C/ d j_H
  dj_O =   M_V * b_O/ (k_O_env + r); % d j_O/ d j_H

  % bypass initial estimate if j_H is specified to allow for continuation
  if exist('j_H', 'var') == 0 % make sure that j_H exists
    j_H = [];
  end
  if isempty(j_H) % mol/d.mol, total CO2 fixation rate, initial estimate
    j_C = (k_C_env * X_C + M_V * (j_HM + r * y_CV)) * b_C/ (k_C_env + r); % mol/d.mol start value for j_C with j_H = 0
    j_H = 1/(1/ k_H + 1/j_C + 1/j_L - 1/(j_C + j_L)); % mol/d.mol start value of j_H  with j_O = 0 and no inhibition
  end

  % initiate Newton Raphson procedure
  info = 1;  % indicate for successful convergence
  i = 0;     % step counter
  F = 1;     % function of j_H for which the root is at j_H; initial value to make sure that NR starts
  while abs(F) > 1e-8 && i < 20
    j_C =  k_C_env * X_C * b_C/ (k_C_env + r) - dj_C * (j_HM + r * y_CV - j_H); % mol/d.mol  spec CO2 flux that arrives at PSU
    j_O =  k_O_env * X_O * b_O/ (k_O_env + r) - dj_O * (j_HM + r * y_OV - j_H); % mol/d.mol  spec O2 flux that arrives at PSU
    j_CO = j_C + j_O; dj_CO = dj_C + dj_O; j_d = j_C - j_O; dj_d = dj_C - dj_O; j_LCO = j_L + j_CO; % help quantities
    F = j_H - j_d/ (1 + j_C/ k_H + j_O/ k_C + (j_CO^2/ j_L + j_L^2/ k_L)/ j_LCO);
    dF = 1 - j_H * dj_d/ j_d  + j_H^2 * (dj_C/ k_H + dj_O/ k_C + 2 * j_CO * dj_CO/ j_L/ j_LCO - ...
        dj_CO * (j_L^2/ k_L + j_CO^2/ j_L)/ j_LCO^2)/ j_d; % d F/ d J_H
    j_H = j_H - F/ dF; % Newton Raphson step
    i = i + 1;         % increase step counter
  end 
  j_HCO = [j_H; j_C; j_O]; % pack first output
  j_L_ = j_L - (j_L + j_CO^2/j_LCO) * j_H/ j_d; % mol/d.mol, non-processed captured photons

  if  abs(F) > 1e-8 || i == 20
    fprintf(['Warning in sgr2_psri: no convergence within ', num2str(i),' steps\n'])
    info = 0; % indicate for failure of convergence
  end