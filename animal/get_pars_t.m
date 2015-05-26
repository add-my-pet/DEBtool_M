%% get_pars_t
% Obtains parameters from growth and reprod data at multiple food levels

%%
function [par, U, Ep] = get_pars_t(p, w, par0)
  %  created 2006/12/15 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [par, U, Ep] = <../get_pars_t.m *get_pars_t*>(p, w, par0)
  
  %% Description
  % Obtains parameters from growth and reprod data at multiple food levels.
  % Maturity and somatic maitenance rate coefficients are equal.
  % The parameter kapR is fixed.
  %
  % Input
  %
  % * p: (n,6)-matrix with quantities (n > 1). The columns are:
  %
  %    1 f     % -  % scaled functiomal response
  %    2 L_b   % mm % length at birth
  %    3 L_p   % mm % length at puberty
  %    4 L_i   % mm % ultimate length
  %    5 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %    6 \dot{R}_i % % d^-1 % maximum reproduction rate
  %
  % * w: optional (n,5)-matrix with weight coefficient (default is ones)
  % * par0: optional (8,1 or 2)-matrix with initial estimate for par
  %
  % Ouput
  %
  % * par: (8,2)-matrix with in the first column
  %
  %    1 kap   % -    % fraction allocated to som maint + growth
  %    2 kapR  % -    % fraction of energy allocated to reprod fixed in embryo
  %                     this parameter is set in fnget_pars_s
  %    3 g     % -    % energy investment ratio
  %    4 kJ    % d^-1 % maturity maintenance rate coefficient
  %    5 kM    % d^-1 % somatic maintenance rate coefficient
  %    6 v     % mm/d % energy conductance
  %    7 Hb    % d mm^2 % scaled maturity at birth M_H^b/{J_EAm}
  %    8 Hp    % d mm^2 % scaled maturity at puberty M_H^p/{J_EAm}
  %    choice of sequence for consistency with get_par_r
  %    the second column has ones (iterate) or zeros (fix)
  %
  % * U: (n,3)-matrix with U^0 = M_E^0/\{\dot{J}_{EAm}\}, 
  %    U^b = M_E^b/\{\dot{J}_{EAm}\}, U^p = M_E^p/\{\dot{J}_{EAm}\}
  % * Ep: (n,6)-matrix as p, but now based on DEB parameters
  
  %% Remarks
  %  iget_pars_r is inverse to get_pars_s and get_pars_t for each row

  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>


  global kapR 

  ns = size(p,1); % number of data points
  
  if exist('w','var') == 0
    w = ones(ns, 5); % assign weight coefficients
  elseif isempty(w)
    w = ones(ns, 5); % assign weight coefficients    
  end

  %% data for regression input
  f = p(:,1);
  fLbw = [p(:,[1 2]), w(:,1)]; 
  fLpw = [p(:,[1 3]), w(:,2)]; 
  fLiw = [p(:,[1 4]), w(:,3)]; 
  frBw = [p(:,[1 5]), w(:,4)]; 
  fRiw = [p(:,[1 6]), w(:,5)];

  if exist('par0','var') == 1
    [nr nc] = size(par0);
    if nr ~= 8
      par = []; U = []; Ep = [];
      printf('numbers of initial parameters not equal to 8\n');
      return;
    end
    par = par0; kapR = par(2,1); par([2 4],:) = []; % remove kapR and kJ
    if nc == 1
      par = [par, ones(5,1)];
    end
  else
    [par, U0b]= get_pars_i(p(:,[1 2 4 5]),w(:,[1 3 4]));
    VHb = par(1); g = par(2); kM = par(3); v = par(4); U0 = U0b(:,1);
    kap = .8; Hb = VHb * (1 - kap); kapR = .95;
    Hp = sum(((1 - kap) * f .* fLiw(:,2) .^ 2 - fRiw(:,2) .* U0/ kapR)/kM)/ns;
    Hp = max(.01, Hp);
    par = [kap 1; g 0; kM 0; v 0; Hb 0; Hp 1];
    nrregr_options('max_step_number',20);
    [par, info] = ...
	nrregr('fnget_pars_t', par, fLbw, fLpw, fLiw, frBw, fRiw);
    %% apply log transformation to avoid negative parameters
    par(:,2) = [1 1 1 1 1 1]';
    nmregr_options('max_step_number',1000);
    nmregr_options('max_fun_evals',1000);
    ln_par = [log(par(:,1)), par(:,2)];
    [ln_par, info] = ...
	nmregr('fnget_lnpars_t', ln_par, fLbw, fLpw, fLiw, frBw, fRiw);
    par = [exp(ln_par(:,1)), ln_par(:,2)];
  end

  % final parameter estimation
  nrregr_options('max_step_number',100);
  nrregr_options('max_step_size',.01);
  [par, info] = ...
      nrregr('fnget_pars_t', par, fLbw, fLpw, fLiw, frBw, fRiw);

  if info ~= 1
    fprintf('convergence problem in finding parameters in get_pars_t\n');
  end
  
  % prepare output
  par = [par(1,:); [kapR 0]; par([2 3 3 4 5 6],:)];
  [Ep, U] = iget_pars_s (par(:,1), f); 



