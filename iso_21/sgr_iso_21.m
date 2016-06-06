%% sgr_iso_21
% specific growth rate for isomorph with 2 reserves

%%
function [r_out, j_E1_S, j_E2_S, j_E1C, j_E2C, info] = ...
    sgr_iso_21 (m_E1, m_E2, j_E1S, j_E2S, y_VE1, y_VE2, mu_EV, k_E, kap, rho1, r0)
  % created: 2011/05/03 by Bas Kooijman, modified 2011/08/05

  %% Syntax
  % [r_out, j_E1_S, j_E2_S, j_E1C, j_E2C, info] = <../sgr_iso_21_var.m *sgr_iso_21*> (m_E1, m_E2, j_E1S, j_E2S, y_VE1, y_VE2, mu_EV, k_E, kap, rho1, r0)

  %% Description
  % specific growth rate for isomorph with 2 reserves, allowing for shrinking
  %
  % Input:
  %
  % * m_E1, m_E2:   mol/mol,   scalars with reserve density
  % * j_E1S, j_E2S: mol/d.mol, scalars with spec maintenance flux if from reserve
  % * y_VE1, y_VE2: mol/mol,   scalars with yield of structure on reserve
  % * mu_EV:        -,         scalar with mu_E1/ mu_V (mu_E1 j_E1S = mu_E2 j_E2S)
  % * k_E:  1/d,               scalar with reserve turnover rate v/ L
  % * kap: -,                  scalar with allocation fraction to soma
  % * rho1: -,                 scalar with preference (default 0)
  % * r0: 1/d,                 optional scalar with initial estimate for r 
  %
  %                            if empty or undefined 0, else previous result is used
  %
  % Output
  %
  % * r: 1/d,                  scalar with spec growth rate
  % * j_E1_S, j_E2_S: mol/d.mol, scalars with  spec som maintenance flux
  % * j_E1C, j_E2C: mol/d.mol, scalars with rejected flux of reserve from growth SUs
  % * info: -,                 scalar with numerical failure (0) or success (1)

  %% Remarks
  % see <gr_iso_21.html *gr_iso_21*> for growth rate d/dt L (for embryo case);
  % see <sgr_iso_21_var.html *sgr_iso_21_var*> for variable stoichiometry

  persistent r % 1/d, specific growth rate
  
  if exist('r0','var') == 1 % use initial guess if specified
    r = r0;
  end
  if isempty(r)             % if first call is without r_0
    r = 0;
  end                       % otherwise: continuation
  
  i = 0; n = 1e3; info = 1;  % initiate iteration pars
  H = 1; % initiate norm; make sure that iteration procedure is started
    
  while (abs(H) > 1e-11) && (i < n) % test norm
    j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r);                          % mol/d.mol, mobilisation flux
    A = rho1 * j_E1C * j_E2S^2/ j_E1S; C = - kap * j_E2C * (j_E1C + j_E2C);
    B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2S; sq = sqrt(B * B - 4 * A * C); D = 2 * A + sq - B;
    if D == 0
      j_E1_S = kap * j_E1C;                                                      % mol/d.mol, spec som maint 1      
    else
      j_E1_S = min(kap * j_E1C, 2 * A * j_E1S/ D);                               % mol/d.mol, spec som maint 1
    end
    j_E2_S = min(kap * j_E2C, j_E2S * (1 - j_E1_S/ j_E1S));                      % mol/d.mol, spec som maint 1
    j_E1G = kap * j_E1C - j_E1_S; j_E2G = kap * j_E2C - j_E2_S;                  % mol/d.mol, spec growth flux to growth
    j_V_S = j_E1S * (1 - j_E1_S/ j_E1S - j_E2_S/ j_E2S) * mu_EV;                 % mol/d.mol, spec shrinking flux
    j_V1G = y_VE1 * j_E1G; j_V2G = y_VE2 * j_E2G;                                % mol.d.mol, spec growth flux
    if j_V1G == 0 || j_V2G == 0     % shrinking
      r = - j_V_S;
      H = r + j_V_S;
    else                            % growing
      H = r + j_V_S - 1/ (1/ j_V1G + 1/ j_V2G - 1/ (j_V1G + j_V2G));             % 1/d, norm function
    
      dA = -rho1 * m_E1 * j_E2S^2/ j_E1S; 
      dC = kap * m_E2 * (j_E1C + j_E2C) + kap * j_E2C * (m_E1 + m_E2);
      dB = dC - (m_E1 + (1 - rho1) * m_E2) * j_E2S;
      if j_E1_S == kap * j_E1C
        dj_E1_S = - kap * m_E1;
      else
        dj_E1_S = j_E1_S * (dA/ A - (2 * dA + (B * dB - 2 * dA * C - 2 * A * dC)/ sq - dB)/ D);
      end
      if j_E2_S == kap * j_E2C
        dj_E2_S = - kap * m_E2;
      else
        dj_E2_S = - dj_E1_S * j_E2S/ j_E1S;
      end
      dj_E1G = - kap * m_E1 - dj_E1_S; dj_E2G = - kap * m_E2 - dj_E2_S;
      dj_V_S = (j_V_S > 0) * j_E1S * (dj_E1_S/ j_E1S + dj_E2_S/ j_E2S) * mu_EV;
      dj_V1G = y_VE1 * dj_E1G; dj_V2G = y_VE2 * dj_E2G;
      dH = dj_V1G/ j_V1G^2 + dj_V2G/ j_V2G^2 - (dj_V1G + dj_V2G)/ (j_V1G + j_V2G)^2; 
      dH = 1 - dj_V_S - dH * (r + j_V_S - H)^2;                                  % -, d/dr H
      r = r - H/ dH;                                                             % new step in NR-procedure
    end
    
    i = i + 1;                                                                   % increase step counter   
  end
 
  if i == n || isnan(r) || ~isreal(r)
    info = 0;  % no convergence
  %  fprintf(['warning in sgr_iso_21: no convergence in ', num2str(i), ' steps', '; r = ', num2str(r), '\n']);
    r = 1e-20;                                                                   % 1/d, set r for next call to sgr_iso_21
    j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r);                          % mol/d.mol, mobilisation flux
    A = rho1 * j_E1C * j_E2S^2/ j_E1S; C = - kap * j_E2C * (j_E1C + j_E2C);
    B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2S; sq = sqrt(B * B - 4 * A * C);
    j_E1_S = min(kap * j_E1C, 2 * A * j_E1S/ (2 * A + sq - B));                  % mol/d.mol, spec som maint 1
    j_E2_S = min(kap * j_E2C, j_E2S * (1 - j_E1_S/ j_E1S));                      % mol/d.mol, spec som maint 1

 % else
 %   fprintf(['sgr_iso_21: successful convergence in ', num2str(i), ' steps', '; r = ', num2str(r), '\n']);      
  end

  r_out = r; % copy result to output
