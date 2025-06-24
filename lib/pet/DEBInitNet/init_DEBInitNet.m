%% init_DEBInitNet
% Runs the DEBInitNet initialization method

function [par, metaPar, txtPar] = init_DEBInitNet(data, auxData, metaData, txtData)
% created 2025/06/20 by Diogo F. Oliveira

%% Syntax
% [par, metaPar, txtPar] = <../init_DEBInitNet.m *init_DEBInitNet*> (data, auxData, metaData)

%% Description
% Uses data and metadata from the mydata_my_pet.m file to give an initial estimate of DEB model
% parameter values.
%  
% The method computes the following parameters
%   z, [p_M], v, kap, k_J, E_Hb, E_Hp, E_G
% For abj species, the method also computes
%   E_Hj
% And for stx species, the method also computes
%   E_Hx
%
% Only parameters that are set to free in pars_init_my_pet.m are replaced by the method. If a
% parameter is not free, then the method will use the value in pars_init_my_pet.m.
%
% The method is only implemented for typified models std, stf, stx, and abj. 
%
% Converts data to standard units using the Symbolic Math Toolbox. If the toolbox is not available,
% then it assumes the data is in standard units.
% The following datasets are required to exist
%   ab, am, Wwb, Wwp, Wwi, Ri
% More details on the datasets used for input are given in <fetch_input_for_DEBInitNet.m *fetch_input_for_DEBInitNet*>
%
% Input
%
% * data: structure with values of data (only zero-variate data are used)
% * auxData: structure with auxiliary data (includes temperatures)
% * metaData: structure with ecocode data (used as input)
% * txtData: structure with information on the data (used to convert data to standard units)
%
% Output
% * par: structure with parameter values (only modifies the parameters above)
% * metaPar: structure with information on metaparameters (not modified, used to get the model type)
% * txtPar: structure with information on parameters (not modified)

%% Remarks 
% Called by <../pet/html/estim_pars.html *estim_pars*> if pars_init_method = 3.
% txtPar and metaPar are set in <pars_init_my_pet.html *pars_init_my_pet*> and not modified.
%
% Description of the DEBInitNet is given in Oliveira et al. (2025) (in prep)
%
% Only sets parameters with the corresponding name. For example, if parameters for males exist, they
% are not automatically set. A warning will be issued to make the user aware of this. Best practice
% is to assign the initial values given by this method to those parameters.
%

%% Check if method can be applied
[par, metaPar, txtPar] = feval(['pars_init_', metaData.species], metaData); % set pars and chem 
if ~par.free.z
    error('Parameter ''z'' should be set free.')
end
if ~any(strcmp(metaPar.model, {'std', 'stf', 'stx', 'abj'}))
    error('Model type is not compatible. DEBInitNet is only implemented for model types std, stf, stx, and abj.')
end

%% Get input from AmP files
[inputData, flag] = fetch_input_for_DEBInitNet(data, auxData, metaData, txtData, par, metaPar);
tryOtherMethodString = [
    'DEBInitNet initialization method cannot be applied. ' ...
    'If the data exists, check that it follows the naming convention. ' ...
    'If not, try another initialization method. \n'];
% Check that all inputData was available
switch flag
    case 1
        error(['Missing data on age at birth. \n\n' tryOtherMethodString])
    case 2
        error(['Missing data on lifespan. \n\n' tryOtherMethodString])
    case 3
        error(['Missing data on weight at birth, puberty, or ultimate. \n\n' tryOtherMethodString])
    case 4
        error(['Missing data on reproduction rate. \n\n' tryOtherMethodString])
end

%% Load model
modelStructureFile = 'deb_init_net.mat';
nn = DEBInitNet(modelStructureFile);

%% Model predictions
yPred = nn.predict(inputData);

%% Convert model predictions to initial parameters
predPar = struct();
predPar.p_M = yPred(1);
predPar.kap = 1 - yPred(2);
predPar.v = yPred(3);
predPar.E_Hp = yPred(8);
predPar.k_J = yPred(9);

% Impute fixed pars
parNamesToImpute = {'p_M', 'kap', 'v', 'E_Hp', 'k_J'};
for p=1:numel(parNamesToImpute)
    parName = parNamesToImpute{p};
    if isfield(par, parName) && ~par.free.(parName)
        predPar.(parName) = par.(parName);
    end
end

% Prediction for maturities depending on model type
if strcmp(metaPar.model, 'abj')
    % E_Hj
    if par.free.E_Hj
        predPar.E_Hj = predPar.E_Hp * yPred(7);
    else
        predPar.E_Hj = par.E_Hj;
    end
    % E_Hb
    if par.free.E_Hb
        predPar.E_Hb = predPar.E_Hj * yPred(6);
    else
        predPar.E_Hb = par.E_Hb;
    end
elseif strcmp(metaPar.model, 'stx')
    if par.free.E_Hx
        predPar.E_Hx = predPar.E_Hp * yPred(5) * 1.01;
    else
        predPar.E_Hx = par.E_Hx;
    end
end
if ~isfield(predPar, 'E_Hb')
    if par.free.E_Hb
        predPar.E_Hb = predPar.E_Hp * yPred(5);
    else
        predPar.E_Hb = par.E_Hb;
    end
end

% Defining E_Hj and E_H if it was not computed
if ~isfield(predPar, 'E_Hj')
    predPar.E_Hj = 1.01 * predPar.E_Hb;
end
if ~isfield(predPar, 'E_Hx')
    predPar.E_Hx = 1.01 * predPar.E_Hb;
end

% s_M=1 if the model is not abj
if strcmp(metaPar.model, 'abj')
    s_M = 1 / yPred(10);
else
    s_M = 1;
end
% Prediction for z
s_p_M = yPred(4);
z3 = predPar.k_J * predPar.E_Hp * predPar.kap / (s_M^3 * s_p_M * (1-predPar.kap) * predPar.p_M);
predPar.z = nthroot(z3, 3);

%% Predict [E_G]
d_V = get_d_V(metaData.phylum, metaData.class);
kap_G = 0.8;
w_V = 23.9;
predPar.E_G = par.mu_V * d_V / kap_G / w_V;


%% Set parameter values in par struct if they exist and are free
fprintf('Computed parameters: \n')
predParNames = fieldnames(predPar);
for p=1:numel(predParNames)
    parName = predParNames{p};
    if isfield(par, parName) && par.free.(parName)
        fprintf('%-4s - %.4e\n', parName, predPar.(parName))
        par.(parName) = predPar.(parName);
    end
end
