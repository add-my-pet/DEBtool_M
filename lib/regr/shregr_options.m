%% shregr_options
% Sets options for function 'shregr'

%%
function shregr_options (key, item, val)
  %  created at 2001/09/07 by Bas Kooijman; 2005/01/27
  
  %% Syntax
  % <../shregr_options.m *shregr_options*> (key, item, val)
  
  %% Description
  % Sets options for function 'shregr' one by one
  %
  % Input
  %
  % * key
  %
  %    'dataset': number of data set
  %    'Range': range of xaxis
  %    'all_in_one': 0 for separate figures, 1 for subfigures
  %    'XTXT': text for xaxis
  %    'YTXT': text for yaxis
  %
  % * item
  % * val: scalar with number
  %
  % Output
  %
  % * no output, but globals are set to values or values printed to screen
  
  %% Remarks
  % Run 'shregr' first to initiate option settings

  global dataset Range all_in_one XTXT YTXT;

    if ~exist('key', 'var')
      key = 'unkown';
    end

    switch key

      case 'default'
	    dataset = ''; 
        Range = ''; 
        all_in_one = ''; 
        XTXT = ''; 
        YTXT = '';
   
      case 'dataset'
	    dataset = item;

      case 'Range'
	    Range(item, :) = val;

      case 'xlabel'     
        if ~exist('val', 'var')
	      val = item; item = 1;
	    end	 
        XTXT{item,1} = val;
        
      case 'ylabel'
        if ~exist('val', 'var')
	      val = item; item = 1;
	    end	    
        YTXT{item,1} = val;
          
      case 'all_in_one'
    	all_in_one = item;
       
      otherwise 
        fprintf('unkown option \n');
	
    end
