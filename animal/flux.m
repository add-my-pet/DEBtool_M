%% flux
% Gets mass fluxes gives states and parameters

%%
function JMO = flux(XEV, nMO, p)
  % created by Bas Kooijman  at 2007/01/28

  %% Syntax
  % JMO = <../flux.m *flux*> (XEV, nMO, p)
  
  %% Descrption
  % Gets mass fluxes gives states and parameters
  %
  % Input
  %
  % * XEV: (nf,3 or 4)-matrix with cols:
  %
  %   food density X, masses of reserve M_E, structure M_V, maturity M_H
  %
  % * nMO: (4,8)-matrix with chemical indices
  %
  %   rows: chemical elements C, H, O, N
  %   cols: CO2, H2O, O2, N-waste, food, structure, reserve, faeces
  %
  % * p: 12 or 13 -vector with parameters of standard DEB model
  %
  %    {J_EAm}, {F_m}, y_EX, y_VE, v, [J_EM], k_J, kap, kap_R, M_Hb, M_Hp, [M_V] with {J_ET} = 0;
  %    or
  %    {J_EAm}, {F_m}, y_EX, y_VE, v, [J_EM], {J_ET}, k_J, kap, kap_R, M_Hb, M_Hp, [M_V] with {J_ET} = 0;
  %
  % Output
  %
  % * JMO: (nf,8)-matrix with fluxes of compounds
  %
  %   cols: CO2, H2O, O2, N-waste, food, structure, reserve, faeces

  %% Example of use
  % See <../mydata_flux.m *mydata_flux*>

  % unpack p
  if length(p) == 12
    JEAm = p(1); b = p(2); yEX = p(3); yVE = p(4); v = p(5);
    JEM = p(6); kJ = p(7); kap = p(8); kapR = p(9); MHb = p(10);
    MHp = p(11); MV = p(12); JET = 0;
  elseif length(p) == 13
    JEAm = p(1); b = p(2); yEX = p(3); yVE = p(4); v = p(5);
    JEM = p(6); JET = p(7); kJ = p(8); kap = p(9); kapR = p(10);
    MHb = p(11); MHp = p(12); MV = p(13);
  else
    fprintf('number of DEB parameters does not equal 12 or 13\n');
    return
  end
  
  % unpack XEV
  X = XEV(:,1); M_E = XEV(:,2); M_V = XEV(:,3);
  kM = yVE * JEM/ MV; % somatic maintenance rate coefficient
  if size(XEV,2) == 4
    M_H = XEV(:,4);
  else
    M_H = M_V * (1 - kap)/ (kap * yVE);
    if kJ ~= kM
      fprintf('Warning: k_J not equal to k_M while maturity is not given\n');
      fprintf('Maturity maintenance costs might not be correct\n');
    end
  end

  % unpack nMO
  n_M = nMO(:, 1:4);        % chemical indices for mineral compounds
  n_O = nMO(:, 4 + (1:4));  % chemical indices for organic compounds

  % convert
  JXAm = JEAm/ yEX; % max spec food uptake rate
  K = JXAm/ b; % half saturation coefficient
  f = X ./ (X + K); % scaled functional response
  yPX = 1 - yEX; % yield of faeces on food
  
  % if CO2 is produced during assimilation, yPX is a free parameter! 
  L = (M_V/ MV) .^(1/3); % structural length
  MEm = JEAm/ v; % [M_Em] = {J_EAm}/v  max reserve density (mass/ vol)
  mEm = MEm/ MV; % max reserve density (mass/ mass)
  ee = (M_E ./ M_V)/ mEm; % scaled reserve density, dim-less
  g = v * MV/ (kap * JEAm * yVE); % energy inverstmet ratio
  Lm = v/ (kM * g); % maximum length
  Lh = JET/ JEM; % heating length

  % organic fluxes
  J_EA = JEAm * (M_H > MHb) .* f .* L .^ 2; % assimilation
  J_XA = -J_EA/ yEX; % food uptake
  J_PA = - yPX * J_XA; % faeces production
  J_EC = JEAm * L .^2 .* (g * ee ./ (g + ee)) .* (1 + (Lh + L) ./ (g * Lm));
  J_E  = J_EA - J_EC;
  J_EJ = kJ * M_H; % maturity maintenance
  J_ER = (1 - kap) * J_EC - J_EJ; % maturation/reproduction
  J_EM = JEM * L .^ 3; % volume-linked somatic maintenance
  J_ET = JET * L .^ 2; % surface-linked somatic maintenance
  J_EG = kap * J_EC - J_EM - J_ET; % growth
  J_V = yVE * J_EG;
  J_O = [J_XA, J_V, J_E + J_ER * kapR .* (M_H > MHp), J_PA];

  % mineral fluxes: J_M * n_M' + J_O * n_O'= 0
  J_M = - J_O * n_O'/n_M';
  
  % pack result
  JMO = [J_M, J_O];
