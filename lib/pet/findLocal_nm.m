%% findLocal_nm
% find local minima for a target parameter
%%
function [parLf, valLf, parVal] = findLocal_nm(parLfNm,parLfMin,parLfMax,nLf,nCont)
  %  created at 2022/04/02 by Bas Kooijman
  
  %% Syntax
  % [parLf, valLf, parVal] = <../findLocal_nm.m *findLocal_nm*> (parLfNm,parLfMin,parLfMax,nLf,nCont)
  
  %% Description
  % Finds local minima using the nm method with 
  % varying a target parameter, estimating the other free parameters through continuation, 
  % Then a graph of the loss function as function of the target parameter is plotted
  % and local minima are searched using the .
  % 
  % Input
  %
  % * parLfNm: string with name of the parameter for which the profile is calculated 
  % * parLfMin: scalar with lower value of the profile interval
  % * parLfMax: scalar with upper value of the profile interval
  % * nLf: number of nodes, increase for a smooth profile
  % * nCont: number of continuations
  %
  % Output
  %
  % * parLf: nLf-vector with values for target par
  % * valLf: nLf-vector of loss function values at free parameters
  % * parVal: (nLf,k)-matrix of n solutions for k free parameters
  
  %% Remarks
  % Run in directory that has the mydata-, pars_init-, predict- files.
  % Assumes that global pets has the name of the entry as cell string.
  
  %% Example of use
  % [parLf,valLf,parVal] = findLocal_nm_rB('v',0.01,0.9,20,2);
  
  global pets loss_function
    
  my_pet = pets{1};
  matNm = ['results_', my_pet];
  func = ['predict_', my_pet];

  % fill structures
  eval(['[data, auxData, metaData, txtData, weights] = mydata_', my_pet,';']);
  eval(['[par, metaPar, txtPar] = pars_init_', my_pet, '(metaData);']);  

  % initiate estim_options settings
  estim_options('default'); % method nm
  estim_options('results_output', 0); % only write results_my_pet.mat-file
  estim_options('report', 0); % no printing to screen
  estim_options('pars_init_method', 2); % use parameter from pars_init
  estim_options('max_step_number', 500);
  estim_options('method', 'no');
  estim_pars; % write results_my_pet.mat
  estim_options('method', 'nm');
  
  % get parNm of free parameters, 
  load(matNm,'par')
  free = par.free; free.(parLfNm) = 0; freeNm = fields(free); n = size(freeNm,1);
  sel = zeros(n,1); for i=1:n; sel(i)=free.(freeNm{i});end
  parNm = fields(par); parNm(end) = ''; parNm = parNm(sel==1); n_par = length(parNm);
  
  % edit free-setting of parLfNm in pars_init
  pars_init = fileread(['pars_init_', my_pet,'.m']);
  i_0 = strfind(pars_init, ['free.', parLfNm]); i_1 = strfind(pars_init(i_0:end), '='); i_0 = i_0 + i_1(1) + 1;
  pars_init = [pars_init(1:i_0-2),' 0; ', pars_init(2+i_0:end)];
  fid = fopen(['pars_init_', my_pet, '.m'], 'w+');
  fprintf(fid,'%s', pars_init); fclose(fid);

  % set parLf-vector for scanning and copy global min and store its lossfunction
  parLf = linspace(parLfMin, parLfMax, nLf)'; % column-vector of target parameter values
  [~, i_0] = sort(abs(parLf - par.(parLfNm))); i_0 = i_0(1); % index of v_lf that is closest to v
  valLf = NaN(nLf, 1); parVal = NaN(nLf, n_par); % initiate lossfunction, par-values
  parVal0 = zeros(n_par,1); for i=1:n_par; parVal0(i) = par.(parNm{i}); end % pars at globel min
  valLf0 = lossFn(func, par, data, auxData, weights); % lf at global minimum
  parLf0 = par.(parLfNm); % par at global minimum

  % estimate pars with fixed parLfNm
  estim_options('pars_init_method', 1);
  % first upper-branch of parLf, start closest to global min value for parLfNm
  for i = i_0:nLf
    load(matNm,'par')
    par.(parLfNm) = parLf(i);
    save(matNm,'par')
    for j=1:nCont; estim_pars; end
    load(matNm,'par')
    valLf(i) = lossFn(func, par, data, auxData, weights);
    for j=1:n_par; parVal(i,j) = par.(parNm{j}); end
    fprintf('value %g, v: %g; lf: %g\n', i, parLf(i), valLf(i));
  end
  % restore par-setting at start
  for j=1:n_par; par.(parNm{j}) = parVal0(j); end
  save(matNm,'par')
  % now lower branch with fixed parLfNm
  for k = 1:i_0-1
    i = i_0 - k; % reverse order to start close to global min value for parLfNm
    load(matNm,'par')
    par.(parLfNm) = parLf(i);
    for j=1:n_par; par.(parNm{j}) = parVal0(j); end
    save(matNm,'par')
    for j=1:nCont; estim_pars; end
    load(matNm,'par')
    valLf(i) = lossFn(func, par, data, auxData, weights);
    for j=1:n_par; parVal(i,j) = par.(parNm{j}); end
    fprintf('value %g, v %g; lf %g\n', i, parLf(i), valLf(i));
  end
 
  prt_tab({valLf, parLf, parVal}, ['loss fn'; parLfNm; parNm])

  % insert global minimum and add parLfNm to parNm list
  parLf = [parLf(1:i_0-1); parLf0; parLf(i_0:end)];
  valLf = [valLf(1:i_0-1); valLf0; valLf(i_0:end)];
  parVal = [parLf, [parVal(1:i_0-1,:); parVal0'; parVal(i_0:end,:)]];
  parNm = [parLfNm;parNm]; n_par = n_par+1; nLf = nLf+1; % prepend v to par-names
  
  % plot lossfunction as function of parLfNm
  plot(parLf, valLf, 'or')
  xlabel(parLfNm)
  ylabel(['lossfunction ', loss_function])
    
  % locate local minima in lf-profile
  sel = zeros(nLf,1); 
  if valLf(2)>valLf(1); sel(1) = true; end; if valLf(nLf)<valLf(nLf-1); sel(n_v) = true; end
  sel(2:nLf-1) = (valLf(2:nLf-1)<valLf(1:nLf-2)) & (valLf(3:nLf)>valLf(2:nLf-1));
  valLf = valLf(sel==1); parLf = parLf(sel==1); parVal = parVal(sel==1,:); nLf = length(valLf);
  
  % edit free-setting of parLfNm in pars_init
  pars_init = fileread(['pars_init_', my_pet,'.m']);
  i_0 = strfind(pars_init, ['free.',parLfNm]); i_1 = strfind(pars_init(i_0:end), '='); i_0 = i_0 + i_1(1) + 1;
  pars_init = [pars_init(1:i_0-2),' 1; ', pars_init(2+i_0:end)];
  fid = fopen(['pars_init_', my_pet, '.m'], 'w+');
  fprintf(fid,'%s', pars_init); fclose(fid);
  
  % find local minima, starting from pars that correspond with local minima on loss function
  estim_options('simplex_size', 0.005); % small simplex size to avoid loss of local min
  fprintf('%g local minima found\n', nLf);
  for i = 1:nLf
    load(matNm,'par')
    for j=1:n_par; par.(parNm{j}) = parVal(i,j); end
    save(matNm,'par')
    for j=1:nCont; estim_pars; end
    load(matNm,'par')
    parLf(i)=par.(parLfNm); for j=1:n_par; parVal(i,j) = par.(parNm{j}); end
    valLf(i) = lossFn(func, par, data, auxData, weights);
    fprintf('solution %g, %s %g; lf %g\n', i, parLfNm, parLf(i), valLf(i));
  end

  prt_tab({valLf, parVal}, ['loss fn'; parNm])
  
  % remove solutions that are not local minima
  fprintf('start checking monotony of loss functions from one solution to the other\n');
  if nLf>1
    [valLf_sort, i_sort] = sort(valLf); 
    parVal_sort = parVal(i_sort,:);
    sel = testMonotony(func,parVal_sort,parNm,valLf_sort,par,data,auxData,weights);
    i_sort = i_sort(~sel); % remove indices for solutions whose lf-connection is monotonous
    parVal = parVal_sort(i_sort,:); valLf = valLf_sort(i_sort); nLf = size(parVal,1);
      fprintf('%g solutions do not have a monotonous loss function connection with other remaining solutions\n', nLf);  
  end
  
  % refine local minima
  for i = 1:nLf
    load(matNm,'par')
    for j=1:n_par; par.(parNm{j}) = parVal(i,j); end
    save(matNm,'par')
    estim_pars;
    load(matNm,'par')
    for j=1:n_par; parVal(i,j) = par.(parNm{j}); end
    valLf(i) = lossFn(func, par, data, auxData, weights);
    fprintf('solution %g, %s %g; lf %g\n', i, parLfNm, parLf(i), valLf(i));
  end

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