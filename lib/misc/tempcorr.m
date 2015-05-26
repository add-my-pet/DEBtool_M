function TC = tempcorr (T,T_1,Tpars)
  %  Created at 2002/04/09 by Bas Kooijman; modified 2005/01/24
  %
  %% Description
  %  Calculates the factor with which physiological rates should be multiplied 
  %    to go from a reference temperature to a given temperature. 
  %
  %% Input
  %  T: vector with new temperatures
  %  T_1: scalar with reference temperature
  %  Tpars: 1-, 3- or 5-vector with temperature parameters:
  %
  %% Output
  %  TC: vector with temperature correction factor(s) that affect(s) all rates
  % 
  %% Remarks
  %  shtempcorr shows a graph of this correction factor as function of the temperature. 
  %
  %% Example of use
  %  tempcorr([330 331 332], 320, [12000 277 318 20000 190000]) and 
  %  shtemp2corr(320, [12000 277 318 20000 190000]). 

  %% Code
  T_A = Tpars(1); % Arrhenius temperature
  if length(Tpars) == 1
    TC = exp(T_A/T_1 - T_A./T);
  elseif length(Tpars) == 3
    T_L = Tpars(2); % Lower temp boundary
    T_AL = Tpars(3); % Arrh. temp for lower boundary
    TC = exp(T_A/ T_1 - T_A./ T) * (1 + exp(T_AL./ T_1 - T_AL/ T_L)) ./ ...
         (1 + exp(T_AL./ T - T_AL/ T_L));
  else
    T_L = Tpars(2); % Lower temp boundary
    T_H = Tpars(3); % Upper temp boundary
    T_AL = Tpars(4); % Arrh. temp for lower boundary
    T_AH = Tpars(5); % Arrh. temp for upper boundary

    TC = exp(T_A/ T_1 - T_A./ T) * ...
	(1 + exp(T_AL./ T_1 - T_AL/ T_L) + exp(T_AH/ T_H - T_AH./ T_1))./ ...
	(1 + exp(T_AL./ T - T_AL/ T_L) + exp(T_AH/ T_H - T_AH./ T));
  end
