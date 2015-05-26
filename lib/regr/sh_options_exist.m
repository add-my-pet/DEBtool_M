function sh_options_exist
  global dataset Range all_in_one xtext ytext ztext plotnr
  
  if ~exist('dataset', 'var')
    dataset = [];
  end
  if ~exist('Range', 'var')
     Range = [];
  end
  if ~exist('all_in_one', 'var')
    all_in_one = [];
  end
  if ~exist('plotnr', 'var')
    plotnr = [];
  end
  if ~exist('xtext', 'var')
    xtext = [];
  end
  if ~exist('ytext', 'var')
    ytext = [];
  end
  if ~exist('ztext', 'var')
    ztext = [];
  end

