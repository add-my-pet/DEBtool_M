%% get_pars_i
% Obtains parameters from growth and reprod data at multiple food levels


%%
function [par, U] = get_pars_i(p, w, par0)
  %  created 2007/08/12 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [par, U] = <../get_pars_i.m *get_pars_i*>(p, w, par0)
  
  %% Description
  % Obtains parameters from growth data at multiple food levels
  % Maturity and somatic maitenance rate coefficients are equal.
  %
  % Input
  %
  % * p: (n,4)-matrix with quantities (n > 1). The columns are:
  %
  %    1 f     % -  % scaled functiomal response
  %    2 L_b   % mm % length at birth
  %    3 L_i   % mm % ultimate length
  %    4 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %
  % * w: optional (n,3)-matrix with weight coefficient (default is ones)
  % * par0: optional (4,1 or 2)-matrix with initial estimate for par
  %
  % Output
  %
  % * par: (4,1 or 2)-matrix with in the first column
  %
  %    1 VHb   % d mm^2 % length at birth
  %    2 g     % -      % energy investment ratio
  %    3 kM    % d^-1   % somatic maintenance rate coefficient
  %    4 v     % mm/d   % energy conductance
  %    choice of sequence for consistency with get_par_h
  %    a second column has ones (iterate) or zeros (fix); default: ones
  %
  % * U: (n,2)-matrix with U^0 = M_E^0/\{\dot{J}_{EAm}\},
  %    U^b = M_E^b/\{\dot{J}_{EAm}\}
  
  %% Remarks
  %  iget_pars_i is inverse to get_pars_i
  
  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>
  
  ns = size(p,1); % number of data points
  
  if exist('w','var') == 0
    w = ones(ns, 3); % assign weight coefficients
  elseif isempty(w)
    w = ones(ns, 3); % assign weight coefficients    
  end

  % data for regression input
  f = p(:,1);
  fLbw = [p(:,[1 2]), w(:,1)]; 
  fLiw = [p(:,[1 3]), w(:,2)]; 
  frBw = [p(:,[1 4]), w(:,3)]; 

  if exist('par0','var') == 1
    par = par0;
  else
    % get kM and g from 1/rB = 3 (f + g)/ (kM g)
    % linear regression of y = 1/rB against x = f
    xm = sum(f)/ ns; x2m = sum(f .* f)/ ns;
    ym = sum(1 ./ frBw(:,2))/ ns; xym = sum(f./ frBw(:,2))/ ns;
    b = (xym - xm * ym)/ (x2m - xm^2); % slope
    a = ym - b * xm;                   % intercept
    kM = max(1e-3, 3/ a); g = max(1e-3, a/ b); % result from regression

    % get v from Lm = v/ (kM g)
    Lm = sum(fLiw(:,2) ./ f)/ns;   % 'mean' maximum length
    v = Lm * kM * g;  Lb = sum(fLbw(:,2))/ ns;
    VHb = Lb^3 * g/ v;
    par = [VHb; g; kM; v]; % pack output temporarily
  end
 
  if 0 % final parameter estimation
    nmregr_options('max_step_number',10000);
    nmregr_options('max_fun_evals',10000);
    [par info] = ...
      nmregr('fnget_pars_i', par, fLbw, fLiw, frBw);
  else 
    nrregr_options('max_step_number',100);
    nrregr_options('max_step_size',10);
    [par info] = ...
      nrregr('fnget_pars_i', par, fLbw, fLiw, frBw);
  end
  
  % prepare second output
  VHb = par(1,1); g = par(2,1); kM = par(3,1); v = par(4,1); 
  U = zeros(ns,2); % initiate second output
  Lm = v/ (kM * g); u2U = v^2 / g^2/ kM^3; vHb = VHb/u2U; 
  for i = 1:ns
    Lb = Lm * get_lb([g, 1, vHb], f(i));
    U0 = u2U * get_ue0([g, 1], f(i), Lb/ Lm); % initial scaled reserve
    Ub = f(i) * Lb^3/ v; % scaled reserve at birth
    U(i,:) = [U0, Ub];
  end
