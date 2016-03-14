%% ricatti
% Solves matrix S from 0 = A + S B' + B

%%
function S = ricatti(A,B)
  %  created by Bas Kooijman at 2005/06/22; modified 2009/09/29

  %% Syntax
  % S = <../ricatti.m *ricatti*> (A,B)

  %% Description
  %  Given square matrices A and B, the function solves matrix S from 0 = A + S B' + B S 
  %
  % Input:
  %
  % * A: (n,n)-matrix with cov d/dt X
  % * B: (n,n)-matrix with jacobian of d/dt X
  % * If d/dt X = f, and f(X^*) = 0, the jacobian is defined as d/dX f'(X^*). 
  %
  % Output:
  %
  % * S: (n,n)-matrix with solution of 0 = A + S B' + B S
  
  %% Example of use
  %  A = [2 1; 1 4]; B = [.1 .6; .5 .8]; ricatti(a,b). 
    
  nA = size(A); nB = size(B); n = nA(1);
  if nA(1) ~= nA(2) || nB(1) ~= nB(2) || nA(1) ~= nB(1)
    fprintf('sizes do not match \n');
    S = [];
    return
  end

  S = fsolve(@fnricatti, B(:), [], A, B, n);
  S = reshape(S, n, n);
end

% subfunction

function f = fnricatti(S, A, B, n)
  % called from ricatti

  S = reshape(S,n,n);
  f = A + S * B' + B * S;
  f = f(:);
end

