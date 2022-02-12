%% maturity_hax
% Gets maturity as function of length for model hax

%%
function H = maturity_hax(L, f, p, lb, lp, lj, le, tj)
  %  created 2022/01/31 by Bas Kooijman
  
  %% Syntax
  % [H, info] = <../maturity_hax.m *maturity_hax*> (L, f, p, lb, lp, lj, le, tj)
  
  %% Description
  % Life history events b (birth), p (puberty), j (pupation), e (emergence)
  % Calculates the scaled maturity UH = MH/ {JEAm} at constant food density in the case of 
  %  acceleration between b and p, pupa between j and e, (non-growing) imago after e.
  % No further maturation after p, so Hp = Hj, and a re-set of maturity at j. Maturity of pupa increases from 0 to He. 
  % Lengths must be ordered in time (so a single stepdown from L_j to 0 at j.
  % Lengths are in the pupal stage if an earlier length was larger. 
  % So [.2 .3 .8] are lengths in the egg or larva stage (before pupation, because they only increase), 
  %  but the last 3 in [.3 .2 .3 .8] are in the pupal stage, because they follow a larger length.
  %
  % Input
  %
  % * L: n-vector with length 
  % * f: scalar with (constant) scaled functional response
  % * p: 10-vector with parameters: kap kapV g kJ kM v UHb UHp UHe
  % * lb: scaled length at birth at f
  % * lp: scaled length at pupation at f
  % * lj: scaled length at metm at f
  % * le: scaled length at emergence at f
  % * tj: scaled age at metam at f
  % 
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/ {J_EAm} = E_H/ {p_Am}
  
  %% Remarks
  % Maturity in the larval stage (between puberty and pupation) stays at puberty level.
  % Maturity and structure are reset to zero at pupation and freeze at emergence of the imago.
  % See <maturity.html *maturity*> in absence of acceleration and
  % <maturity_j.html *maturity_j*> with accleration,
  % <maturity_s.html *maturity_s*> if accleration is delayed.
  % Called from scaled_power_hax.

  %% Example of use
  % [H, a, info] = maturity_hex(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, .4, 2])
 
  % unpack parameters
  kap  = p(1);  % -, fraction allocated to growth + som maint
  kapV = p(2);  % -, conversion efficiency from larval reserve to larval structure, back to imago reserve
  g    = p(3);  % -, energy investment ratio
  kJ   = p(4);  % 1/d, maturity maint rate coeff
  kM   = p(5);  % 1/d, somatic maint rate coeff
  v    = p(6);  % cm/d, energy conductance
  Hb   = p(7);  % d cm^2, E_Hb/ {p_Am}, scaled maturity at birth
  Hp   = p(8);  % d cm^2, E_Hp/ {p_Am}, scaled maturity at puberty
  He   = p(9);  % d cm^2, E_He/ {p_Am}, scaled maturity at emergence
    
  if isempty(f)
    f = 1; % abundant food
  end

  % split L in L_pre and L_post j 
  Lm = v/ kM/ g; Lj = Lm * lj; Le = Lm * le; Lb = Lm * lb; Lp = Lm * lp; k = kJ/ kM; kE = v/ Lb; sM = Lp/Lb;         
  nL = length(L); L_pre = L(1);
  if nL > 1
    for i = 2:nL
      if L(i) > L(i-1)
        L_pre = [L_pre; L(i)];
      end
    end
  end
  nL_pre = length(L_pre); L_post = L; L_post(1:nL_pre) = []; nL_post = length(L_post);

  % embryo till pupation
  uHb = Hb * g^2 * kM^3/ (v^2); vHb = uHb/ (1 - kap);  
  uHp = Hp * g^2 * kM^3/ (v^2); 
  ue0 = get_ue0([g; k; vHb], f, lb); % initial scaled reserve M_E^0/{J_EAm}
  [l_out, teh] = ode45(@dget_teh_j, [1e-6; L_pre(1)/ 2; L_pre]/ Lm, [0; ue0; 0], [], k, g, kap, f, uHb, uHp, lb, lp);
  teh(1:2,:) = []; 
  H = teh(:,3) * v^2/ g^2/ kM^3; % d.cm^2, scaled maturity
  H(L >= Lp) = Hp;
  
  % pupa and imago
  if nL_post > 0
    v_j = v * sM;                            % cm/d, energy conductance of imago
    aVEH_0 = [0; Lj^3; f * Lj^3/ v_j; 0];    % state at start pupation
    [L_out, aVEH] = ode45(@dget_aVEH, [1e-6; L_post(1)/ 2; L_post], aVEH_0, [], g, kJ, kM, kE, v_j, kap, kapV);
    aVEH(1:2,:) = []; H = aVEH(:,4); 
  end

end

% subfunctions

function dtEH = dget_teh_j(l, tEH, k, g, kap, f, uHb, uHp, lb, lp)
  % l: scalar with scaled length  l = L g k_M/ v
  % tEH: 3-vector with (tau, uE, uH) of embryo and juvenile
  %   tau = a k_M; scaled age
  %   uE = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   uH = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dtEH: 3-vector with (dt/duH, duE/duH, dl/duH)
  % called by maturity_j
  
  t = tEH(1); % scaled age
  uE = max(1e-10,tEH(2)); % scaled reserve
  uH = tEH(3); % scaled maturity
  l2 = l * l; l3 = l2 * l;
 
  % first obtain dl/dt, duE/dt, duH/dt
  if uH < uHb % isomorphic embryo
    r = (g * uE/ l - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE =  - uE * (g/ l - r);
    duH = (1 - kap) * uE * (g/ l - r) - k * uH;
  elseif uH < uHp % V1-morphic juvenile
    rj = (g * uE/ lb - l3)/ (uE + l3); % scaled exponential growth rate between b and j
    dl = l * rj/ 3;
    duE = f * l^3/ lb - uE * (g/ lb - rj);
    duH = (1 - kap) * uE * (g/ lb - rj) - k * uH;
  else % isomorphic adult
    sM = lp/ lb;
    r = (g * uE * sM/ l - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 * sM - uE * (g * sM/ l - r);
    duH = 0; % no maturation in adults
  end

  % then obtain dt/dl, duE/dl, duH/dl, 
  dtEH = [1; duE; duH]/ dl;
end

  function daVEH = dget_aVEH(L, aVEH, g, k_J, k_M, k_E, v, kap, kap_V)
    % pupal development
    % L: cm, structural length of imago
           
    % unpack variables aVEH
    %a  = aVEH(1); % d, time since pupation 
    V  = aVEH(2);  % cm^3, structural volume of larva
    UE  = aVEH(3); % d.cm^2, E/{p_Am}, scaled reserve of pupa
    UH  = aVEH(4); % d.cm^2, E_H/{p_Am}, scaled maturity 
     
    L_m = v/ k_M/ g; % cm, max structural length
    
    % first obtain dL/dt, dV/dt, dUE/dt, dUH/dt
    dV = - V * k_E;                     % cm^3/d, change larval structure
    
    e = v * UE/ L^3;                    % -, scaled reserve density
    r = v * (e/ L - 1/ L_m)/ (e + g);   % 1/d, specific growth rate
    SC = UE * (v/ L - r);               % cm^2, scaled mobilisation rate
    dUE = - dV * kap_V * kap * g/ v - SC;  % cm^2, change in scaled reserve

    dL = r * L/ 3;                      % cm/d, change in length
    dUH = (1 - kap) * SC - k_J * UH;    % cm^2, change in scaled maturity
      
    % then obtain dt/dL, dUE/dL, dUH/dL
    daVEH = [1; dV; dUE; dUH]/ dL;      % pack derivatives
  end
