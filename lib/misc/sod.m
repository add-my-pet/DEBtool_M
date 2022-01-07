%% sod
% computes scaled outlier distances form a array of trait values

%%
function dist = sod(val, in_outlier, norm)
% created 2022/01/07 by Bas Kooijman

%% Syntax
% dist = <../sol.m *sod*> (val, in_outlier, norm) 

%% Description
% Computes scaled outlier distances from a array of trait values: 
% the mean distance between outlier and other species, divided by the mean distance between all other species.
% Distances between outlier species are not taken into account.
% All species, except the ones in the indices in_outlier, are treated as other species.
% So n-m other species exist, but if input in_outlier is not specified: n-1 other species exist
%
% Input:
%
% * val: (n,k)-array with trait values; species in rows, traits in columns
% * in_outlier: optional m-vector of indicies for species that are treated as outliers (default: all species one-by-one)
% * norm: optional boolean for loss function F_sb (0, default) or F_su (1) as distance measure
%
% Output:
%
% * dist: m-vector with scaled outlier distances

%% Remarks
% The distance measures are DEBtool_M/lib/regr/lossfuction_sb or lossfuction_su.


%% Example of use
% dist = sod(rand(10,2)) 
% See mydata_sod for example of use

  n = size(val,1); % total number of species
  if ~exist('in_outlier','var') || isempty(in_outlier)
    in_outlier = 0; % all species are outliers one-by-one
    dist = zeros(n,1);
  else
    n_outlier = length(in_outlier);
    dist = zeros(n_outlier,1);
  end
    
  if ~exist('norm','var') || isempty(norm)
    norm = 0; % symmetric bounded loss function
  end
  
  if in_outlier == 0 % all species are outliers one-by-one
    for i = 1:n
      in_other = 1:n; in_other(i) = [];
      d_10 = distAB(val(i,:),val(in_other,:),norm);
      d_00 = distAB(val(in_other,:),val(in_other,:),norm);
      dist(i) = mean(d_10(:))/mean(d_00(:));
    end
  else % outliers are in in_outlier, the rest is other 
    in_other = 1:n; in_other(in_outlier) = [];
    d_00 = distAB(val(in_other,:),val(in_other,:),norm);
    md_00 = mean(d_00(:)); % mean distance between other species
    for i = 1:n_outlier      
      d_10 = distAB(val(in_outlier(i),:),val(in_other,:),norm);
      dist(i) = mean(d_10(:))/md_00;
    end
  end

  
end

function d = distAB(val_A, val_B, norm)
  n_A = size(val_A,1); n_B = size(val_B,1); d = zeros(n_A, n_B);  
  for i = 1:n_A
    for j = 1:n_B
      if ~norm 
        d(i,j) = sum((val_A(i,:) - val_B(j,:)).^2 ./ (val_A(i,:).^2 + val_B(j,:).^2));
      else
        d(i,j) = sum((val_A(i,:) - val_B(j,:)).^2 .* (1./val_A(i,:).^2 + 1./val_B(j,:).^2));
      end
    end
  end
end
