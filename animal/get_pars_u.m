%% get_pars_u
% Gets primary parameters from compound parameters

%%
function [par, aLM] = get_pars_u(q, p)
  %  created 2007/01/27 by Bas Kooyman, modified 2007/08/07
  
  %% Syntax
  % [par, aLM] = <../get_pars_u.m *get_pars_u*>(q, p)
  
  %% Description
  % Gets primary parameters from compound parameters
  % Surface linked somatic maintenance costs are not included
  %
  % Input
  %
  % * q: 4-vector with
  %
  %    1 JXAm  % mmol/d.mm^2 % {J_{XAm}} max spec food uptake rate
  %    2 K     % M    % half saturation coefficient
  %    3 ME0   % mol  % M_E^0 mass at time 0 (all mass consists of reserve)
  %    4 MWb   % mol  % M_W^b mass at birth (reserve plus structure)
  %    this data must be supplied to convert compound to primary pars
  %    we here assume that ME0 and MWb are given at abundant food
  %    (reserve density at birth equals that of the mother at egg production)
  %
  % * p: 8-vector with
  %
  %    1 kap   % -      % fraction allocated to som maint + growth
  %    2 kapR  % -      % fraction of energy to reprod that is fixed in embryo
  %    3 g     % -      % energy investment ratio
  %    4 kJ    % d^-1   % maturity maintenance rate coefficient
  %    5 kM    % d^-1   % somatic maintenance rate coefficient
  %    6 v     % mm/d   % energy conductance
  %    7 Hb    % d.mm^2 % scaled maturity at birth M_H^b/{J_EAm}
  %    8 Hp    % d.mm^2 % scaled maturity at puberty M_H^p/{J_EAm}
  %    this vector is output of get_pars_s
  %
  % Output
  %
  % * par: 12-vector with primary pars of standard DEB model
  %
  %    1  JEAm % mmol/d.mm^2 % {J_{EAm}} max spec assimilation rate
  %    2  b    % m^3/ d.mm^2 % {b} spec searching rate
  %    3  yEX  % mol/mol     % y_EX yield of reserve on food
  %    4  yVE  % mol/mol     % y_VE yield of structure on reserve
  %    5  v    % mm/d        % energy conductance
  %    6  JEM  % mol/d.mm^3  % [J_{EM}] spec somatic maintenance costs
  %    7  kJ   % 1/d         % k_J maturity maintenance rate coefficient
  %    8  kap  % -           % \kappa fraction to som maint + growth
  %    9  kapR % -           % \kappa_R fraction fixed in embryo 
  %   10  MHb  % mol         % M_H^b maturity at birth
  %   11  MHp  % mol         % M_H^p maturity at puberty
  %   12  MV   % mol/ mm^3   % [M_V] mass-volume converter for structure
  %
  % * aLM: (4,4)-matrix with 
  %
  %    age a, length L, mass of reserve M_E, mass of structure M_V
  %    at age 0, at birth, at puberty, at infinity
  
  %% Remarks
  % Notice that all quantities that involve length depend on the shape unless if chosen for volumetric lengths

  %% Example of use
  % See <../mydata_get_pars.m *mydata_get_pars*>

  % unpack q
  JXAm = q(1); K   = q(2); ME0 = q(3); MWb = q(4);
  % unpack p
  kap = p(1); kapR = p(2); g   = p(3); kJ  = p(4);
  kM  = p(5); v    = p(6); Hb  = p(7); Hp  = p(8);

  Lm = v/ (kM * g); % max length for transfer to dget_aul
  f = 1; % scaled functional response for transfer to dget_aul_p

  % get initial scaled reserve, assuming abundant food (f = 1)
  [U0, Lb, info] = initial_scaled_reserve(f, [Hb/(1-kap); g; kJ; kM; v]);
  if info ~= 1
    fprintf('problems in finding initial scaled reserve\n');
  end

  % get states at birth: age, scaled reserve, length
  ab = get_tb([g; kJ/ kM], f, Lb/ Lm)/ kM;
  Ub = f * Lb^3/ v; 
 
  b    = JXAm/ K;
  JEAm = ME0/ U0;
  yEX  = JEAm/ JXAm;
  MHb  = JEAm * Hb;
  MHp  = JEAm * Hp;
  MEb  = JEAm * Ub;
  MVb  = MWb - MEb;
  MV   = MVb/ Lb^3;
  yVE  = v * MV/ (kap * JEAm * g);
  JEM  = kM * MV/ yVE;
  
  % pack parameters of the standard model
  par = [JEAm; b; yEX; yVE; v; JEM; kJ; kap; kapR; MHb; MHp; MV];

  % get states at puberty: age, scaled reserve, length
  [H, aUL] = ode45(@dget_aul_p, [Hb;Hp], [ab, Ub, Lb], [], kap, v, kJ, g, Lm, f);
  ap = aUL(end,1); Up = aUL(end,2); Lp = aUL(end,3);
  MEp = JEAm * Up; MVp = MV * Lp^3;

  % states at infinite age
  MVm = MV * Lm^3; MEm = MEp * (Lm/ Lp)^3;

  % pack states 
  aLM = [ 0,  0, ME0,   0;
	 ab, Lb, MEb, MVb;
	 ap, Lp, MEp, MVp;
	Inf, Lm, MEm, MVm];