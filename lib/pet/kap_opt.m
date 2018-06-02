%% kap_opt
% finds kappa that maximizes max reprod rate

%%
function [kap R_i] = kap_opt(model, par, T, f) 
% created 2016/06/09 by Bas Kooijman

%% Syntax
% [kap R_i] = <kap_opt.m *kap_opt*>(model, par, T, f)

%% Description
% Finds kappa that maximizes max reprod rate given all other parameters.
% For models hep and hex, however, it is kappa that maximizes cumulative numer of eggs.
%
% Input
%
% * model: string with name of model
% * par:   structure with primary parameters at reference temperature in time-length-energy frame
% * T:     optional scalar with temperature in Kelvin; default C2K(20)
% * f:     optional scalar scaled functional response; default 1
% 
% Output
% 
% * kap:   2-vector, optimal, actual kappa
% * R_i:   2-vector, optimal, actual max reprod rate (#/d)

%% Remarks
% uses <reprod_rate_i.html *reprod_rate_i*> to compute max reprod rate.
% Use <../../../AmPtool/html/read_pars.html *read_pars*> to extract model and parameters from allStat

%% Example of use
% kap_opt('std', par, C2K(20), 1) 

  kap = par.kap; z = par.z;
  R_i = fngain(model, par, T, f); % get actual value
  
  del = 0.02;  % intial step size in kap
  kap_0 = 0.7; % kap close to optimal value
  par.kap = kap_0; par.z = z * kap_0/ kap; R_0 = fngain(model, par, T, f);
  %i = 1; [i kap_0 R_0]

  kap_1 = kap_0 + del;
  par.kap = kap_1; par.z = z * kap_1/ kap; R_1 = fngain(model, par, T, f);
  %i = i + 1; [i kap_1 R_1]
  if R_1 < R_0
    del = -del;
    kap_1 = kap_0 + del;
    par.kap = kap_1; par.z = z * kap_1/ kap; R_1 = fngain(model, par, T, f);
    %i = i + 1; [i kap_1 R_1]
  end

  while abs(del) > 1e-6 && abs(R_0 - R_1) > 1e-4
    while R_1 > R_0 
      kap_0 = kap_1; R_0 = R_1;
      kap_1 = kap_0 + del;
      if kap_1 > 1
        kap_1 = (1 + kap_0)/2;
      elseif kap_1 < 0
       kap_1 = kap_0/2;
      end
      par.kap = kap_1; par.z = z * kap_1/ kap; R_1 = fngain(model, par, T, f);
      %i = i + 1; [i kap_1 R_1]
    end
    kap_0 = kap_1; R_0 = R_1;
    del = -del/5;       
    kap_1 = kap_0 + del;
    if kap_1 > 1
      kap_1 = (1 + kap_0)/2;
    elseif kap_1 < 0
       kap_1 = kap_0/2;
    end
    par.kap = kap_1; par.z = z * kap_1/ kap; R_1 = fngain(model, par, T, f);
    %i = i + 1; [i kap_1 R_1]
  end
  
  % finish
  kap_m = kap_1; R_m = R_1;
  kap = [kap_m; kap]; R_i = [R_m; R_i];

end

function R_i = fngain(model, par, T, f)
  switch model
    case {'hep','hex'}
      [x R_i] = reprod_rate_i(model, par, T, f);
    otherwise
      R_i = reprod_rate_i(model, par, T, f);
  end
end
