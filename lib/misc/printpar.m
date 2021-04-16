%% printpar
% Print parameter names, values and standard deviations

%%
function printpar(varargin)
  % created by Bas Kooijman, modified 2009/02/18, 2010/08/05, 2020/01/12
  
  %% Syntax 
  % <../printpar.m *printpar*>(varargin)
  
  %% Description
  % Print parameter names, values and standard deviations to screen. 
  % The names of the parameters should be collected in a (r,c)-matrix, while the values and the (optional) standard deviations are r-vectors. 
  % Text for a header is also optional. 
  %
  % Input:
  %
  % * fid: optional integer for file-identification, see fopen
  % * nm: n-vector with text for parameter values (cells)
  % * p: n-vector with parameter values
  % * optional n-vector with standard deviations
  % * optional text for header
  
  %% Example of use 
  % nm = {'initial length '; 'growth rate'}; p = [1; .5]; sd = [.5; 1.5]; 
  % printpar(nm, p, sd); or printpar(nm, p); or printpar(nm, p, [], 'myheader');
    
  if isa(varargin{1},'cell') && nargin == 4
    fid = 1; % write to screen
    nm  = varargin{1};
    p   = varargin{2};
    sd  = varargin{3};
    if isempty(sd); zeros(length(nm),0); end
    txt = varargin{4};
  elseif isa(varargin{1},'cell') && nargin == 3
    fid = 1; % write to screen
    nm  = varargin{1};
    p   = varargin{2};
    sd  = varargin{3};
    txt = 'Parameter values and standard deviations';
  elseif isa(varargin{1},'cell') && nargin == 2
    fid = 1; % write to screen
    nm = varargin{1};
    p  = varargin{2};
    txt = 'Parameter values';
  elseif nargin == 5 
    fid = varargin{1}; % write to specified file
    nm  = varargin{2};
    p   = varargin{3};
    sd  = varargin{4};
    txt = varargin{5};
  elseif nargin == 4
    fid = varargin{1}; % write to specified file
    nm  = varargin{2};
    p   = varargin{3};
    sd  = varargin{4};
    txt = 'Parameter values and standard deviations';
  elseif nargin == 3
    fid = varargin{1}; % write to specified file
    nm  = varargin{2};
    p   = varargin{3};
    txt = 'Parameter values';
  end
  
  if isempty(sd)
    n = 2; 
  else
    n = nargin;
  end
     
  r = size(nm, 1);
  fprintf(fid, [txt, ' \n']);
  if n == 2 && isnumeric(p)
    for i = 1:r
      fprintf(fid, '%s %8.4g \n', nm{i,:}, p(i,1));
    end
  elseif n == 2 
    for i = 1:r
      fprintf(fid, '%s %s \n', nm{i,:}, p(i,:));
    end
  else
    for i = 1:r
      fprintf(fid, '%s %8.4g %8.4g \n', nm{i,:}, p(i,1), sd(i));
    end
  end
