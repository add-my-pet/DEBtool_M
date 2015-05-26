%% get_t50_s
% Gets scaled median age at death for short growth periods

%%
function [t50 info] = get_t50_s(p, f, t500)
  % created 2010/03/01 by Bas Kooijman, modified 2015/01/18
    
  %% Syntax
  % [t50 info] = <../get_t50_s.m *get_t50_s*> (p, f, t500)
  
  %% Description
  % Calculates scaled median life span at constant f for short growth periods, relative to life span
  %
  % Input
  %
  % * p: 4-vector with parameters: g lT ha SG
  % * f: optional scalar with scaled functional response (default: f = 1)
  % * t500: optional scalar with starting value for t50
  % 
  % Output
  %
  % * t50: scalar with scaled median life span
  % * info: scalar with indicator for success (1) or failure (0)
  
  %% Remarks
  % Theory: see comments on DEB3 Section 6.1.1. 

  %% Example of use
  %  get_t50_s([.5, .1, .1, .01])
   
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  %% unpack pars
  g   = p(1); % energy investment ratio
  lT  = p(2); % scaled heating length {p_T}/[p_M]Lm
  ha  = p(3); % h_a/ k_M^2, scaled Weibull aging acceleration
  sG  = p(4); % Gompertz stress coefficient

  if abs(sG) < 1e-10
    sG = 1e-10;
  end
  
  li = f - lT;
  hW3 = ha * f * g/ 6/ li; hW = hW3^(1/3); % scaled Weibull aging rate
  hG = sG * f * g * li^2;  hG3 = hG^3;     % scaled Gompertz aging rate
  tG = hG/ hW; tG3 = hG3/ hW3;             % scaled Gompertz aging rate

  if exist('t500','var') == 0
    t500 = .889/ hW;
  elseif isempty(f)
    t500 = .889/ hW;
  end

  options = optimset('Display','off');
  [t50 flag info] = fzero(@fnget_t50_s, t500 * hW, options, tG);
  t50 = t50/ hW; % S(t50)=.5
  
% subfunctions

function S = fnget_t50_s(t, tG)
% modified 2010/02/25
% called by get_tm_s for life span at short growth periods
% integrate ageing surv prob over scaled age
% t: age * hW 
% S: ageing survival prob

hGt = tG * t; % age * hG
S = exp((1 + hGt + hGt.^2/2  - exp(hGt)) * 6/ tG^3) - .5; 
