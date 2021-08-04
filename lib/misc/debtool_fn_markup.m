%% Name of DEBtool function
% Put short description here
% can implement a link to a paper like <http://www.bio.vu.nl/thb/research/bib/Kooy2014.html *this*>.

%%
function [output1, output2] = debtool_fn_markup(input1, input2)
% created year/month/day by AUTHOR; modified year/month/day AUTHOR

%% Syntax
% [output1, output2] = <../debtool_fn_markup.m *debtool_fn_markup*> (input1, input2) 
% (please notice that the name of the function/script is hyperlinked to the code for that function/script!)

%% Description
% Description of what the funtion or script actually does. It is even possible to
% specify what type of formula is used if one wants.
%
% Input:
%
% * Input 1 : (scalar, n-vector, n-p matrix, structure) containing ...
% * p: 3-vector with parameters: 
%
%    - g : energy investement ratio, - 
%    - k : 
%    - v_H^b : scaled maturity at birth 
%
% * Input 2 : (scalar, n-vector, n-p matrix, structure) containing ...
%
% Output:
% 
% * Output 1 : (scalar, n-vector, n-p matrix, structure) containing ...
% * Output 2 : (scalar, n-vector, n-p matrix, structure) containing ...
% * two examples of specifying an output are lb: scalar with scaled length at birth, info: indicator equals 1 if successful, 0 otherwise

%% Remarks
% Add this section if need be to put any specific comments one might have about the script or the function. 
% For example you could write something like: the theory behind debtool_function is discussed in
% <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b *this paper*>.
% In fact it is highly recommended to put a link to a relevant DEB theory paper upon which the function/script is based.

%% Example of use
% Put here an example of use. 
% Often times there is a mydata_debtool_function script which uses the function. 
% We can refer to that script here and perhaps make a link to it. 
% See how the link to a function is implemented under the syntax function.

%% Publish settings
% options.showCode = false; 
% options.evalCode = false; 
% options.catchError = false; 
% publish('debtool_function', options);
% The default format is html and the file will by default also be placed in
% a subdirectory html of the folder of that toolbox.
