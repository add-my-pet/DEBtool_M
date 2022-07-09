%% ismin
% checks if a parameter combination is at a local minimum of the loss function
%%
function [info, lf] = ismin(my_pet, del)
  %  created at 2022/07/07 by Bas Kooijman
  
  %% Syntax
  % [info, lf] = <../ismin.m *ismin*> (my_pet, del)
  
  %% Description
  % checks if a parameter combination is at a local minimum of the loss function 
  % by comparing its value against values where all free parameters are multiplied 
  % by 1-del, 1 and 1+del independently, which gives 3^n combinations for n free parameters. 
  % 
  % Input
  %
  % * my_pet: char string with name of pet
  % * del: optional scalar with perturbation factor (default 0.05)
  %
  % Output
  %
  % * info: boolean: true if local minimum, false if not
  % * lf: scalar with value of the loss function
  
  %% Remarks
  % Assumes local existence of my_data_my_pet, pars_init_my_pet, predict_my_pet.
  % This function only works for lossfunction_sb 
  % and is really computationally intensive if number of free parameter exceeds 6;
  
  %% Example of use
  % First copy add_my_pet/entries/Dipodomys_deserti to local and reduce # free pars by editing pars_init: 
  % ismin('Dipodomys_deserti', 0.05);
  
  if ~exist('del','var')
    del = 0.05;
  end
  
  % initiate par,data,auxData,weights for calls to lossfunction
  % the free pars in par will be overwritten
  eval(['[data_st, auxData, metaData, txtData, weights] = mydata_', my_pet,';']);
  eval(['[par, metaPar, txtPar] = pars_init_', my_pet, '(metaData);']);  
  func = ['predict_', my_pet];
  free = par.free; parNm = fields(free); % par names
  n_par = length(parNm); i_free = [];
  for i = 1:n_par; if free.(parNm{i}); i_free = [i_free, i]; end; end
  n_free = length(i_free);
  
  % catenate dependent data, weights in a single vector
  nm = fieldnmnst_st(data_st); % names of data sets
  data = data_st; psd = data.psd; data = rmfield(data, 'psd'); % copy to remove independent data
  for i = 1:length(fields(data))
    if size(size(data.(nm{i})),2) == 2 && size(data.(nm{i}),2) > 1
      data.(nm{i})(:,1) = []; 
    end 
  end
  data.psd = psd; [data, meanData] = struct2vector(data, nm);
  weights = struct2vector(weights, nm);
  sel = ~isnan(data); % fill sel to exclude NaN's in data
  
  % compose txt to fill perturbation factors pert in nested loops, here for example with n=3 
  % txt = 'for i1=-1:1;for i2=-1:1;for i3=-1:1;k=k+1;pert(k,:)=[1+del*i1, 1+del*i2, 1+del*i3];end;end;end'
  n_pert = 3^n_free; % # of perturbations
  i_ref = round(n_pert/2 + 0.5); % row-index of pert with all ones
  pert = zeros(n_pert, n_free); val = zeros(n_pert,1); k = 0;   txt=''; % initiate
  for i=1:n_free
    txt = [txt, 'for i', num2str(i), '=-1:1;'];
  end
  txt = [txt, 'k=k+1; pert(k,:)=['];
  for i=1:n_free
    txt = [txt, '1+del*i', num2str(i), ','];
  end
  txt(end) = ']';
  for i=1:n_free
    txt = [txt, ';end'];
  end
  eval(txt); % fill perturbation factors
  
  % get loss function sb for perturbed pars
  par = rmfield(par, 'free'); par_ref = par; % copy par-structure to reference
  for i = 1:n_pert
    for j = 1:n_free; par.(parNm{j}) = par_ref.(parNm{j}) * pert(i,j); end
    %val(i) = lossFn(func, par, data, auxData, weights);
    f = feval(func, par, data_st, auxData);
    f = predict_pseudodata(par, data_st, f);
    [prdData, meanPrdData] = struct2vector(f, nm);
    val(i) = weights(sel)' * ((data(sel) - prdData(sel)).^2 ./ (meanData(sel).^2 + meanPrdData(sel).^2));
    %fprintf([num2str(i), ' ', num2str(val(i)), '\n']);
  end
  %
  lf = val(i_ref); % value of loss function at un-perturbed parameter combination
  info = all(lf <= val);
    
  figure(1) % plot survivor function of loss function values
  xy = surv(val); plot(xy(:,1),xy(:,2),'r');
  hold on
  plot([lf; lf], [0; 1], 'g');
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('loss function at perturbed parameters') 

end

function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:}); aux = aux(:); 
    vec = [vec; aux(~isnan(aux))];
    meanVec = [meanVec; ones(length(aux), 1) * mean(aux)];
  end
end