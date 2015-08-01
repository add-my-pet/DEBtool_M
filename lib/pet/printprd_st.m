%% printprd_st
% prints data of a species to screen

%%
function printprd_st(data, txtData, prdData, RE)
% created 2015/04/01 by Goncalo Marques & Bas Kooijman
% modified 2015/07/29,  2015/08/01 by Goncalo Marques

  %% Syntax
  % <../printprd_st.m *printprd_st*> (data, txtData, prdData, RE)

  %% Description
  % Prints the data of a species to screen
  %
  % Input 
  %
  % * txtData: text for data
  % * data: data structure
  % * prd: structure with predictions
  % * RE: relative error
  
  %% Remarks
  % Data values are printed first, followed by prediction and relative error
  % The relative error of pseudo date are set to zero, irrespective of the diffference between value and prediction
    
  [nm nst] = fieldnmnst_st(data);
  dtsets = fieldnames(data);

  fprintf('data and predictions (relative error) \n');
  for j = 1:nst

    fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
    tempData = getfield(data, fieldsInCells{1}{:});
    k = size(tempData, 2); % number of data points per set
    if k == 1
      if ~isempty(findstr(nm{j}, '.'))
        tempUnit = getfield(txtData.units, fieldsInCells{1}{:}); 
        tempLabel = getfield(txtData.label, fieldsInCells{1}{:});       
        str = [nm{j}, ', ', tempUnit, ', ',  tempLabel];
        str = ['%3.4g %3.4g (%3.4g) ', str, '\n'];
        tempPrdData = getfield(prdData, fieldsInCells{1}{:});
        fprintf(str, tempData, tempPrdData, RE(j));
      else
        str = [nm{j}, ', ', txtData.units.(nm{j}), ', ',  txtData.label.(nm{j})];
        str = ['%3.4g %3.4g (%3.4g) ', str, '\n'];
        fprintf(str, data.(nm{j}), prdData.(nm{j}), RE(j));
      end
    else
      str = ['see figure (%3.4g) ', dtsets{j}, ', ', txtData.label.(nm{j}){1}, ' vs. ', txtData.label.(nm{j}){2}, '\n'];
      fprintf(str, RE(j));
    end
  end
