%% get_pars_s
% Obtains parameters from growth and reprod data at multiple food levels

%%
function [par, U, Ep] = get_pars_s(p, w, par0)
  %  created 2006/12/15 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [par, U, Ep] = <../get_pars_s.m *get_pars_s*>(p, w, par0)
  
  %% Description
  % Obtains parameters from growth and reprod data at multiple food levels
  % Maturity and somatic maintenance rate coefficients might differ.
  % The parameter kapR is fixed
  %
  % Input
  %
  % * p: (n,6)-matrix with quantities (n > 1). The columns are:
  %
  %    1 f     % -  % scaled functioal response
  %    2 L_b   % mm % length at birth
  %    3 L_p   % mm % length at puberty
  %    4 L_i   % mm % ultimate length
  %    5 \dot{r}_B % d^-1   % von Bertalanffy growth rate
  %    6 \dot{R}_i % % d^-1 % maximum reproduction rate
  %
  % * w: (n,5)-matrix with weight coefficient (optional, default is ones)
  % * par0: optional (8,2)-matrix with initial estimate for par
  %
  % Output
  %
  % * par: (8,2)-matrix with first column
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
  %    second column: zeros (fix) or ones (iterate)
  %
  % * U: (n,3)-matrix with U^0 = M_E^0/\{\dot{J}_{EAm}\}, 
  %    U^b = M_E^b/\{\dot{J}_{EAm}\}, U^p = M_E^p/\{\dot{J}_{EAm}\}
  % * Ep: (n,6)-matrix as p, but now based on DEB parameters
  
  %% Remarks
  % iget_pars_s is inverse to get_pars_s

  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>

  ns = size(p,1); % number of data points
  
  if exist('w','var') == 0
    w = ones(ns, 5); % assign weight coefficients
  elseif isempty(w)
    w = ones(ns, 5); % assign weight coefficients    
  end

  % data for regression input
  f  = p(:,1);
  Lb = p(:,2); fLbw = [f, Lb, w(:,1)]; 
  Lp = p(:,3); fLpw = [f, Lp, w(:,2)]; 
  Li = p(:,4); fLiw = [f, Li, w(:,3)]; 
  rB = p(:,5); frBw = [f, rB, w(:,4)]; 
  Ri = p(:,6); fRiw = [f, Ri, w(:,5)];

  if exist('par0','var') == 1
    par = par0(:); par = [par(1:8), [1;0;1;1;1;1;1;1]];
  else % obtain initial estimate
    [par U0b]= get_pars_i(p(:,[1 2 4 5]),w(:,[1 3 4]));
    VHb = par(1); g = par(2); kM = par(3); v = par(4); U0 = U0b(:,1);
    kJ = kM; kap = .8; Hb = VHb * (1 - kap); kapR = .95;
    Hp = max(.1, sum((1 - kap) * f .* Li .^ 2 - Ri .* U0/ kapR)/ns);
    par = [kap 1; kapR 0; g 0; kJ 0; kM 0; v 0; Hb 0; Hp 1];
    par = get_pars_t(p,w,par); % this assumes that kJ = kM
    par(:,2) = [1 0 1 1 1 1 1 1]';
    % first use log-transform to avoid negative par-values
    nmregr_options('max_step_number',1000);
    ln_par = [log(par(:,1)), par(:,2)];
    [ln_par, info] = ...
      nmregr('fnget_lnpars_s', ln_par, fLbw, fLpw, fLiw, frBw, fRiw);
    par(:,1) = exp(ln_par(:,1));
    if 0
      ln_par = [log(par(:,1)), par(:,2)];
      nrregr_options('max_step_number',10);
      [ln_par, info] = ...
      nrregr('fnget_lnpars_s', ln_par, fLbw, fLpw, fLiw, frBw, fRiw);
      par(:,1) = exp(ln_par(:,1));
    end
  end
  
  %% final parameter estimation
  nrregr_options('max_step_size',10);
  nrregr_options('max_step_number',20);
  nrregr_options('max_norm',1e-6);
  [par, info] = ...
        nrregr('fnget_pars_s', par, fLbw, fLpw, fLiw, frBw, fRiw);
  
  if info ~= 1
    fprintf('convergence problem in finding parameters\n');
  end

  % prepare output
  [Ep, U] = iget_pars_s(par(:,1), f);
