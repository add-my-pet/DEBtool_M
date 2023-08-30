%% setweights_tW
% sets weights of tW data in a mydata-file

%%
function [factor_cur, nm] = setweights_tW(my_pet, factor_new)
  % created 2023/80/30 by Bas Kooijman
  %% Syntax
  % <../setweights_tW.m *setweights_tW*> (my_pet, factor_new)
  
  %% Description
  % Weight-coefficients can only be set in mydata files my specifying multiplication factor for default settings.
  % The functions modifies the factors for data sets of type tW in a mydata-file. 
  % The first call might avoid the second input to obtain the current setting.
  % A second call might modify the current setting, by specifying the second input.
  % If that happens, the first output equals the second input.
  %
  % Input
  %
  % * my_pet: string with entry-name for loading/writing mydata_my_pet
  % * factor_new: optional vector with new multipliers for weights for tW data  
  %
  % Output
  %
  % * factor_cur: vector with current multipliers for weights of tW data
  % * nm: cell string with fieldnames of tW data
  
  %% Examples
  % setweights_tW('Daphnia_magna',0) on the assumption that mydata_Daphia_magna.m is in the current dir

  fnm = ['mydata_', my_pet];
  feval(['[data, ~, ~, ~, weights] = ', fnm, ';']); % fill structure data and weights
  flds = fieldnames(data);
  flds = flds(contains('tW', flds)); % all data fields that contain "tW"
  
  fnm = [fnm, '.m'];
  mydata = fileread(fnm);
  ind = 7 + strfind(mydata, 'weights.'); n = length(ind); flds_w = cell(n,1);
  for i=1:n; ind_1 = strfind(mydata(ind(i):end, ' '); flds_w{i} = mydata(ind(i):ind(i)+ind_1(1)); end
  nm = flds_w;

  % write mydata
  % fid_mydata = fopen(fnm, 'w+'); fprintf(fid_mydata, '%s', mydata); fclose(fid_mydata);

