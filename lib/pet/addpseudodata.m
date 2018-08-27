%% addpseudodata
% Adds pseudodata information into inputed data structures 

%%
function [data, units, label, weight] = addpseudodata(data, units, label, weight)
% created 2015/01/16 by Goncalo Marques and Bas Kooijman, 2018/08/26 Bas Kooijman

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
% * weight : structure with data weights for a regression 
%
% Output: 
%
% * data : structure with data and pseudodata values 
% * units : structure with data and pseudodata units 
% * label : structure with data and pseudodata labels 
% * weight : structure with data and pseudodata weights for a regression 

%% Example of use
% [data, units, label, weight] = addpseudodata([], [], [], []);
% Will create the four structures data, units, label and weight with pseudodata information

global loss_function

% set pseudodata
data.psd.v = 0.02;     units.psd.v = 'cm/d';       label.psd.v = 'energy conductance';
data.psd.kap = 0.8;    units.psd.kap = '-';        label.psd.kap = 'allocation fraction to soma';
data.psd.kap_R = 0.95; units.psd.kap_R = '-';      label.psd.kap_R = 'reproduction efficiency';
data.psd.p_M = 18;     units.psd.p_M = 'J/d.cm^3'; label.psd.p_M = 'vol-spec som maint';   
data.psd.k_J = 0.002;  units.psd.k_J = '1/d';      label.psd.k_J = 'maturity maint rate coefficient';
data.psd.kap_G = 0.8;  units.psd.kap_G = '-';      label.psd.kap_G = 'growth efficiency'; 

% set weights
weight.psd = setweights(data.psd, []);
weight.psd.v     = 0.1 * weight.psd.v;
weight.psd.kap   = 0.1 * weight.psd.kap;
weight.psd.kap_R = 0.1 * weight.psd.kap_R;
weight.psd.kap_G = 0.1 * weight.psd.kap_G;
weight.psd.p_M   = 0.1 * weight.psd.p_M;
weight.psd.k_J   = 0.1 * weight.psd.k_J;

weight.psd.kap_G = 200 * weight.psd.kap_G;   % more weight to kap_G

if strcmp(loss_function, 'su')
  weight.psd.v     = 10^(-4) * weight.psd.v;
  weight.psd.p_M   = 10^(-4) * weight.psd.p_M;
  weight.psd.k_J   = 10^(-4) * weight.psd.k_J;
  weight.psd.kap_R = 10^(-4) * weight.psd.kap_R;
  weight.psd.kap   = 10^(-4) * weight.psd.kap;
  weight.psd.kap_G = 10^(-4) * weight.psd.kap_G;
end
