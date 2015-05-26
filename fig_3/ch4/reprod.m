function [varargout] = reprod(p, varargin)
  %% [varargout] = reprod(p, vargargin)
  %% p: vector with parameters
  %% for i = 1 : many 
  %% LNi: (n,2)-matrix with length, number of eggs
  %% Vi: (n,2)-matrix with volume of eggs

  %% unpack parameters
  kap = p(1); % -, fraction allocated to somatic maint + growth
  g   = p(2); % -, energy investment ratio
  kJ  = p(3); % 1/d, maturity maintenance rate coefficient
  kM  = p(4); % 1/d, somatic maintenance rate coefficient
  v   = p(5); % mm/d, energy conductance
  Hb  = p(6); % d mm^2, scaled maturity at birth: M_H^b/{J_EAm}
  Hp  = p(7); % d mm^2, scaled maturity at puberty: M_H^p/{J_EAm}
  tR  = p(8); % d, intermoult period times kapR
  v0  = p(9); % mm/d, conversion of U0 to vol of egg
  F   = p; F(1:9) = []; % scaled func responses

  nxyw = nargin - 1; % number of data sets

  p_isr = p(1:6); p_isr(1) = p(6)/(1-p(1));
  U0 = initial_scaled_reserve(max(1,F), p_isr);
  Lm = v/ (kM * g); % maximum length

  for i = 1:2:nxyw
    LN = varargin{i}; % assign input matrix with length, number of eggs
    V = varargin{i + 1}; % assign input matrix with egg volume (dummy)

    f = F((i + 1)/ 2); % scaled functional response
    %% scaled catabolic flux: J_EC/{J_EAm}
    SC = LN(:,1) .^ 2 * (g * f/ (g + f)) .* (1 + LN(:,1)/ (g * Lm));
    %% number of eggs
    N = tR * ((1 - kap) * SC - kJ * Hp)/ U0((i + 1)/ 2);

    varargout{i} = N; % expected number of eggs
    varargout{i + 1} = ones(size(V,1),1) * v0 * U0((i + 1)/ 2); % exp egg vol
  end
