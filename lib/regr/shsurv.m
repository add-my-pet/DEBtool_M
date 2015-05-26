function shsurv (func, p, varargin)
  %  created: 2002/02/10 by Bas Kooijman
  %
  %% Description
  %  plots observed survivors and model predictions
  %  func: character string with name of user-defined function
  %    see scsurv
  %  p: (r,k) matrix with parameter values in p(:,1) 
  %  tni: (ni,k) matrix with
  %    tni(:,1) time points
  %    tni(:,2) number of survivors (optional)
  %    The number of data matrices nt1, nt2, ... is optional but >0
  %    but must match the definition of 'func'.
  %
  %% Remarks
  %  Set options for plotting routine shsurv with shregr_options
  %
  %% Example of use, assuming that function_name, pars, and data tn are defined properly: 
  %  shsurv('function_name', pars, tn), or if the user-defined function codes for two data sets, 
  %  for instance shsurv('function_name', pars, tn1, tn2). 
  
  %% Code
  i = 1; % initiate data set counter
  ci = num2str(i);   % character string with value of i
  ntn = nargin - 2; % number of data sets
  while (i <= ntn)     % loop across data sets
    eval(['tn', ci, ' = varargin{',ci,'};']);
    eval(['[n(', ci, ') k] = size(tn', ci, ');']); % number of data points
    if i == 1
      listtn = ['tn', ci,',']; % initiate list tn
      listT = ['T', ci,',']; % initiate list T
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listT = [listT, ' T', ci,',']; % append list T
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end

  nl = size(listtn,2); listtn = listtn(1:(nl-1)); % remove last ','
  nl = size(listT,2);  listT = listT(1:(nl-1));   % remove last ','
  nl = size(listf,2);  listf = listf(1:(nl-1));   % remove last ','
  nl = size(listg,2);  listg = listg(1:(nl-1));   % remove last ','
  
  p = p(:,1); % remove other columns from parameter data

  global dataset Range all_in_one; % option settings
  
  for i = 1:ntn
    ci = num2str(i);
    eval(['global xlabel', ci, ' ylabel', ci, ';']);
  end

  %% set options if necessary
  if prod(size(dataset)) == 0 % select data sets to be plotted
    dataset = 1:ntn;
  end
  
  if prod(size(all_in_one)) == 0 % all graphs in one
    all_in_one = 0;
  end
  
  if prod(size(Range)) == 0 % set plot ranges
    Range = zeros(ntn, 2);
    for i = 1:ntn
      ci = num2str(i);
      eval(['r0 = 0.9 * min(tn', ci, '(:,1));']);
      eval(['r1 = 1.1 * max(tn', ci, '(:,1));']);
      Range(i,:) = [r0 r1];
    end
  end
  
  nr = size(Range,1);
  if nr ~= ntn % set plot ranges, because existing ones are invalid
    Range = zeros (ntn, 2);
    for i = 1:ntn
      ci = num2str(i);
      eval(['r0 = 0.9 * min(tn', ci, '(:,1));']);
      eval(['r1 = 1.1 * max(tn', ci, '(:,1));']);
      Range(i,:) = [r0 r1];
    end
  end
  
  for i = 1:ntn % set plot labels
    ci = num2str(i);
    if eval(['prod(size([xlabel', ci,'])) == 0'])
      eval(['xlabel', ci, ' = ''time'';']);
    end
    if eval(['prod(size([ylabel', ci,'])) ~= 1'])
      eval(['ylabel', ci, ' = ''number'';']);
    end    
  end
    
  nS = max(size(dataset)); % set number of data sets to be plotted  

  for i = 1:ntn  %% set time points
    eval(['T', num2str(i), ' = linspace(', ...
	  num2str(Range(i,1)), ', ', num2str(Range(i,2)), ', 100);';]);
  end
  
  %% get survival probabilities
  eval(['[', listf,'] = ', func, '(p,', listT,' );']);
  eval(['[', listg,'] = ', func, '(p,', listtn,' );']);
  for i = 1:nS %% get number of survivors
    ci = num2str(dataset(i));
    eval(['f', ci, ' = f', ci, ' * tn', ci, '(1,2);']);
    eval(['g', ci, ' = g', ci, ' * tn', ci, '(1,2);']);
  end
  
  clf;

  if all_in_one ~= 0 % single plot mode
    for i = 1:nS % loop across data sets that must be plotted
      ci = num2str(dataset(i));
      eval(['plot(T', ci, '(:, 1), f', ci, ', ''r'');']);
      eval(['[nr nc] = size(tn', ci, ');']);
      eval(['plot(tn', ci, '(:,1), tn', ci, '(:,2), ''b+'');']);
      for j = 1:n(dataset(i)) % connect data points with curves
    	eval(['plot([tn', ci, '(j,[1 1])', ...
	      'tn', ci, '(j,2); g', ci, '(j)', 'm';]);
      end
      if i == 1 % set labels
	    eval(['xtext = xlabel',ci,';']);
        eval(['xlabel(''', xtext, ''');']);
        eval(['ytext = ylabel',ci,';']);
        eval(['ylabel(''', ytext, ''');']);
      end  
    end
  else % multiplot mode
    %% rows and colums of multiplot
    r = max([1, floor(sqrt(ntn))]); k = ceil(nS/r);
    
    for i = 1:nS % loop across data sets that must be plotted
      subplot(r,k,i)  
      clf;
      ci = num2str(dataset(i));
      eval(['xtext = xlabel',ci,';']);
      eval(['xlabel(''', xtext, ''');']);
      eval(['ytext = ylabel',ci,';']);
      eval(['ylabel(''', ytext, ''');']);
      eval(['plot(T', ci, '(:, 1), f', ci, ', ''r'');']);
      eval(['[nr nc] = size(tn', ci, ');']);
      eval(['plot(tn', ci, '(:,1), tn', ci, '(:,2), ''b+'');']);
    end

  end