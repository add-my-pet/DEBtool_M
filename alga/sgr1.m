%% sgr1
% specific growth rate for V1 morph with 1 reserve, allowing for shrinking

%%
function [r, jEM, jVM, jER, info] = ...
      sgr1 (m_E, k_E, j_EM, y_EV, j_VM, a, r0)
  %  created: 2007/09/26 by Bas Kooijman, modified 2009/09/21
  
  %% Syntax
  % [r, jEM, jVM, jER, info] = <../sgr1.m *sgr1*> (m_E, k_E, j_EM, y_EV, j_VM, a, r0) 

  %% Description
  % Specific growth rate for V1 morph with 1 reserve, allowing for shrinking.
  %
  % Input:
  %
  % * m_E:  scalar with mol/mol, reserve density
  % * k_E:  scalar with 1/time, reserve turnover rate
  % * j_EM: scalar with mol/time.mol, spec maintenance flux if from reserve
  % * y_EV: scalar with mol/mol, yield of reserve on structure
  % * j_VM: optional scalar with mol/time.mol, spec maintenance flux;
  %        if from structure (default j_EM/ y_EV)
  % * a: optional scalar with preference (default 0)
  % * r0: optional scalar with initial estimate for r (default 0)
  %
  % Output:
  %
  % * r:    scalar with 1/time, spec growth rate
  % * jEM: scalar with mol/time.mol, spec maintenance flux for reserve
  % * jVM: scalar with mol/time.mol, spec maintenance flux for structure
  % * jER: scalar with mol/time.mol, rejected flux of reserve
  % * info: scalar with numerical failure (0) or success (1)
  
  %% Remarks
  % cf <sgr2.html *sgr2*>, <sgr3.html *sgr3*> and <sgr4.html *sgr4*> for specific growth rate with 2, 3 and 4 reserves
  
  %% Example of use
  % see <../mydata_sgr.m *mydata_sgr.m*>

  jER = 0; % included for consistency with sgr2
  
  if exist('j_VM','var') == 0
    j_VM = j_EM/ y_EV; % minimum value
  end
  if isempty(j_VM)
    j_VM = j_EM/ y_EV; % minimum value
  end
  if exist('a','var') == 0
    a = 0; % switch model: absolute priority of reserve for maintenance
  end
  if exist('r0','var') == 0
    r0 = 0; % only relevant for preference model
  end

  if a == 0 % switch model
    if m_E * k_E > j_EM % growth conditions
      r = (m_E * k_E - j_EM)/ (m_E + y_EV);
    else % shrinking conditions
      r = (m_E * k_E - j_EM)/ (m_E + j_EM/ j_VM);
    end
    j_EC = m_E * (k_E - r);
    jEM = min(j_EM, j_EC);
    jVM = j_VM * (1 - jEM/ j_EM);
    info = 1;
  else % preference model
    i = 1; info = 1;
    f = 1; % initiate norm; make sure that iteration procedure is started
    while (f^2 > 1e-15) & (i < 20) % test norm
      j_EC = m_E * (k_E - r0); % catabolic rate
      C = - j_EC * (j_EC + y_EV * j_VM);
      B = C + ((1 - a) * j_EC + y_EV * j_VM) * j_EM;
      A = a * j_EM^2;
      jVM = j_VM * 2 * A/ (2 * A + sqrt(B^2 - 4 * A * C) - B);
      r = (m_E * k_E - j_EM - (y_EV - j_EM/ j_VM) * jVM)/ (m_E + y_EV);
      f = r - r0; r0 = r; i = i + 1;
    end
    jEM = j_EM * (1 - jVM/ j_VM);
    if i == 20
      info = 0;  % no convergence
      fprintf('no convergence of sgr1 in 20 steps\n');
    end
  end
