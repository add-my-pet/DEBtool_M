%% get_tj_hax
% Gets scaled age at emergence for hax model

%%
function [tj, te, tp, tb, lj, le, lp, lb, li, rj, rB, uEe, info] = get_tj_hax(p, f)
  % created at 2017/08/01, 2022/01/27 by Bas Kooijman, 
  
  %% Syntax
  % [tj, te, tp, tb, lj, le, lp, lb, li, rj, rB, uEe, info] = <../get_tj_hax.m *get_tj_hax*> (p, f)
  
  %% Description
  % Obtains scaled ages at pupation, emergence, puberty, birth and the scaled lengths at these ages for hax model of e.g. Chaoborus;
  % The hax model is the same as the hep model, but has a pupa stage like the hex model.
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between b and p; isomorphy between p and j ( = pupation, e.g. transition from larva to pupa). 
  % Notice j-e-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 8 with parameters: g, k, v_H^b, v_H^p, v_R^j, v_H^e, kap, kapV   
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tj: scaled age at pupation \tau_j = a_j k_M
  % * te: scaled age at emergence \tau_e = a_e k_M
  % * tp: scaled age at puberty \tau_p = a_p k_M
  % * tb: scaled age at birth \tau_b = a_b k_M
  % * lj: scaled length at pupation lj = Lj/ Lm, Lm = v/ (k_M * g)
  % * le: scaled length at emergence le = Le/ Lm
  % * lp: scaled length at puberty = end of acceleration
  % * lb: scaled length at birth = start of acceleration
  % * li: ultimate scaled length li = Li/ Lm
  % * rhoj: scaled exponential growth rate between b and p: \rho_j = r_j/ k_M
  % * rhoB: scaled von Bertalanffy growth rate between p  between j: \rho_B = r_B/ k_M
  % * uEe: scaled reserve at emergence: u_E^e = U_E^e g^2 kM^3/ v^2; U^e = E^e/ {p_Am}
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  Contrary to the abj-model, p (puberty) does not coincide with birth (b), no acceleration as adult (but still larva)
  %  See <get_tj_hex.html get_tj_hex*> in case of holo metabolic insects;
  %  See <get_tj_hep.html get_tj_hex*> in case of ephemeropterans;
  
  %% Example of use
  %  get_tj_hax([.5, .1, .01, .05, .2])
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am} start acceleration
  vHp = p(4); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am} end acceleration
  vRj = p(5); % (kap/(1 - kap)) [E_R^j]/ [E_G] scaled reprod buffer density at pupation
  vHe = p(6); % v_H^e = U_H^e g^2 kM^3/ (1 - kap) v^2; U_H^e = E_H^e/ {p_Am} at emergence
  kap = p(7); % -, allocation fraction to soma of pupa
  kapV = p(8);% -, conversion efficiency from larval reserve to larval structure, back to imago reserve

  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  % from zero till puberty
  pars_tj = [g k 0 vHb vHp]; % vHp functions as vHj in get_tj
  [tp, tpp, tb, lp, lpp, lb, li, rj, rB, info] = get_tj(pars_tj, f);
  sM = lp/ lb; % -, acceleration factor

  % from puberty till pupation
  [vR, tl] = ode45(@dget_tj_hax, [0; vRj], [0; lp], [], f, sM, rB, li, g, k, vHp);
  tj = tp + tl(end,1); % -, scaled age at pupation
  lj = tl(end,2);      % -, scaled length at pupation
        
  % from pupation to emergence; 
  % instantaneous conversion from larval structure to pupal reserve
  uEj = lj^3 * (kap * kapV + f/ g);       % -, scaled reserve at pupation

  options = odeset('Events', @emergence);
  [t, luEvH, te, luEvH_e] = ode45(@dget_tj_hex, [0; 300], [0; uEj; 0], options, sM, g, k, vHe);
  
  if isempty(te)
    te = []; le = []; uEe = []; info = 0;
  else
    te = tj + te;     % -, scaled age at emergence 
    le = luEvH_e(1);  % -, scaled length at emergence
    uEe = luEvH_e(2); % -, scaled reserve at emergence
  end

end

%% subfunctions

function dtl = dget_tj_hax(vR, tl, f, sM, rB, li, g, k, vHp)
  l = tl(2); % -, scaled length

  dl = rB * max(0, li - l);
  dvR = (f * g * sM/ l + f)/ (g + f) - k * vHp/ l^3 - 3 * rB * vR * (f * sM/ l - 1);

  dtl = [1; dl]/ dvR; % pack output
end

function dluEvH = dget_tj_hex(t, luEvH, sM, g, k, vHe)
  l = luEvH(1); l2 = l * l; l3 = l * l2; l4 = l * l3; uE = max(1e-6, luEvH(2)); vH = luEvH(3);

  dl = (sM * g * uE - l4)/ (uE + l3)/ 3;
  duE = - uE * l2 * (sM * g + l)/ (uE + l3);
  dvH = - duE - k * vH;

  dluEvH = [dl; duE; dvH]; % pack output
end

function [value,isterminal,direction] = emergence(t, luEvH, sM, g, k, vHe)
 value = vHe - luEvH(3); 
 isterminal = 1;
 direction = 0;
end