%% addpseudodata
% Adds pseudodata information into inputed data structures 

%%
function [data, units, label, weights] = addpseudodata(data, units, label, weights)
% created 2015/01/16 by Goncalo Marques and Bas Kooijman, 2018/08/26, 2023/07/23 Bas Kooijman

%% Syntax
% [data, units, label, weight] = <../addpseudodata.m *addpseudodata*> (data, units, label, weight)

%% Description
% Adds the pseudodata information and weights for purposes of the regression
%
% Inputs:
%
% * data : structure with data values 
% * units : structure with data units 
% * label : structure with data labels 
% * weights : structure with data weights for a regression 
%
% Output: 
%
% * data : structure with data and pseudodata values 
% * units : structure with data and pseudodata units 
% * label : structure with data and pseudodata labels 
% * weights : structure with data and pseudodata weights for a regression 

%% Example of use
% [data, units, label, weight] = addpseudodata([], [], [], []);
% Will create the four structures data, units, label and weight with pseudodata information

global loss_function

% set pseudodata
data.psd.v = 0.02;     units.psd.v = 'cm/d';       label.psd.v = 'energy conductance';
data.psd.p_M = 18;     units.psd.p_M = 'J/d.cm^3'; label.psd.p_M = 'vol-spec som maint';   
data.psd.k_J = 0.002;  units.psd.k_J = '1/d';      label.psd.k_J = 'maturity maint rate coefficient';
data.psd.k = 0.3;      units.psd.k = '-';          label.psd.k = 'maintenance ratio';
data.psd.kap = 0.8;    units.psd.kap = '-';        label.psd.kap = 'allocation fraction to soma';
data.psd.kap_G = 0.8;  units.psd.kap_G = '-';      label.psd.kap_G = 'growth efficiency'; 
data.psd.kap_R = 0.95; units.psd.kap_R = '-';      label.psd.kap_R = 'reproduction efficiency';

% set weights
weights.psd = setweights(data.psd, []);
weights.psd.v     = 0.1 * weights.psd.v;
weights.psd.p_M   = 0.1 * weights.psd.p_M;
weights.psd.k_J   = 0.1 * weights.psd.k_J;
weights.psd.k     = 0 * weights.psd.k;
weights.psd.kap   = 0.1 * weights.psd.kap;
weights.psd.kap_G = 20 * weights.psd.kap_G;
weights.psd.kap_R = 0.1 * weights.psd.kap_R;

if strcmp(loss_function, 'su')
  weights.psd.v     = 1e-4 * weights.psd.v;
  weights.psd.p_M   = 1e-4 * weights.psd.p_M;
  weights.psd.k_J   = 1e-4 * weights.psd.k_J;
  weights.psd.k     = 1e-4 * weights.psd.k;
  weights.psd.kap   = 1e-4 * weights.psd.kap;
  weights.psd.kap_G = 1e-4 * weights.psd.kap_G;
  weights.psd.kap_R = 1e-4 * weights.psd.kap_R;
end
