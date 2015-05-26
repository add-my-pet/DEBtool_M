%% nrdregr_st
% Routine called by nrregr to calculate numerical derivatives

%%
function [f, df] = nrdregr_st (func, p, st)
  % created: 2001/09/07 by Bas Kooijman; modified: 2013/05/02 by Gonçalo Marques
 
  %% Syntax
  % [f, df] = <..nrdregr_st.m *nrdregr_st*> (func, p, st)
  
  %% Description
  % Routine called by nrregr to calculate numerical derivatives
  %
  % Input
  %
  % * func: character string with name of user-defined function;
  %    see <nrregr_st.html *nrregr_st*> or <nrregr.html *nrregr*>
  % * p: (np,2) matrix with
  %
  %    p(:,1) parameter values
  %    p(:,2) binaries with yes or no conditional values
  %    all conditional parameters have zero (co)variance
  %
  % * st: (ni,3) structure with
  %
  %    st.nm(:,1) independent variable
  %    st.nm(:,2) dependent variable
  %    st.nm(:,3) weight coefficients (optional)
  %    The number of data matrices in st fields is optional
  %    The first data matrix is assumed to be zero-variate, 
  %      the others uni-variate, which are first reduced to zero-variate data
  %      if all weight coefficients in a uni-variate data-set are zero,
  %      that relative error gets weight zero
  %  
  % Output
  %
  % * f: (n,1) vector with function evaluations
  % * df: (n,l) matrix with Jacobian
   
  global index 

  [nm nst] = fieldnmnst_st(st);
  
  % index: parameter indices that are iterated
  
  step = 1.05; % step factor in parameter values for numerical differentiation

  
  % get function values at evaluation point
  eval(['[f_str] = ', func, '(p, st);']);
  f = [];
  for i = 1:nst
    eval(['f = [f; f_str.', nm{i}, '];']);
  end	    
  n = length(f); % total number of data points
  l = length(index); % number of parameters that are iterated
  
  df = zeros(sum(n),l); % initiate jacobian
  for i = 1 : l % loop across parameters to be iterated
    % make step in a single parameter value
    q = p; q(index(i)) = p(index(i)) * step;
    % get function values at changed parameter value
    eval(['[g_str] = ', func, '(q, st);']);
    
    g = [];
    for j = 1:nst
      eval(['g = [g; g_str.', nm{j}, '];']);
    end
    df(:,i) = (g - f)/ (step - 1)/ p(index(i)); % numerical differentials for parameter i
  end
  