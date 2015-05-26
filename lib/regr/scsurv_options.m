%% scsurv_options
% Sets optioan for scsurv, see <nrregr_options.html *nrregr_options*>.

%%
function scsurv_options (key, val)
  if ~exist('key','var')
    nrregr_options
  elseif ~exist('val','var')
    nrregr_options(key)
  else
    nrregr_options(key, val);
  end

  
