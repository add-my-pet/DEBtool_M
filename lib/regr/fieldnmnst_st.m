function [nm nst] = fieldnmnst_st(st)
  % created 2013/05/02 by Gonçalo Marques; modified 2013/09/27
  %
  %% Description
  %  creates a list of field names of a structure and its number
  %
  %% Input
  %  st: a matlab structure 
  %  
  %% Output
  %  nm: vector of field names
  %  nst: number of fields
  %
  %% Remarks
  %  fieldnmnst_st will produce a list of the fields of the last level of
  %  the structure. For example for the structure x with:
  %  x.len
  %  x.len.dat1
  %  x.len.dat2
  %  x.temp
  %  x.reprod
  %  x.reprod.dat
  %  the list of field names will be:
  %  nm = ['len.dat1', 'len.dat2', 'temp', 'repod.dat']
  
  %% Code
  nm = fieldnames(st);
  nst = length(nm); % number of data sets
  baux = 1;
  while baux == 1
    nmaux = [];
    baux = 0;
    for i = 1:nst
      if eval(['isstruct(st.', nm{i}, ')'])
        eval(['vaux = fieldnames(st.', nm{i}, ');']);
        nv = length(vaux);
        for j = 1:nv
          nmaux = [nmaux; cellstr(strcat(nm{i}, '.', vaux{j}))];
        end
        baux = 1;
      else
        nmaux = [nmaux; nm(i)];
      end
    end
    nm = nmaux;
    nst = length(nm);
  end

