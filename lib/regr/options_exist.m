function options_exist
  global max_step_number max_step_size max_norm max_evol report ...
      tol_fun max_fun_evals tol_simplex popSize startPop
  
  if ~exist('popSize','var')  % ga**
    popSize = [];
  end
  if ~exist('startPop','var') % ga**
    startPop = [];
  end
  if ~exist('max_step_number','var') % ga**, nm**, nr**
    max_step_number = [];
  end
  if ~exist('max_step_size','var') % nr**
    max_step_size = [];
  end
  if ~exist('max_norm','var')      % nr**
    max_norm = [];
  end
  if ~exist('max_evol','var')      % ga**
    max_evol = [];
  end
  if ~exist('report','var')        % ga**, nm**, nr**
    report = [];
  end
  if ~exist('tol_fun','var')       % ga**, nm**
    tol_fun = [];
  end
  if ~exist('max_fun_evals','var') % nm**
    max_fun_evals = [];
  end
  if ~exist('tol_simplex','var')   % nm**
    tol_simplex = [];
  end

