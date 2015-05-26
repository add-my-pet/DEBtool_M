%% get_evh
% mass of reserve and structure and maturity as function of time

%%
function EVH = get_evh(a,p,X)
  % created by Bas Kooijman 2007/01/28, modified 2011/07/03
  
  %% Syntax
  % EVH = <..get_evh.m *get_evh*> (a,p,X)
  
  %% Description
  % Obtains mass of reserve and structure and maturity 
  %    (quantified as cumulated investedment into maturation in the form of reserve), 
  % given constant food density, for different ages. 
  %
  % Input
  %
  % * a: (n,1)-matrix with ages
  % * p: 12 or 13 -vector with parameters of standard DEB model:
  %      {J_EAm}, {F_m}, y_EX, y_VE, v, [J_EM], k_J, kap, kap_R, M_H^b, M_H^p, [M_V] with {J_ET} = 0
  %
  %    or
  %      {J_EAm}, {F_m}, y_EX, y_VE, v, [J_EM], {J_ET}, k_J, kap, kap_R, M_H^b, M_H^p, [M_V]
  %
  % * X: scalar with food density
  %  
  % Output
  %
  % * EVH: (n,3)-matrix with
  %   masses of reserve M_E, structure M_V, maturity M_H
  
  %% Remarks
  % The theory behind get_lb, get_tb and get_ue0 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b>.
  
  %% Example of use
  % See <../mydata_flux.m *mydata_flux*>
  
  % unpack p
  if length(p) == 12
    JEAm = p(1); Fm = p(2); yEX = p(3); yVE = p(4); v = p(5);
    JEM = p(6); kJ = p(7); kap = p(8); kapR = p(9); MHb = p(10);
    MHp = p(11); MV = p(12); JET = 0;
  elseif length(p) == 13
    JEAm = p(1); Fm = p(2); yEX = p(3); yVE = p(4); v = p(5);
    JEM = p(6); JET = p(7); kJ = p(8); kap = p(9); kapR = p(10);
    MHb = p(11); MHp = p(12); MV = p(13);
  else
    fprintf('number of DEB parameters does not equal 12 or 13\n');
    return
  end

  kM = yVE * JEM/ MV; % 1/d, somatic maintenance rate coefficient
  g = v * MV/ (kap * JEAm * yVE); % -, energy investment ratio
  VHb = MHb/ JEAm/ (1 - kap);     % d.cm^2, scaled maturity at birth
  JXAm = JEAm/ yEX;   % mol/d.cm^2, max spec food uptake rate
  K = JXAm/ Fm;       % M, half saturation coefficient
  f = X/ (X + K);     % -, scaled functional response
  ME0 = JEAm * initial_scaled_reserve(f, [VHb; g; kJ; kM; v]); % mol

  MEm = JEAm/ v;      % mol/cm^3, [M_Em] = {J_EAm}/v  max reserve density (mass/ vol)
  mEm = MEm/ MV;      % mol/mol, max reserve density (mass/ mass)
  Lm = v/ (kM * g);   % cm, maximum length
  LT = JET/ JEM;      % cm, heating length

  a = [-1e-10; a];    % d, prepend zero
  [a EVH] = ode45(@dget_evh, a, [ME0; 1e-6; 1e-6], [], f, Lm, LT, mEm, g, v, JEAm, yVE, JEM, JET, kJ, kap, MHb, MHp, MV);
  EVH(1,:) = [];      % remove first row
