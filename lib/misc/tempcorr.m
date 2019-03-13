%% tempcorr
% computes temperature correction factor

%%
function TC = tempcorr (T, T_ref, pars_T)
  %  Created at 2002/04/09 by Bas Kooijman; modified 2005/01/24, 2016/11/18, 
  %  Dina Lika & Bas Kooijman: 2019/02/26
  
  %% Syntax
  % TC = <../tempcorr.m *tempcorr*> (T, T_ref, pars_T)

  %% Description
  %  Calculates the factor with which physiological rates should be multiplied 
  %    to go from a reference temperature to a given temperature.
  %  The 3-parameter version models low or high temerature torpor, depending the the value of the boudary temparature, relative to the  reference temperatur, the 5-parameter version models both.
  %  The 5- parameter version assumes that the reference temperature is between the lower and upper temperature boundaries.
  %
  % Input
  %
  % * T: vector with temperatures in K
  % * T_ref: scalar with reference temperature in K
  % * pars_T: 1-, 3- or 5-vector with temperature parameters in K
  %
  %    1: T_A: Arrhenius temperature
  %    3: T_A, T_L, T_AL or T_A, T_H, T_AH: Arrhenius temperature, boundary temperature, Arrhenius temperature for that boundary temperature
  %    5: T_A, T_L, T_H, T_AL, T_AH    
  %
  % Output:
  %
  % * TC: vector with temperature correction factor(s) that affect(s) all rates
   
  %% Remarks
  %  The intended use is: (rate at  T) = (rate at T_ref) * tempcorr (T, T_ref, pars_T). 
  %  Notice that tempcorr (T_ref, T_ref, pars_T) results in the value 1, independent of pars_T.
  %  Notice also that the result with one parameter is always larger than with 3 or 5 parameters, with the same first parameter.
  %  The Arrhenius temperature T_A affects rates at the full temperature-range. 
  %
  %  The interpretation of the parameters in the 3-parameter version depends on the value of pars_T(2), relative to T_ref.
  %  If pars_T(2) < T_ref, it is assumed that T_L = pars_T(2) and T_AL = pars_T(3), and low-temperature torpor is modelled.
  %  If pars_T(2) > T_ref, it is assumed that T_H = pars_T(2) and T_AH = pars_T(3), and high-temperature torpor is modelled.
  %
  %  Low-temperature torpor does not affect rates at temperatures larger than T_ref; the reverse applies for high-temperature torpor.
  %  This also holds for the 5-parameter version. 
  %
  %  <shtempcorr.html *shtempcorr*> shows a graph of this correction factor as function of the temperature. 

  %% Example of use
  %  tempcorr([330 331 332], 320, [12000 277 328 20000 190000]) and 
  %  shtemp2corr(320, [12000 277 328 20000 190000]). 

  T_A = pars_T(1); % Arrhenius temperature
    s_A = exp(T_A/ T_ref - T_A ./ T);  % Arrhenius factor
    
  if length(pars_T) == 1
    TC = s_A;
    
  elseif length(pars_T) == 3 % either low-temperature torpor or high-temperature torpor
    if pars_T(2) < T_ref
      T_L  = pars_T(2); % Lower temp boundary
      T_AL = pars_T(3); % Arrh. temp for lower boundary
      s_L_ratio = (1 + exp(T_AL ./ T_ref - T_AL/ T_L)) ./ ...
	              (1 + exp(T_AL ./ T     - T_AL/ T_L));
      TC = s_A .* ((T <= T_ref) .* s_L_ratio + (T > T_ref));
    else % pars_T(2) > T_ref
      T_H  = pars_T(2); % Upper temp boundary
      T_AH = pars_T(3); % Arrh. temp for upper boundary
      s_H_ratio = (1 + exp(T_AH/ T_H - T_AH ./ T_ref)) ./ ...
	              (1 + exp(T_AH/ T_H - T_AH ./ T    ));
      TC = s_A .* ((T >= T_ref) .* s_H_ratio + (T < T_ref));
    end
         
  else % length(pars_T) == 5: both low- and high-temperature torpor
    T_L  = pars_T(2);  % Lower temp boundary
    T_H  = pars_T(3);  % Upper temp boundary
    T_AL = pars_T(4);  % Arrh. temp for lower boundary
    T_AH = pars_T(5);  % Arrh. temp for upper boundary
    
    if T_L > T_ref || T_H < T_ref
      fprintf('Warning from temp_corr: invalid parameter combination, T_L > T_ref and/or T_H < T_ref\n')
      TC = [];
      return
    end

    s_L_ratio = (1 + exp(T_AL/ T_ref - T_AL/ T_L)) ./ ...
	            (1 + exp(T_AL ./ T   - T_AL/ T_L));
    s_H_ratio = (1 + exp(T_AH/ T_H - T_AH/ T_ref)) ./ ...
	            (1 + exp(T_AH/ T_H - T_AH ./ T  ));
    TC = s_A .* ((T <= T_ref) .* s_L_ratio + (T > T_ref) .* s_H_ratio);    
  end
