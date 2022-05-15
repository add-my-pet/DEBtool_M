%% postProcess_mmea
% filter and improve solutions of mmea
%%
function sol = postProcess_mmea(results_mmea)
  %  created at 2022/04/01 by Bas Kooijman
  
  %% Syntax
  % sol = <../postProcess_mmea.m *postProcess_mmea*> (results_mmea)
  
  %% Description
  % filters solutions of mmea by removing solutions that are too close together and 
  % whose lossfunction increases monotonically if the parameter set moves straight 
  % from the best to other solutions. Then each remaining parameter set is used as
  % seed in an nm algorithm, and the removing procedure is repeated.
  % The method is based on the fact that if the loss function increases
  % monotonically when moving from start to end, the end parameter set
  % cannot be a local minimum of the loss function.
  % 
  % Input
  %
  % * results: char string with name of .mat file with solution set of mmea
  %
  % Output
  %
  % * sol: (n,k)-matrix of n solutions for k free parameters
  
  %% Remarks
  % Run in directory that has the mydata-, pars_init- and predict-file,
  % as well as the results_my_pet_mmea.mat file with mmea solutions.
  % If not present, the results_my_pet.mat file will be written, 
  % with par-values as in the pars_init-file.
  % The list of solutions is printed at each reduction round and finally
  % the elasticities
  
  %% Example of use
  % pars_Dipodomys_deserti_mmea = postProcess_mmea('results_Dipodomys_deserti_mmea');
  global pets 
    
  % read results_mmea
  load(results_mmea)
  sol = result.solutionsParameters; % (n,k)-matrix with (solutions,parameters) 
  [n_sol, n_par] = size(sol);
  parNm = result.parameterNames; % cell-string with names of free parameters
  val = result.lossFunctionValues;
  if length(parNm) ~= n_par
    fprintf('Warning from postProcess_mmea: parameter names are not consistent with solution set\n');
    return
  end
  fprintf('%g solutions found and printed in table\n', n_sol);
  prt_tab({(1:n_sol)', val, sol},['Par'; 'Lf'; parNm]', 'solutions');   
  
  % initiate par,data,auxData,weights for calls to lossfunction
  % the free pars in par will be overwritten
  my_pet = strsplit(results_mmea,'_'); my_pet = [my_pet{2}, '_', my_pet{3}];
  pets = {my_pet}; % required for running nm
  eval(['[data, auxData, metaData, txtData, weights] = mydata_', my_pet,';']);
  eval(['[par, metaPar, txtPar] = pars_init_', my_pet, '(metaData);']);  
  func = ['predict_', my_pet];
  
  % initiate estim_options settings and make a copy of results_my_pet.mat
  estim_options('default'); % method nm
  estim_options('results_output', 0); % only write results_my_pet.mat-file
  estim_options('report', 0); % no printing to screen
  estim_options('max_step_number', 500);
  if ~exist(['results_',my_pet,'.mat'], 'file')
    estim_options('pars_init_method', 2);
    estim_options('method', 'no');
    estim_pars; % write results_my_pet.mat-file
  end
  if ismac || isunix % save a copy; will be restore at the end
    system(['cp results_',my_pet,'.mat results_',my_pet,'_copy.mat']);
  else
    system(['powershell cp results_',my_pet,'.mat results_',my_pet,'_copy.mat']);
  end

  n_rnd = 10;
  for h = 1:n_rnd % start selection & refinement rounds
  
    % remove solutions that are too close together
    if n_sol>1
      [sol, val] = reduceSol(sol, val);
      n_sol = size(sol,1);
      fprintf('round %g of %g: %g solutions are sufficiently apart\n', h, n_rnd, n_sol);
    end

    % refine remaining solutions with nm method with max 500*h steps
    estim_options('method', 'nm');
    estim_options('pars_init_method', 1); % start from .mat file
    estim_options('simplex_size', 0.005); % very small to avoid leaving local min
    load(['results_',my_pet,'.mat'], 'par');
    for i=1:n_sol
      for k=1:n_par; par.(parNm{k}) = sol(i,k); end % overwrite free pars
      save(['results_',my_pet,'.mat'], 'par');
      for H=1:h; estim_pars; end
      load(['results_',my_pet]);
      for k=1:n_par; sol(i,k) = par.(parNm{k}); end % copy resulting pars in sol
      val(i) = lossFn(func, par, data, auxData, weights);
      fprintf('%round %g of %g: refining solution %g of %g\n',h,n_rnd,i,n_sol)
    end
 
    % remove solutions that are too close together
    if n_sol>1
      [sol, val] = reduceSol(sol, val);
      n_sol = size(sol,1);
      fprintf('%round %g of %g: %g refined solutions are sufficiently apart and printed in table\n', h,n_rnd,n_sol);
      prt_tab({(1:n_sol)', val, sol},['Par'; 'Lf'; parNm]', 'solutions');   
    end
      
    % remove solutions that are not local minima
    fprintf('start checking monotony of loss functions from one solution to the other\n');
    if n_sol>1
      [val_sort, i_sort] = sort(val); 
      sol_sort = sol(i_sort,:);
      sel = testMonotony(func,sol_sort,parNm,val_sort,par,data,auxData,weights);
      i_sort = i_sort(~sel); % remove indices for solutions whose lf-connection is monotonous
      sol = sol_sort(i_sort,:); val = val_sort(i_sort); n_sol = size(sol,1);
      fprintf('round %g of %g: %g solutions do not have a monotonous loss function connection with other remaining solutions\n', h,n_rnd,n_sol);   
    end
  end % end of reduction rounds

  % print elasticities of best solution
  for k=1:n_par; par.(parNm{k}) = sol(1,k); end
  save(['results_',my_pet,'.mat'], 'par');
  prt_elas

  % restore results_my_pet.mat and delete the copy
  if ismac || isunix
    system(['cp results_',my_pet,'_copy.mat results_',my_pet,'.mat']);
  else
    system(['powershell cp results_',my_pet,'_copy.mat results_',my_pet,'.mat']);
  end
  delete(['results_',my_pet,'_copy.mat'])
  
end

function sel = testMonotony(func,sol,parNm,val,par,data,auxData,weights)
  % sel(i) = true if lf traject to i is monotonous
  [n_sol, n_par] = size(sol); sel = false(n_sol,1);
  n_w = 10; w = linspace(0,1,n_w); % weights for par start and end
  for i = 1:n_sol
    for j = i+1:n_sol
      par_0 = par; for k=1:n_par; par_0.(parNm{k}) = sol(i,k); end % start (=best) par
      par_1 = par; for k=1:n_par; par_1.(parNm{k}) = sol(j,k); end % end par
      lf = zeros(n_w,1); lf(1) = val(i); lf(n_w) = val(j); % initiate loss function vector
      for i_lf = 2:n_w-1
        par_lf = par; for k=1:n_par; par_lf.(parNm{k}) = (1-w(i_lf))*sol(i,k)+w(i_lf)*sol(j,k); end 
        lf(i_lf) = lossFn(func, par_lf, data, auxData, weights);
      end
      sel(j) = all(lf(1:n_w-1)<lf(2:n_w));
    end
  end
end

function [sol_red, val_red] = reduceSol(sol, val)
  [n_sol, ~] = size(sol); sel=true(n_sol,1); tol = 1.05;
  for i=1:n_sol-1
    for j=i+1:n_sol
      ratio = max(sol([i;j],:),[],1)./min(sol([i;j],:),[],1); 
      if all(ratio<tol)
        if val(i) < val(j)
          sel(j) = false;
        else
          sel(i) = false;
        end 
      end
    end
    sol_red = sol(sel,:); val_red = val(sel);
  end
end