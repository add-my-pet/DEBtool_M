%% ReadTable
% reads numerical table from csv file

%%
function tab = ReadTable(file)
  %  created 2017/05/30 by Bas Kooijman

  %% Syntax
  % tab = <../ReadTable.m *ReadTable*> (file)
  
  %% Description
  % converts a csv file into a numerical table, assuming that 
  %   - the number of columns for each row is fixed
  %   - all columns are fully numerical
  %
  % Input:
  %
  % * file: file name, including extension
  %
  % Output:
  %
  % * tab: (r,c)-table with numerical values


fnm = fopen(file); tab = str2num(char(fread(fnm)')); fclose(fnm);

