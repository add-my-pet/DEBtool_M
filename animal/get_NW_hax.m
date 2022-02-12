%% get_NW_hax
% Gets number of eggs at emergence for hax model from wet weight of imago

%%
function [N, f, le] = get_NW_hax(Ww, pars_tj, pars_aux)
  % created at 2017/08/01 by Bas Kooijman, modified 2022/01/30
  
  %% Syntax
  % [N, f, l_e] = <../get_NW_hax.m *get_NW_hax*> (Ww, pars_tj, pars_aux)
  
  %% Description
  % Obtains number of eggs at pupation from wet weight at pupation for hax model
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * Ww: n-vector with scaled wet weights at pupation in grams
  % * pars_tj: 8-vector with parameters: g, k, v_Hb, v_Hp, v_Rj, v_He, kap, kapV
  % * pars_aux: 6-vector with parameters: kap_R, E_m, L_m, w_E, mu_E, d_E
  %  
  % Output
  %
  % * N: n-vector with number of eggs at pupation
  % * f: n-vector with functional response 
  % * le: n-vector with scaled structural length at pupation
  
  %% Remarks
  %  First finds f from Ww, then N and le from f.
  %  Weights at emergence include reprod buffer.
  %  See get_NW_hep and get_NW_hex for hep and hex model
  
  %% Example of use
  %  get_NW_hax([.5, .1, .01, .05, .2, 0.8, .95])
   
   kap = pars_tj(7); v_Rj = pars_tj(5); kap_R = pars_aux(1); % unpack parameters
   g = pars_tj(1); E_m = pars_aux(2); L_m = pars_aux(3); w_E = pars_aux(4); mu_E = pars_aux(5); d_E = pars_aux(6);
      
   % first get Ww_j, N_j and l_i values for a range of f-values
   f_knot = [0.05; (.1:.1:1.5)']; n_f = length(f_knot); 
   lj_knot = zeros(n_f,1); N_knot = zeros(n_f,1); Wwj_knot = zeros(n_f,1);
   for i=1:n_f
     [tj, tp, tb, lj_knot(i), lp, lb, li, rj, rB, uEj] = get_tjj_hax(pars_tj, f_knot(i));
     N_knot(i) = kap_R * (1 - kap) * v_Rj * lj_knot(i)^3/ get_ue0(pars_tj, f_knot(i)); % total # of eggs
     Ww_Rj = v_Rj * (1 - kap) * g * E_m * (L_m * lj_knot(i))^3 * w_E/ mu_E/ d_E;    % g, wet weight reprod buffer at pupation
     Wwj_knot(i) = (L_m * lj_knot(i))^3 + Ww_Rj + uEj * g * E_m * L_m^3 * w_E/ mu_E/ d_E; % g, wet weight including reprod buffer
   end
   
   % now interpolate in splines
   f  = spline1(Ww,[Wwj_knot, f_knot],[],[]); %f for Ww
   N  = spline1(f,[f_knot, N_knot],[],[]); % N for f
   le = spline1(f,[f_knot, lj_knot],[],[]); % le for f
   
end

%% subfunction

function [tj, tp, tb, lj, lp, lb, li, rj, rB, uEj] = get_tjj_hax(p, f)
  % like get_tj_hax, but without pupation stage
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am} start acceleration
  vHp = p(4); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am} end acceleration
  vRj = p(5); % (kap/(1 - kap)) [E_R^j]/ [E_G] scaled reprod buffer density at pupation
    
  % from zero till puberty
  pars_tj = [g k 0 vHb vHp]; % vHp functions as vHj in get_tj
  [tp, tpp, tb, lp, lpp, lb, li, rj, rB] = get_tj(pars_tj, f);
  sM = lp/ lb; % -, acceleration factor

  % from puberty till pupation
  [vR tl] = ode45(@dget_tj_hax, [0; vRj], [0; lp], [], f, sM, rB, li, g, k, vHp);
  tj = tp + tl(end,1); % -, scaled age at pupation
  lj = tl(end,2);      % -, scaled length at pupation
        
  uEj = lj^3 * (1 + f/ g);       % -, scaled reserve at pupation

end

%% subfunctions

function dtl = dget_tj_hax(vR, tl, f, sM, rB, li, g, k, vHp)
  l = tl(2); % -, scaled length

  dl = rB * max(0, li - l);
  dvR = (f * g * sM/ l + f)/ (g + f) - k * vHp/ l^3 - 3 * rB * vR * (f * sM/ l - 1);

  dtl = [1; dl]/ dvR; % pack output
end
