%% <../get_lf_distribution.m *get_lf_distribution*>
% created by Dina Lika 2018/08/27; modified 2020/12/12
  %% Syntax
  % [p_vec, lf] = <../get_lf_distribution.m *get_lf_distribution*>(nTrials, nCont)
  %
  %% Description
  % Calibration step for the interval estimation
  % Calculates the global minima of the loss function, 
  % that correspond with nTrials, say 500 or 1000, 
  % Monte Carlo simulations of data that has a scatter equal to the observed scatter.
  %
  % The theory is discussed in Marques et al. 2018. "Fitting Multiple
  % Models to Multiple Data Sets". J Sea Research, doi.org/10.1016/j.seares.2018.07.004
  %
  %% Input
  %
  % * nTrials: number of Monte Carlo data sets
  % * nCont: number of continuations
  %
  %% Output
  %
  % * lf: vector with the values of the loss function
  % * p_vec: matrix with the (free) parameter values
  % * name_par: names of free parameters
  %% Example of use
  %  get_lf_distribution(10, 5); % for 10 MonteCarlo  trials and 5
  %  continuations of the estimation 

function [lf, p_vec, nm] = get_lf_distribution(nTrials, nCont)

% Script - Calibration step for the interval estimation
% calls generate_data

global pet

% set all of the estimation options:
estim_options('default'); 
nmregr_options('report', 0);  % does not report to screen to save time

[data, auxData, metaData, txtData, weights] = feval(['mydata_', pet]); 
[par, metaPar, txtPar] = feval(['pars_init_', pet], metaData);
[prdData0, info] = feval(['predict_',pet], par, data, auxData); 
filternm = ['filter_', metaPar.model];

% compute cv to be used to generate new datasets
% cv = the mean of the absolute difference between observed and predicted 
% values divided by the predicted value
st = data; 
[nm, nst] = fieldnmnst_st(prdData0); % nst: number of data sets, take the field from prdData to exclude pseudo-data
cv_vec = zeros(nst,1);
for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    k = size(auxVar, 2);
    if k >= 2
        st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
    end
    prdAux  = getfield(prdData0, fieldsInCells{1}{:});
    dataAux = getfield(st, fieldsInCells{1}{:});
    cv_vec(i) = sum(abs(dataAux-prdAux)./prdAux)/length(prdAux);
end
cv = mean(cv_vec);

% generate new datasets, estimate parameters and calculate the value of the
% loss function
p_vec=[]; lf = zeros(nTrials,1); 
for j=1:nTrials
     fprintf(['Trial ', num2str(j), '\n']);
    newData = generate_data(data, prdData0, cv);  % generate new datasets
    % estimate parameters with the newData set, nCont continuations
    for k =1:nCont
        [par, info, nsteps] = petregr_f(@predict_data_psd, par, newData, auxData, weights, filternm);
    end
    [prdData, info] = predict_data_psd(par, newData, auxData);
    lf(j) = lossfun(newData, prdData, weights); % calculate the value of the loss function
    % save in p_vec only those that are estimated 
    p = [];
    [nm, npar] = fieldnmnst_st(par.free); % nst: number of pars 
    for i = 1:npar   % makes st only with dependent variables
        fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
        auxVar = getfield(par.free, fieldsInCells{1}{:});   % data in field nm{i}
        auxPar = getfield(par, fieldsInCells{1}{:});   % data in field nm{i}
        if auxVar == 1
            p = setfield(p, fieldsInCells{1}{:}, auxPar);
        end
    end
    % convert structure to vector
    [nm, np] = fieldnmnst_st(p); % nst: number of pars 
    [p_free, x] = struct2vector(p, nm);
    p_vec = [p_vec, p_free]; % save parameter estimates
    
    save('intCalibrate', 'lf', 'p_vec', 'nm'); % save intermidiate values
end
end

% This function generates new data sets  
% from log normal distribution with mean the estimated value and 
%
function newData = generate_data(data, prdData, cv)

st = data; % take the field from prdData because data have also the pseudo-data
[nm, nst] = fieldnmnst_st(prdData); % nst: number of data sets

for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    prdAux = getfield(prdData, fieldsInCells{1}{:}); 
    k = size(auxVar, 2);
    if k < 2 % zero-variate data
        new = add_noise(prdAux,cv, 1);
    else     % uni-variate data
        new = zeros(length(prdAux), 2); 
        for j = 1:length(prdAux)
            new(j,2) = add_noise(prdAux(j),cv, 1); % dependent variable
            new(j,1) = auxVar(j,1);                % independent variable
        end      
    end
    newData.([nm{i}]) = new;
end
newData.psd = data.psd;  % add pseudodata
end

% auxiliary functions :
function [prdData, info] = predict_data_psd(par, data, auxData)
% Predictions, using parameters and data
% Adds pseudodata predictions into predictions structure 

global pet

[prdData, info] = feval(['predict_',pet], par, data, auxData);
prdData = predict_pseudodata(par, data, prdData);

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

