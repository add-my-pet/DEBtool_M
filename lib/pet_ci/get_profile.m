%% <../get_profile.m *get_profile*>
% created by Dina Lika 2018/09/03
%
  %% Syntax
  % [pars_profile, lf_profile] = <../get_profile.m *get_profile*>(pProfile,lowVal,upperVal,dim,nCont)
  %
  %% Description
  % Calculates the profile of the loss function for a parameter
  %
  % The theory is discussed in Marques et al. 2018. "Fitting Multiple
  % Models to Multiple Data Sets". J Sea Research, doi.org/10.1016/j.seares.2018.07.004
  %
  % Input
  %
  % * pProfile: the parameter for which the profile is calculated (string)
  % * lowVal: lower value of the profile interval
  % * upperVal: upper value of the profile interval
  % * dim: number of nodes, increase for a smooth profile
  % * nCont: number of continuations

  %
  % Output
  %
  % * lf_profile: vector with the values of the loss function
  % * pars_profile: vector with the parameter values

function [lf_profile, pars_profile] = get_profile(pProfile,lowVal,upperVal,dim,nCont)
  
global pet

% set all of the estimation options:
estim_options('default'); 
estim_options('report', 0);           % does not report to screen to save time

[data, auxData, metaData, txtData, weights] = feval(['mydata_', pet]);
[par, metaPar, txtPar] = feval(['pars_init_', pet], metaData);
filternm = ['filter_', metaPar.model];

estVal = eval(['par.',pProfile]);
aux    = linspace(lowVal, estVal, dim);
p_vec1 = sort(aux,'descend');
p_vec2 = linspace(estVal, upperVal, dim);

par.free.(pProfile)= 0;     % fix the "profile" parameter

% compute the profile from (low value you choose to best estimate)
lf1 = zeros(1,dim);
for j = 1:length(p_vec1)
    par.(pProfile)= p_vec1(j);  % replace the value of the "profile" parameter 
    % estimate parameters with the newData set, nCont continuations
    for k =1:nCont
        [par, info, nsteps] = petregr_f(@predict_data_psd, par, data, auxData, weights, filternm);
    end
    [prdData, info] = predict_data_psd(par, data, auxData);
    lf1(j) = lossfun(data, prdData, weights); % calculate the value of the loss function
end

% compute the profile from (best estimate to upperVal you choose )
lf2 = zeros(1,dim);
% initialize all parameters
[par, metaPar, txtPar] = feval(['pars_init_', pet], metaData);
par.free.(pProfile)= 0;     % fix the "profile" parameter

for j = 1:length(p_vec2)
    par.(pProfile)= p_vec2(j) ; % replace the value of the "profile" parameter 
    % estimate parameters with the newData set, nCont continuations
    for k =1:nCont
        [par, info, nsteps] = petregr_f(@predict_data_psd, par, data, auxData, weights, filternm);
    end
    [prdData, info] = predict_data_psd(par, data, auxData);
    lf2(j) = lossfun(data, prdData, weights); % calculate the value of the loss function
end
% merge the left and right branch
[x1 index] = sort(p_vec1,'ascend'); % order
y1 = lf1(index);
pars_profile = [x1 p_vec2(2:end)]; lf_profile = [y1 lf2(2:end)];
end

% auxiliary functions
function [prdData, info] = predict_data_psd(par, data, auxData)
% Predictions, using parameters and data
% Adds pseudodata predictions into predictions structure 

global pet

[prdData, info] = feval(['predict_',pet], par, data, auxData);
prdData = predict_pseudodata(par, data, prdData);

end
%%
function lf_val = lossfun(data, prdData, weights)
% compute the value of the loss function

global lossfunction

    fileLossfunc = ['lossfunction_', lossfunction];
    st = data; % take the field from prdData because data have also the pseudo-data
    [nm, nst] = fieldnmnst_st(data); % nst: number of data sets
  
    for i = 1:nst   % makes st only with dependent variables
        fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
        auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
        k = size(auxVar, 2);
    if k >= 2
        st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
    end
    end
    [Y, meanY] = struct2vector(st, nm);
    W = struct2vector(weights, nm);
    [P, meanP] = struct2vector(prdData, nm);
    lf_val = feval(fileLossfunc, Y, meanY, P, meanP, W);
end
%%
function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:});
    vec = [vec; aux];
    meanVec = [meanVec; ones(length(aux), 1) * mean(aux)];
  end
end
