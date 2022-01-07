%% randN
% random trials from a standard normal distribution 
%%

function val = randN(n,m)
% created 2022/01/07 by Bas Kooijman

%% Syntax
% val = <../randN.m *randN*> (n,m) 

%% Description
% generates random trials from a standard normal distribution using the Box-Muller method
%
% Input:
%
% * n: scalar with number of rows
% * m: optional scalar with number of columns (default 1)
%
% Output:
%
% * val: (n,m)-array with random trials from a N(0,1) distribution

%% Example of use
% x=randN(10)

if ~exist('m','var') || isempty(m)
    m = 1;
end

val = sqrt(-2 * log(rand(n,m))) .* cos(2 * pi * rand(n,m));