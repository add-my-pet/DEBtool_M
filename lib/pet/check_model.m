%% check_model
% checks for the existence of a typified model

%%
function [res, models] = check_model(model)
% created 2018/01/12 Bas Kooijman
 
  %% Syntax 
  % [res models] = <../check_model.m *check_model*> (model)

  %% Description
  % checks if the name of a model is a typified mode
  %
  % Input
  %
  % * model: string with name of model
  %
  % Output
  %
  % * res: boolean with true if model is a typified one, false if not 
  % * model: cell string with typified models

  %% Remark
  % function AmPtool/get_model_types reads model types from DEBwiki
  
  %% Example of use
  % check_model('std')
  
  models = {'std'; 'stf'; 'stx'; 'ssj'; 'sbp'; 'abj'; 'asj'; 'abp'; 'hep'; 'hex'};
  res = ismember(model, models);
  
 