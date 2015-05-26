function clear_file(file_nm)
  oid = fopen([file_nm, '.m'], 'w'); % open file for writing
  fclose(oid);
