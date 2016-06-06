%% gr_iso_21
% growth rate d/dt L for isomorph-embryo with 2 reserves

%%
function [v_B_out, j_E1_M, j_E2_M, j_E1C, j_E2C, info] = ...
    gr_iso_21 (L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1, v_B_0)
  % created: 2011/08/05 by Bas Kooijman

  %% Syntax
  % [v_B_out, j_E1_M, j_E2_M, j_E1P, j_E2P, info] = <../gr_iso_21.m *gr_iso_21*> (L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1, v_B_0)

  %% Description    
  % growth rate v_B = d/dt L = r * L/ 3 > 0 for isomorph-embryo with 2 reserves
  %   see sgr_iso_21 for specific growth rate r (that allows shrinking)
  %
  % Input:
  %
  % * L:            cm,        scalar with structural length
  % * m_E1, m_E2:   mol/mol,   scalars with reserve density
  % * j_E1M, j_E2M: mol/d.mol, scalars with spec maintenance flux if from that reserve
  % * y_VE1, y_VE2: mol/mol,   scalars with yield of structure on reserve
  % * v:            cm/d,      scalar with energy conductance
  % * kap:          -,         scalar with allowcation fraction to soma
  % * rho1:         -,         scalar with preference (default 0)
  %
  % Ouptut:
  %
  % * v_B_0:        cm/d,      optional scalar with initial estimate for v_B 
  %
  %                            if empty or undefined v/3, else previous result is used
  %
  % * v_B_out:      cm/d,      scalar with growth rate
  % * j_E1_M, j_E2_M: mol/d.mol, scalars with spec som maintenance flux
  % * j_E1C, j_E2C: mol/d.mol, scalars with rejected flux of reserve fro growth SUs
  % * info:         -,         scalar with numerical failure (0) or success (1)

  persistent v_B               % 1/d, growth rate for continuation

  if exist('v_B_0','var') == 1 % use initial guess if specified
    v_B = v_B_0;
  end
  if isempty(v_B)              % if first call is without v_B_0
    v_B = v/ 3 - 1e-4;
  end                          % otherwise: continuation

  i = 0; n = 10; info = 1;     % initiate iteration pars
  H = 1; % initiate norm; make sure that iteration procedure is started
  
  while (abs(H) > 1e-8) && (i < n) % test norm
    r = 3 * v_B/ L;                                             % 1/d, specific growth rate
    j_E1C = m_E1 * (v/ L - r); j_E2C = m_E2 * (v/ L - r);       % mol/d.mol, spec mobilisation rates
    A = rho1 * j_E1C * j_E2M^2/ j_E1M; C = - kap * j_E2C * (j_E1C + j_E2C);
    B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2M; sq = sqrt(B * B - 4 * A * C);
    j_E1_M = min(kap * j_E1C, 2 * A * j_E1M/ (2 * A + sq - B)); % mol/d.mol, spec som maint rate 1
    j_E2_M = min(kap * j_E2C, j_E2M * (1 - j_E1_M/ j_E1M));     % mol/d.mol, spec som maint rate 2
    v_G1 = max(1e-10, y_VE1 * (kap * m_E1 * (v/ 3 - v_B) - j_E1_M * L/ 3)); % cm/d, growth rate 1
    v_G2 = max(1e-10, y_VE2 * (kap * m_E2 * (v/ 3 - v_B) - j_E2_M * L/ 3)); % cm/d, growth rate 2
    H = v_B - 1/ (1/ v_G1 + 1/ v_G2 - 1/ (v_G1 + v_G2));        % cm/d, norm function
    
    dA = -rho1 * m_E1 * j_E2M^2/ j_E1M; 
    dC = kap * m_E2 * (j_E1C + j_E2C) + kap * j_E2C * (m_E1 + m_E2);
    dB = dC - (m_E1 + (1 - rho1) * m_E2) * j_E2M;
    dj_E1_M = j_E1_M * (dA/ A - (2 * dA + (B * dB - 2 * dA * C - 2 * A * dC)/ sq - dB)/ (2 * A + sq - B));
    dj_E2_M = - dj_E1_M * j_E2M/ j_E1M;
    th_G1 = - y_VE1 * (kap * m_E1 + dj_E1_M); 
    th_G2 = - y_VE2 * (kap * m_E2 + dj_E2_M);
    dH = th_G1/ v_G1^2 + th_G2/ v_G2^2 - (th_G1 + th_G2)/ (v_G1 + v_G2)^2; 
    dH = 1 - dH * (v_B - H)^2;                                  % -, d/dv_H H
    
    v_B = min(v/ 3 - 1e-10, max(1e-10, v_B - H/ dH));           % new step in NR-procedure
    i = i + 1;                                                  % increase step counter
  end

  if i == n || isnan(v_B) || v_B < 0 || v_B > v/ 3
    info = 0;                                                   % no convergence
    fprintf(['warning in gr_iso_21: no convergence in ', num2str(i), ' steps\n']);
    v_B = v/ 3 - 1e-4;                                          % cm/d, change in structural length
    r = 3 * v_B/ L;                                             % 1/d, specific growth rate
    j_E1C = m_E1 * (v/ L - r); j_E2C = m_E2 * (v/ L - r);       % mol/d.mol, spec mobilisation rates
    A = rho1 * j_E1C * j_E2M^2/ j_E1M; C = - kap * j_E2C * (j_E1C + j_E2C);
    B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2M; sq = sqrt(B * B - 4 * A * C);
    j_E1_M = min(kap * j_E1C, 2 * A * j_E1M/ (2 * A + sq - B)); % mol/d.mol, spec som maint rate 1
    j_E2_M = min(kap * j_E2C, j_E2M * (1 - j_E1_M/ j_E1M));     % mol/d.mol, spec som maint rate 2
  %else
  %  fprintf(['gr_iso_21: successful convergence in ', num2str(i), ' steps\n']);      
  end

  v_B_out = v_B; % copy result to output
 