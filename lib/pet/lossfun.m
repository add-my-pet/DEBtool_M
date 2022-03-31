%% lossfun
% gets value of loss function

%%
function lf_val = lossfun(data, prdData, weights)
% created by Dina Lika 2018/08/27; modified 2020/12/12, 2021/01/16, 2022/01/09, 2022/03/31 by Bas Kooijman

%% Syntax
% lf_val = <../lossfun.m *lossfun*> (data, prdData, weights)

%% Description
% Gets value of loss function
%
% Input:
%
% * data: structure as specified by mydata-files
% * prdData: structure as specified by predict-files
% * weights: structure as specified by mydata-files
%
% Output:
%
% * lf_val: value of loss function

%% Remarks
% the output does not include contributions from the augmented term or from pseudo-data.
% Uses global "lossfunction" with strings re, sb or su, see DEBtool_M/lib/regr

  global lossfunction
    
  if ~exist('lossfunction','var') || isempty(lossfunction)
    lossfunction = 'sb';
  end

  if isfield(data,'psd')
    data = rmfield(data,'psd');
  end
  
  st = data; % take the field from prdData because data have also the pseudo-data
  [nm, nst] = fieldnmnst_st(data); % nst: number of data sets
  
  for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    k = size(auxVar, 2);
    if k > 1
      st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
    end
  end
  [Y, meanY] = struct2vector(st, nm);
  W = struct2vector(weights, nm);
  [P, meanP] = struct2vector(prdData, nm);
  lf_val = feval(['lossfunction_', lossfunction], Y, meanY, P, meanP, W);
end

function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:});
    sel = ~isnan(aux);
    vec = [vec; aux];
    meanVec = [meanVec; ones(length(aux), 1) * mean(aux(sel))];
  end
end