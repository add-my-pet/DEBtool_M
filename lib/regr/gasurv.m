%% gasurv
% Calculates max likelihood estimates using a genetic algorithm for univariate data

%%
function [q, info, endPop, bPop, traceInfo] = gasurv(func, p, varargin)
  %  created: 2006/05/25 by Bas Kooijman
  
  %% Syntax
  % [q, info, endPop, bPop, traceInfo] = <..gasurv.m *gasurv*>(func, p, varargin)
  
  %% Description
  % Calculates max likelihood estimates using a genetic algorithm for univariate data
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
  % * p: (k,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * tni (read as tn1, tn2, .. ): (ni,2) matrix with
  %
  %     tni(:,1) time: must be increasing with rows
  %     tni(:,2) number of survivors: must be non-increasing with rows
  %     tni(:,3, 4, ... ) data-pont specific information data (optional)
  %     The number of data matrices tn1, tn2, ... is optional but >0
  %
  % Output
  %
  % * q: matrix like p, but with ml-estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  % * endPop: the final population: individual in each row; last column is minus weighted sum of squares  
  % * bPop: a trace of the best population
  % * traceInfo: a matrix of best and means of the ga for each generation
  
  %% Remarks
  % Set options with <garegr_options.html *garegr_options*>
  % Similar to <nrsurv.html *nrsurv*>, but slower and a larger bassin of attraction.
  %
  % Modified from gaot package version 1996/02/02:
  %   C.R. Houck, J.Joines, and M.Kay. 
  %   A genetic algorithm for function optimization: 
  %   A Matlab implementation. ACM Transactions on Mathmatical Software, Submitted 1996
  %   binary and order options removed
  %
  % gasurv calls for:
  %    User-defined function: 'func'
  %
  % Crossover Operators:
  %      simplexover heuristicxover arithxover 
  % Mutation Operators:
  %      boundarymutation multinonunifmutation nonunifmutation unifmutation
  % Selection Functions:
  %      normgeomselect roulette tournselect
  % Utility functions: cat
  % Option setting: garegr_options
  
  %% Example of use
  %  <../mydata_surv.m *mydata_surv*>

  global popSize startPop tol_fun report max_step_number max_evol

  ntn = nargin - 2; % number of data sets
  for i = 1:ntn % loop across data sets
    ci = num2str(i); % character string with value of i
    if i == 1
      listtn = ['tn', ci,',']; % initiate list tn
      listf = ['f', ci,',']; % initiate list f
    else     
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listf = [listf, ' f', ci,',']; % append list f
    end
  end
  nl = size(listtn,2); listtn = listtn(1,1:nl - 1); % remove last ','
  nl = size(listf,2); listf = listf(1,1:nl - 1); % remove last ','
  eval(['global ', listtn]); % make data sets global

  N = zeros(ntn, 1); % initiate data counter
  for i = 1:ntn % loop across data sets
    ci = num2str(i); % character string with value of i
    eval(['tn', ci, ' = varargin{i};']); % assing unnamed arguments to xywi
    eval(['[N(', ci, '), k] = size(tn', ci, ');']); % number of data points
    if i == 1
      %% obtain time intervals and numbers of death
      D = tn1(:,2) - [tn1(2:N(i),2);0]; % initiate death count
      n0 =  tn1(1,2) * ones(N(1),1); % initiate start number
    else     
      eval(['D = [D; tn', ci,'(:,2)] - [tn', ci, '(2:N(i),2);0];']);
                                % append death counts
      eval(['n0 = [n0; tn', ci, '(1,2) * ones(N(', ci,'),1)];']);
				% append initial numbers
    end
  end

  q = p; % copy input parameter matrix into output
  likmax = D' * log(max(1e-10, D ./ n0)); % max of log lik function  
  ntot = sum(N); % tot number of time intervals
  prob = zeros(ntot,1);

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k > 1
    index = index(0 < p(:,2)); % indices of iterated parameters
  end
  numVar = max(size(index));  % number of parameters that must be iterated
  if (numVar == 0)
    return; % no parameters to iterate
  end
  bounds = q(index,[3 4]); % lower and upper boundaries of iterated parameters
  xZomeLength  = 1 + numVar; % Length of the xzome=numVars+fittness

  % set options if necessary

  if numel(popSize) == 0
    garegr_options('popSize', 80)
  end
  if numel(tol_fun) == 0
    garegr_options('tol_fun', 1e-6)
  end
  if numel(report) == 0 
    garegr_options('report', 1)
  end
  if numel(max_step_number) == 0
    garegr_options('max_step_number', 500)
  end
  if numel(max_evol) == 0
    garegr_options('max_evol', 50)
  end

  estr = ['[', listf, '] = ', func, '(indiv, ', listtn, ');'];

  %   selectFN   - name of the .m selection function (['normGeomSelect'])
  %   selectOpts - options string to be passed to select after
  %                select(pop,%,opts) ([0.08])
  selectFN = ['normgeomselect'];
  selectOpts = 0.08;

  %   xOverFNs   - a string containing blank seperated names of Xover.m
  %                files (['arithXover heuristicXover simpleXover']) 
  %   xOverOpts  - A matrix of options to pass to Xover.m files with the
  %                first column being the number of that xOver to perform
  %                similiarly for mutation ([2 0;2 3;2 0])
  xOverFNs = char('arithXover', 'heuristicXover', 'simpleXover');
  xOverOpts = [2 0; 2 3; 2 0];

  %   mutFNs     - a string containing blank seperated names of mutation.m 
  %                files (['boundaryMutation multiNonUnifMutation ...
  %                         nonUnifMutation unifMutation'])
  %   mutOpts    - A matrix of options to pass to Xover.m files with the
  %                first column being the number of that xOver to perform
  %                similiarly for mutation ([4 0 0;6 100 3;4 100 3;4 0 0])
  mutFNs = char('boundaryMutation', 'multiNonUnifMutation', ...
	    'nonUnifMutation', 'unifMutation');
  mutOpts = [4 0 0; 6 max_evol 3; 4 max_evol 3; 4 0 0];

  endPop       = zeros(popSize,xZomeLength); % A secondary population matrix
  c1           = zeros(1,xZomeLength); 	% An individual
  c2           = zeros(1,xZomeLength); 	% An individual
  numXOvers    = size(xOverFNs,1); 	% Number of Crossover operators
  numMuts      = size(mutFNs,1); 	% Number of Mutation operators
  bFoundIn     = 1; 			% Number of times best has changed
  done         = 0;                     % Done with simulated evolution
  gen          = 1; 			% Current Generation Number
  gen_bval     = 0;                     % Gen Number since last new best
  collectTrace = (nargout > 4); 	% Should we collect info every gen
  bPop         = zeros(0,xZomeLength+1);% inserted because of error in ga

  % Generate start population if necessary
  if isempty(startPop) | ~sum(size(startPop,2) == [numVar xZomeLength])
    startPop = zeros(popSize,xZomeLength);
    range = bounds(:,2) - bounds(:,1);
    for i = 1:popSize
      startPop(i,1:numVar) = (bounds(:,1) + range .* rand(numVar,1))';
      indiv = p(:,1); indiv(index) = startPop(i,1:numVar)';
      eval(estr);
      if ntn == 1
        prob = f1 - [f1(2:N(1));0]; % death probabilities
      else % catenate in the case of multiple samples
        cn = 0;
        for i = 1:ntn
          ci = num2str(i);
          eval(['prob((1:(N(', ci, ')-1)) + cn,1) = f', ci, ...
	        ' - f', ci, '(2:N(', ci, '));0];']);
          cn = cn + n(i);
        end 
      end  
      indiv_val = - 2 * (likmax - D' * log(max(1e-10,prob)));  
      startPop(i,xZomeLength) = indiv_val;
    end
  elseif numVar == size(startPop,2) % supplement startPop with fitness values
    popSize = size(startPop,1);
    startPop = [startPop, zeros(popSize,1)];
    for i = 1:popSize
      indiv = p(:,1); indiv(index) = startPop(i,1:numVar)';
      eval(estr);
      if ntn == 1
        prob = f1 - [f1(2:N(1));0]; % death probabilities
      else % catenate in the case of multiple samples
        cn = 0;
        for i = 1:ntn
          ci = num2str(i);
          eval(['prob((1:(N(', ci, ')-1)) + cn,1) = f', ci, ...
	        ' - f', ci, '(2:N(', ci, '));0];']);
          cn = cn + n(i);
        end 
      end  
      indiv_val = - 2 * (likmax - D' * log(max(1e-10,prob)));  
      startPop(i,xZomeLength) = indiv_val;
    end
  else % make sure that popSize represents number of individuals
    popSize = size(startPop,1);    
  end 

  oval = max(startPop(:,xZomeLength)); % Best value in start pop

  while(~done)
    % Elitist Model
    [bval,bindx] = max(startPop(:,xZomeLength));       % Best of current pop
    best =  startPop(bindx,:);

    if collectTrace
      traceInfo(gen,1) = gen; 		               % current generation
      traceInfo(gen,2) = startPop(bindx,xZomeLength);  % Best fittness
      traceInfo(gen,3) = mean(startPop(:,xZomeLength));% Avg fittness
      traceInfo(gen,4) = std(startPop(:,xZomeLength)); 
    end

    if ((abs(bval - oval) > tol_fun) | (gen == 1)) % If we have a new best sol
      if report == 1
        fprintf(1,'\n%d %f\n',gen,-bval);          % Update the report
      end 
      bPop(bFoundIn,:) = [gen startPop(bindx,:)];  % Update bPop Matrix
      bFoundIn = bFoundIn + 1;                % Update number of changes
      oval = bval;                            % Update the best val
      gen_bval = 0;
    else 
      if report == 1
        fprintf(1,'%d ',gen);	              % Otherwise just update num gen
      end
      gen_bval = gen_bval + 1;
    end 

    endPop = feval(selectFN,startPop,[gen selectOpts]); % Select

    for i = 1:numXOvers
      for j = 1:xOverOpts(i,1)
	a = 1 + round(rand * (popSize - 1)); 	% Pick a parent
	b = 1 + round(rand * (popSize - 1)); 	% Pick another parent
	xN = deblank(xOverFNs(i,:)); 	% Get the name of crossover function
        [c1 c2] = feval(xN,endPop(a,:),endPop(b,:),bounds,[gen xOverOpts(i,:)]);
	
	if c1(1:numVar) == endPop(a,(1:numVar)) % Make sure we created a new 
	  c1(xZomeLength) = endPop(a,xZomeLength); % solution before evaluating
	elseif c1(1:numVar) == endPop(b,(1:numVar))
	  c1(xZomeLength) = endPop(b,xZomeLength);
	else 
	  indiv = p(:,1); indiv(index) = c1(1:numVar)';
	  eval(estr);
          if ntn == 1
            prob = f1 - [f1(2:N(1));0]; % death probabilities
          else % catenate in the case of multiple samples
            cn = 0;
            for i = 1:ntn
              ci = num2str(i);
              eval(['prob((1:(N(', ci, ')-1)) + cn,1) = f', ci, ...
	            ' - f', ci, '(2:N(', ci, '));0];']);
              cn = cn + n(i);
            end 
          end  
          indiv_val = - 2 * (likmax - D' * log(max(1e-10,prob)));  
	  c1(xZomeLength) = indiv_val;
	end 
	if c2(1:numVar) == endPop(a,(1:numVar))
	  c2(xZomeLength) = endPop(a,xZomeLength);
	elseif c2(1:numVar) == endPop(b,(1:numVar))
	  c2(xZomeLength) = endPop(b,xZomeLength);
	else 
	  indiv = p(:,1); indiv(index) = c2(1:numVar)';
	  eval(estr);
          if ntn == 1
            prob = f1 - [f1(2:N(1));0]; % death probabilities
          else % catenate in the case of multiple samples
            cn = 0;
            for i = 1:ntn
              ci = num2str(i);
              eval(['prob((1:(N(', ci, ')-1)) + cn,1) = f', ci, ...
	            ' - f', ci, '(2:N(', ci, '));0];']);
              cn = cn + n(i);
            end 
          end  
          indiv_val = - 2 * (likmax - D' * log(max(1e-10,prob)));  
	  c2(xZomeLength) = indiv_val;
	end      
	
	endPop(a,:) = c1;
	endPop(b,:) = c2;
      end
    end 

    for i = 1:numMuts
      for j = 1:mutOpts(i,1)
	a = 1 + round(rand * (popSize - 1));
	c1 = feval(deblank(mutFNs(i,:)),endPop(a,:),bounds,[gen mutOpts(i,:)]);
	if c1(1:numVar) == endPop(a,(1:numVar)) 
	  c1(xZomeLength) = endPop(a,xZomeLength);
	else
	  indiv = p(:,1); indiv(index) = c1(1:numVar)';
	  eval(estr);
          if ntn == 1
            prob = f1 - [f1(2:N(1));0]; % death probabilities
          else % catenate in the case of multiple samples
            cn = 0;
            for i = 1:ntn
              ci = num2str(i);
              eval(['prob((1:(N(', ci, ')-1)) + cn,1) = f', ci, ...
	            ' - f', ci, '(2:N(', ci, '));0];']);
              cn = cn + n(i);
            end 
          end  
          indiv_val = - 2 * (likmax - D' * log(max(1e-10,prob)));  
	  c1(xZomeLength) = indiv_val;
	end
	endPop(a,:) = c1;
      end
    end  
      
    gen = gen + 1;

    if gen >= max_step_number % stop because number of generation exceeds maximum
      done = 1;
      info = 0;
      fprintf(['\n no convergence within ', num2str(max_step_number), ...
	      ' generations \n']);
    elseif gen_bval >= max_evol % stop because of lack of improvement
      done = 1;
      info = 1;
      if report > 0
        fprintf(['\n no improvement within ', num2str(max_evol), ...
		' generations \n']);
      end
    end

    startPop = endPop; 			% Swap the populations
  
    [bval,bindx] = min(startPop(:,xZomeLength)); % Keep the best solution
    startPop(bindx,:) = best; 		% replace it with the worst
  end 

  [bval,bindx] = max(startPop(:,xZomeLength));
  if report 
    fprintf(1,'\n%d %f\n',gen,-bval);	  
  end

  x = startPop(bindx,:);
  bPop(bFoundIn,:) = [gen startPop(bindx,:)];

  if collectTrace
    traceInfo(gen,1) = gen; % current generation
    traceInfo(gen,2) = startPop(bindx,xZomeLength);   % Best fittness
    traceInfo(gen,3) = mean(startPop(:,xZomeLength)); % Avg fittness
  end

  q(index, 1) = x(1:numVar)'; % copy best solution to output
