%% setweights_tW
% sets weights of tW data in a mydata-file

%%
function [factor_cur, flds] = setweights_tW(my_pet, factor_new)
  % created 2023/80/30 by Bas Kooijman
  %% Syntax
  % <../setweights_tW.m *setweights_tW*> (my_pet, factor_new)
  
  %% Description
  % Weight-coefficients can only be set in mydata files by specifying multiplication factors on default settings.
  % The function modifies the factors for data sets of type tW in a mydata-file. 
  % The first call might avoid the second input to obtain the current settings.
  % A second call might modify the current settings, by specifying the second input.
  % If that happens, the first output equals the second input and the mydata file is overwritten.
  %
  % Input
  %
  % * my_pet: string with entry-name for loading/writing mydata_my_pet
  % * factor_new: optional scalar or vector with new multipliers for weights for tW data  
  %
  % Output
  %
  % * factor_cur: vector with current multipliers for weights of tW data
  % * flds: cell string with fieldnames of tW data
  
  %% Remarks
  % This function does not recognise that text for weight-setting in mydata might be outcommented.
  % If factor_new is scalar, all weights of tW data will have the same value.
  
  %% Examples
  % fac = setweights_tW('Octopus_pallidus'); on the assumption that mydata_Octopus_pallidusa.m is in the current dir
  % setweights_tW('Octopus_pallidus',2); 

  fnm = ['mydata_', my_pet];
  [data, ~, ~, ~, weights] = feval(fnm); % fill structure data and weights
  flds = fieldnames(data);
  flds = flds(contains(flds,'tW')); % all data fields that contain "tW"
  wghts = setweights(data,[]);
  n = length(flds); factor_cur = ones(n,1);
  for i=1:n; factor_cur(i) = weights.(flds{i})(1)/wghts.(flds{i})(1); end   
  if ~exist('factor_new','var'); return; end
  
  if length(factor_new)==1; factor_new = factor_new * ones(n,1); end
  if length(factor_new)<n
    fprintf('Warning from setweights_tW: length of factors is smaller than number of tW fields\n')
    return
  end
  
  fnm = [fnm, '.m'];
  mydata = fileread(fnm);
  ind_w = strfind(mydata, 'weights.')-1; % index of start weight settings
  if isempty(ind_w)
    ind_w = strfind(mydata, 'weights = setweights(data, []);'); 
    ind_w = ind_w + 1 + strfind(mydata(ind_w:end), char(10)); ind_w = ind_w(1);
  end
  
  for i=1:n % scan tW fields
    txt = ['weights.',flds{i}];
    ind = strfind(mydata,txt);
    if ~isempty(ind) % remove current setting
      ind_1 = strfind(mydata(ind:end), char(10)); mydata(ind:ind-1+ind_1(1)) = [];
    end 
    mydata = [mydata(1:ind_w), txt, ' = ', txt, ' * ', num2str(factor_new(i)), ';', char(10), mydata(ind_w+1:end)];
  end
  factor_cur = factor_new;

  write mydata
  fid_mydata = fopen(fnm, 'w+'); fprintf(fid_mydata, '%s', mydata); fclose(fid_mydata);

