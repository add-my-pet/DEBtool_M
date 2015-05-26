function matrix2file(file_nm, matrix_nm, matrix)
  % created by Bas Kooijman, modified 2010/08/05
  %
  %% Description
  %  Appends matrix of numbers to an m-file. 
  %
  %% Input
  %  file_nm: character string with file name exclusive extension '.m' 
  %  matrix_nm: character string with name of matrix
  %  matrix: (r,c)- matrix with values
  %
  %% Output
  %  ascii-file with extension .m with code for assigning a variable. 
  %  If the file already exists, the code is appended. If the file does not exist, it is created
  % 
  %% Remarks
  %  By running the file as a script file under Octave/Matlab, the matrix is assigned as a variable.
  %
  %% Example of use
  %  matrix2file('file_nm', 'X;', rand(4)). 
  
  [r c] = size(matrix);
  n = sum(0 == mod(matrix(:),1));
  if n == r * c
    form = ' %d'; % integer
  else
    form = ' %f'; % fixed decimal
  end
  
  oid = fopen([file_nm, '.m'], 'a'); % open file for appending
  fprintf(oid, [matrix_nm, ' = [...\n']);
  r = size(matrix,1);
  for i = 1:r-1
    fprintf(oid, form, matrix(i,:));
    fprintf(oid, '; \n');
  end
  fprintf(oid, form, matrix(r,:));
  fprintf(oid, ']; \n \n');
  fclose(oid);
