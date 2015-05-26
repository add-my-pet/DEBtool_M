%% nmsurv_options
% Sets options for nmsurv, see <nmregr_options.html *nmregr_options*>

%%
function nmsurv_options (key, val)
  if ~exist('key','var')
    nmregr_options
  elseif ~exist('val','var')
    nmregr_options(key)
  else
    nmregr_options(key, val);
  end
  
