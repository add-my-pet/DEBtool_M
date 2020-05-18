%% f_ris0
% Gets scaled functional response at with the specific population growth rate is zero

%%
function [f info] = f_ris0 (p, f_0)
  % created 2009/09/18 by Bas Kooijman
  
  %% Syntax
  % [f info] = <../f_ris0.m *f_ris0*> (p, f_0)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the standard DEB model equals zero, 
  %   by solving the characteristic equation. Aging is the only cause of death. 
  %
  % Input
  %
  % * p: 11-vector with parameters: kap kapR g kJ kM LT v UHb UHp ha sG
  % * f_0: optional scalar with func response for which maturation ceases at puberty (see <get_ep_min.html *get_ep_min*>)
  %
  % Output
  %
  % * f: scaled func response at which r = 0 for reproducing isomorphs
  % * info: scalar with indicator for failure (0) or success (1)
  
  %% Remarks
  % Shell around <sgr_iso.html *sgr_iso*>, using a bisection method.

  if ~exist('f_0', 'var')
    % unpack parameters
    kap = p(1); % kapR = p(2); 
    g   = p(3); kJ  = p(4); kM   = p(5); LT  = p(6);  
    v   = p(7); UHb  = p(8); UHp = p(9);
    %ha = p(10); sG = p(11);
  
    k = kJ/ kM;
    Lm = v/ kM/ g;
    lT = LT/ Lm;
    VHp = UHp/ (1 - kap);
    vHp = VHp * g^2 * kM^3/ v^2;
    
    f_0 = get_ep_min([k; lT; vHp]);
  end

  % initialize range for f
  f_1 = 1;         % upper boundary (lower boundary is f_0)
  norm = 1; i = 0; % initialize norm and counter

  while i < 100 && norm^2 > 1e-16 % bisection method
    i = i + 1;
    f = (f_0 + f_1)/ 2;
    norm = sgr_iso(p, f);
    if norm > 0
        f_1 = f;
    else
        f_0 = f;
    end
  end

  if i == 100
    info = 0;
    fprintf('f_ris0 warning: no convergence for f in 100 steps\n')
  else
    info = 1;
    %fprintf(['f_iso warning: successful convergence for f in ', num2str(i), ' steps\n'])
  end
