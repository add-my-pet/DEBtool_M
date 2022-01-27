function [prdData, info] = predict_no_pet(par, data, auxData)
  
  % unpack par, data, auxData
  vars_pull(par); vars_pull(data);  
  
  info = 1; % we use the default, filter = 1, to allow user-defined filters 
  EX = a + b * tX(:,1);
  
  % pack to output
  prdData.tX = EX;
  