%% predict_my_pet_mytox
% Obtains predictions with toxicant, using parameters and data

%%
function [prdData, info] = predict_my_pet(par, data, auxData)
  
  %% Syntax
  % [prdData, info] = <../predict_my_pet_mytox.m *predict_my_pet_mytox*>(par, data, auxData)
  
  %% Description
  % Obtains predictions, using parameters and data
  %
  % Input
  %
  % * par: structure with parameters (see below)
  % * data: structure with data (not all elements are used)
  % * auxData : structure with temp data and other potential environmental data
  %  
  % Output
  %
  % * prdData: structure with predicted values for data
  % * info: identified for correct setting of predictions (see remarks)
  
  %% Remarks
  % Template for use in add_my_pet.
  % The code calls <parscomp_st.html *parscomp_st*> in order to compute
  % scaled quantities, compound parameters, molecular weights and compose
  % matrixes of mass to energy couplers and chemical indices.
  % With the use of filters, setting info = 0, prdData = {}, return, has the effect
  % that the parameter-combination is not selected for finding the
  % best-fitting combination; this setting acts as customized filter.
  
  %% Example of a costumized filter
  % See the lines just below unpacking
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
    
  % customized filters for allowable parameters of the standard DEB model (std)
  % for other models consult the appropriate filter function.
  filterChecks = k * v_Hp >= f_tL^3 || ...         % constraint required for reaching puberty with f_tL
                 ~reach_birth(g, k, v_Hb, f_tL);   % constraint required for reaching birth with f_tL
  
  if filterChecks  
    info = 0;
    prdData = {};
    return;
  end  
  
  % compute temperature correction factors
  TC_am = tempcorr(temp.am, T_ref, T_A);
  TC_tL = tempcorr(temp.tL, T_ref, T_A);

% zero-variate data

  % life cycle
  pars_tp = [g; k; l_T; v_Hb; v_Hp];               % compose parameter vector
  [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); % -, scaled times & lengths at f
  
  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC_am;               % d, mean life span at T
  
  % pack to output
  % the names of the fields in the structure must be the same as the data names in the mydata file
  prdData.am = aT_m;
  
  % uni-variate data
  
  % time-length 
  f = f_tL_tox; pars_lb = [g; k; v_Hb];                          % compose parameters
  ir_B = 3/ k_M + 3 * f * L_m/ v; r_B = 1/ ir_B;             % d, 1/von Bert growth rate
  Lw_i = (f * L_m - L_T)/ del_M;                             % cm, ultimate physical length at f
  Lw_b = get_lb(pars_lb, f) * L_m/ del_M;                    % cm, physical length at birth at f
  ELw = Lw_i - (Lw_i - Lw_b) * exp( - TC_tL * r_B * tL(:,1)); % cm, expected physical length at time

  % pack to output
  % the names of the fields in the structure must be the same as the data names in the mydata file
  prdData.tL = ELw;