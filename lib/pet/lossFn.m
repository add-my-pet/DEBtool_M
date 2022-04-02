%% mds4mmea
% classic multidimensional scaling applied to solutions of the mmea method

%%
function F = lossFn(func, par, data, auxData, weights)
  %  created at 2022/03/31 by Bas Kooijman
  
  %% Syntax
  % F = <../lossFn.m *lossFn*> (func, par, data, auxData, weights)
  
  %% Description
  % calculates loss function value for predict_my_pet, using parameters par
  % 
  % Input
  %
  % * func: character string with predict_my_pet
  % * par: structure with parameter values as from pars_init
  % * data: structure with data as from mydata
  % * auxData: structure with auxData as from mydata
  % * weight: structure with weights as from mydata
  %
  % Output
  %
  % * F: scalar with value of the loss function
  
  %% Remarks
  % the lossfunction is selected via global lossfunction, but sb is used if empty
  % the value of the lossfunction includes contributions of pseudo-data, contrary to lossfun.
  
  %% Example of use
  % Assuming that 
  %
  % * mydata_Acanthaster_planci
  % * pars_init_Acanthaster_planci
  % * predict_Acanthaster_planci
  %
  % are given:
  % [data, auxData, metaData, ~, weights] = mydata_Acanthaster_planci;
  % par = pars_init_Acanthaster_planci(metaData);
  % Fsb_1 = lossFn('predict_Acanthaster_planci', par, data, auxData, weights);
  %
  % prdData = predict_Acanthaster_planci(par, data, auxData);
  % Fsb_2 = lossfun(data, prdData, weights);
  % [Fsb_1 Fsb_2]
  
  global lossfunction
  
  close all

  if ~exist('lossfunction','var') || isempty(lossfunction)
    lossfunction = 'sb';
  end
  fileLossfunc = ['lossfunction_', lossfunction];
  
%   if isfield(data,'psd')
%    data = rmfield(data,'psd');
%   end

  q = rmfield(par, 'free'); 

  st = data;
  [nm, nst] = fieldnmnst_st(st); % nst: number of data sets
  for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    [~, k, npage] = size(auxVar);
    if k>=2 && npage==1% columns 2,3,.. are treated as data to be predicted if npage==1
      st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2:end));
    end
  end
  
  [nm, nst] = fieldnmnst_st(st); % nst: number of data sets
  [Y, meanY] = struct2vector(st, nm);
  W = struct2vector(weights, nm);

  f = feval(func, q, data, auxData);
  f = predict_pseudodata(q, data, f);
  [P, meanP] = struct2vector(f, nm);

  F = feval(fileLossfunc, Y, meanY, P, meanP, W);
end

function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:}); aux = aux(:); aux = aux(~isnan(aux));
    vec = [vec; aux];
    meanVec = [meanVec; ones(length(aux), 1) * mean(aux)];
  end
end
