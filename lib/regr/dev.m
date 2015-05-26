%% dev
%

%%
function d  = dev(func, p, varargin)
  %  created: 2005/01/31 by Bas Kooijman
  
  %% Syntax
  % d  = <../dev.m *dev*>(func, p, varargin)
  
  %% Description
  %  calculates deviance: two times the difference between the log likelihood function and its maximum 
  %    (which based on the multinomial distribution where the death probabilities correspond with the observed relative frequencies). 
  %  The maximum likelihood estimates minimize the deviance. 
  %  See dev2 for the surface-equivalent and dev3 for the volume-equivalent. 
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, tn) with
  %       p: k-vector with parameters; tn: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, tn1, tn2, ...) with  p: k-vector  and
  %      tni: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For tn see below.
  %
  % * p: (k,2) matrix with parameter values in p(:,1)
  % * tni (read as tn1, tn2, .. ): (ni,2) matrix with
  %
  %     tni(:,1) time: must be increasing with rows
  %     tni(:,2) number of survivors: must be non-increasing with rows
  %     tni(:,3, 4, ... ) data-pont specific information data (optional)
  %     The number of data matrices tn1, tn2, ... is optional but >0
  %
  % Output
  % * d: scalar with deviance
  
  %% Remarks
  %  calls user-defined function 'func'
  
  %% Example of use
  % Assuming that function_name, pars, and tn1 (and possibly more data matrices) are defined properly: 
  %  dev('function_name', pars, tn1, tn2, ...). 

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  ntn = nargin - 2; % number of data sets
  n = zeros(ntn,1); % initiate data counter
  while (i <= ntn) % loop across data sets
    eval(['tn', ci, ' = va_arg();']); % assing unnamed arguments to tni
    eval(['[n(', ci, ') k] = size(tn', ci, ');']); % number of data points
    if i == 1      %% obtain time intervals and numbers of death
      D = tn1(:,2) - [tn1(2:n(i),2);0]; % initiate death count
      n0 =  tn1(1,2)*ones(n(1),1); % initiate start number
      listtn = ['tn', ci,',']; % initiate list tn
      listt = ['tn', ci]; % initiate list tn for global declaration
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      eval(['D = [D; tn', ci,'(:,2) - [tn', ci, '(2:n(i),2);0]];']);
                             % append death counts
      eval(['n0 = [n0; tn', ci, '(1,2)*ones(n(', ci,'),1)];']);
				             % append initial numbers
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listt = [listt, ' tn', ci]; % append list tn for global declaration
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end

  [i nl] = size(listtn); listtn = listtn(1:(nl-1)); % remove last ','
  [i nl] = size(listf); listf = listf(1:(nl-1)); % remove last ','
  [i nl] = size(listg); listg = listg(1:(nl-1)); % remove last ','
  eval(['global ', listt,';']); % make data sets global

  ntot = sum(n)-ntn; % tot number of time intervals
  likmax = D' * log(max(1e-10,D./ n0)); % max of log lik function
  
  prob = zeros(ntot,1);
  eval(['[', listf,'] = ', func, '(p,', listtn,' );']);
  if ntn == 1
    prob = f1(1:(n(1)-1),1) - f1(2:n(1),1); % death probabilities
  else % catenate in the case of multiple samples
    cn = 0;
    for i = 1:ntn
      ci = num2str(i);
      eval(['prob((1:(n(', ci, ')-1)) + cn,1) = f', ci, '(1:(n(', ...
	    ci, ')-1),1) - f', ci, '(2:n(', ci, '),1);']);
      cn = cn + n(i)-1;
    end 
  end
  
  d = 2 * (likmax - D' * log(max(1e-10,prob)));
