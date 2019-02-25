%% get_parfields
% returns cell array of strings with names of core primary parameters for a given DEB model

%%
function [coreParFields, info] = get_parfields(model, addchem)
% created 2015/07/31 by Starrlight Augustine; modified by Goncalo Marques; 2017/02/03, 2018/08/18, 2019/02/24 by Bas Kooijman
 
  %% Syntax 
  % [coreParFields, info] = <../get_parfields.m *get_parfields*> (model)

  %% Description
  % Provides the list of core primary parameters which must be present in
  % pars_init_my_pet for a given model
  %
  % Input
  %
  % * model: string with name of model: 'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hex', 'nat'. 
  % * addchem: optional boolean, to include chemical parameters. Default 0: not include them
  %
  % Output
  %
  % * coreParFields: cell string with field names
  % * info: scalar 1 for success, 0 for failure 
  
  %% Remarks
  % check_my_pet is a macro for check_my_pet_stnm, which checks each species one by one
  % If the model doesn't exist, the output is empty and info = 0

  %% Example of use
  % [coreParFields, info] = get_parfields(metaPar.model)
  
  if ~check_model(model)
    fprintf(['warning from check_model: ', model, ' is not a typical model\n'])
  end
  
  if ~exist('addchem', 'var')
      addchem = 0;
  end
  
  info = 1;
  
  switch model
      
  case {'std', 'stf', 'abp', 'sbp'}
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hp', 'h_a', 's_G'};
    
  case 'stx'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hx', 'E_Hp', 'h_a', 's_G', 't_0'};
    
  case 'ssj'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hs', 't_sj', 'E_Hp', 'k_E', 'h_a', 's_G'};     
    
  case 'abj'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hj', 'E_Hp', 'h_a', 's_G'};
    
  case 'asj'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hs', 'E_Hj', 'E_Hp', 'h_a', 's_G'};

  case 'hep'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hp', 'E_Rj', 'h_a', 's_G'};

  case 'hex'
    coreParFields =  {'T_A', 'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'kap_V', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 's_j', 'E_He', 'h_a', 's_G'};
    
  case 'nat'  
    coreParFields =  {};
    
  otherwise
    coreParFields  = {}; 
    info = 0;     
          
  end
  
  if addchem
    chem = { ...
    'd_X';   'd_V';  'd_E';  'd_P'; % g/cm^3, specific densities 
    'mu_X'; 'mu_V'; 'mu_E'; 'mu_P'; % J/mol, chemical potentials for organics
    'mu_C'; 'mu_H'; 'mu_O'; 'mu_N'; % J/mol, chemical potentials for minerals
    'n_CX'; 'n_HX'; 'n_OX'; 'n_NX'; % -, chemical indices
    'n_CV'; 'n_HV'; 'n_OV'; 'n_NV';
    'n_CE'; 'n_HE'; 'n_OE'; 'n_NE';
    'n_CP'; 'n_HP'; 'n_OP'; 'n_NP';
    'n_CC'; 'n_HC'; 'n_OC'; 'n_NC';
    'n_CH'; 'n_HH'; 'n_OH'; 'n_NH';
    'n_CO'; 'n_HO'; 'n_OO'; 'n_NO';
    'n_CN'; 'n_HN'; 'n_ON'; 'n_NN'};
    coreParFields = [coreParFields, chem'];
  end

      
  
end
  
  