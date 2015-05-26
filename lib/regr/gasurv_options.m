%% gasurv_options
% Sets optioan for gasurv, see <garegr_options.html *garegr_options*>.

%%
function gasurv_options (key, val)
  if ~exist('key', 'var')
    garegr_options
  elseif ~exist('val', 'var')
    garegr_options(key)
  else
    garegr_options(key, val);
  end
