%% merge
% merges an (n_1,2) and (n_2,2) metrix into an (n_1+n_2,3) matrix 

%%
function tXY = merge(tX, tY)
  % created at 2022/08/24 by Bas Kooijman
  
  %% Syntax
  % tXY = <../merge.m *merge*>(tX, tY)
  
  %% Description
  % merges an (n,2) and nm,2) metrix into an (n+m,3) matrix.
  % Unknown values in tXY are NaN's.
  % Double t-values tXY are avoided, but in tX or tY not allowed.
  %
  % Input
  %
  % * tX: (n,2)-matrix with t,X-values
  % * tY: (m,2)-matrix with t,Y-values
  %
  % Output
  %
  % * tXY: (n+m,3) matrix with t,x,y-values
  
  %% Remarks
  % 
  
  
  %% Example of use
  % merge([1 2 5; 2.1 3 1]',[1 2.5 5; 1 4 6.3]')
  
  n = size(tX,1); m = size(tY,1);
  if ~length(unique(tX(:,1)))==n
    fprintf('Double values in first col of first input\n'); tXY = []; return
  end
  if ~length(unique(tY(:,1)))==m
    fprintf('Double values in first col of second input\n'); tXY = []; return
  end
    
  t = unique([tX(:,1); tY(:,1)]); n_t = length(t); ind = 1:n_t; tXY = [t, NaN(n_t,2)]; 
  for i=1:n
    tXY(ind(t==tX(i,1)),2) = tX(i,2);
  end
  for i=1:m
    tXY(ind(t==tY(i,1)),3) = tY(i,2);
  end
 
 end