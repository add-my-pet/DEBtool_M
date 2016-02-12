%%  get_parfields
% return cell arry of strings with names of core primary parameters for a
% given DEB model

function [coreParFields, info] = get_parfields(model)
% created 2015/07/31 by Starrlight Augustine; modified by Goncalo Marques;
 
  %% Syntax 
  % <../get_parfields.m *get_parfields*> (model)

  %% Description
  % Provides the list of core primary parameters which must be present in
  % pars_init_my_pet for a given model
  %
  % Input
  %
  % * model: string with name of model: 'std', 'stf', 'stx', 'ssj', 'abj',
  % 'asj'. If the model doesn't exist, the output is empty
  %  * info: scalar 1 for sucess, 0 for failure
  % 
  
  %% Remarks
  % check_my_pet is a macro for check_my_pet_stnm, which checks each species one by one

  %% Example of use
  % [coreParFields, info] = get_parfields(metaPar.model)
  
  info = 1;
  
  switch model
      
  case {'std', 'stf', 'abp', 'sbp'}
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hp', 'h_a', 's_G'};
    
  case 'stx'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hx', 'E_Hp', 'h_a', 's_G', 't_0'};
    
  case 'ssj'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hs', 't_sj', 'k_E', 'h_a', 's_G'};     
    
  case 'abj'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hj', 'E_Hp', 'h_a', 's_G'};
    
  case 'asj'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hs', 'E_Hj', 'E_Hp', 'h_a', 's_G'};

  case 'hep'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 'E_Hp', 's_j', 'h_a', 's_G'};

  case 'hex'
    coreParFields =  {'z', 'F_m', 'kap_X', 'kap_P', 'v', 'kap', 'kap_R', 'p_M', 'p_T', 'k_J', 'E_G', 'E_Hb', 's_j', 'E_He', 'h_a', 's_G'};
    
  otherwise
     coreParFields  = {}; 
     info = 0;     
          
  end
  
end
  
  