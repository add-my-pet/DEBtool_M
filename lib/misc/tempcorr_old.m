%% tempcorr
% computes temperature correction factor

%%
function TC = tempcorr_old (T, T_ref, pars_T)
  %  Created at 2002/04/09 by Bas Kooijman; modified 2005/01/24, 2016/11/18
  
  %% Syntax
  % TC = <../tempcorr_old.m *tempcorr_old*> (T, T_ref, pars_T)

  %% Description
  %  Calculates the factor with which physiological rates should be multiplied 
  %    to go from a reference temperature to a given temperature. The
  %    3 and 5- parameter versions of the Arrhenius module suppose that the
  %    reference temperature is contained within the thermal neutral zone.
  %
  % Input
  %
  % * T: vector with new temperatures
  % * T_ref: scalar with reference temperature
  % * pars_T: 1-, 3- or 5-vector with temperature parameters
  %
  %    1: T_A
  %    3: T_A, T_L, T_AL
  %    5: T_A, T_L, T_H, T_AL, T_AH    
  %
  % Output:
  %
  % * TC: vector with temperature correction factor(s) that affect(s) all rates
   
  %% Remarks
  %  <shtempcorr.html *shtempcorr*> shows a graph of this correction factor as function of the temperature. 
  %  To avoid unexpected behaviour in a 5-parameter application, make sure that T_L < T_A < T_H
  
  %% Example of use
  %  tempcorr([330 331 332], 320, [12000 277 318 20000 190000]) and 
  %  shtemp2corr(320, [12000 277 318 20000 190000]). 

  T_A = pars_T(1); % Arrhenius temperature
  if length(pars_T) == 1
    TC = exp(T_A/ T_ref - T_A ./ T);
    
  elseif length(pars_T) == 3
    T_L  = pars_T(2); % Lower temp boundary
    T_AL = pars_T(3); % Arrh. temp for lower boundary
    TC = exp(T_A/ T_ref - T_A ./ T) .* ...
         (1 + exp(T_AL ./ T_ref - T_AL/ T_L)) ./ ...
         (1 + exp(T_AL ./ T     - T_AL/ T_L));
          
    if T_ref <= T_L
       fprintf('warning reference temperature is lower than T_L \n');
    end
     
  else
    T_L  = pars_T(2);  % Lower temp boundary
    T_H  = pars_T(3);  % Upper temp boundary
    T_AL = pars_T(4);  % Arrh. temp for lower boundary
    T_AH = pars_T(5);  % Arrh. temp for upper boundary

    TC = exp(T_A/ T_ref - T_A ./ T) .* ...
	     (1 + exp(T_AL ./ T_ref - T_AL/ T_L) + exp(T_AH/ T_H - T_AH ./ T_ref)) ./ ...
	     (1 + exp(T_AL ./ T     - T_AL/ T_L) + exp(T_AH/ T_H - T_AH ./ T    ));
    
    if T_ref >= T_H
      fprintf('warning reference temperature is higher than T_H \n')    
    elseif T_ref <= T_L
      fprintf('warning reference temperature is lower than T_L \n');
    end
    
  end
