function escapedStr = strescape(str)
%STRESCAPE Escape control character sequences in a string.
% STRESCAPE(STR) converts the escape sequences in a string to the values
% they represent.
%
% Example:
%
% strescape('Hello World\n')
%
% See also SPRINTF.
% Copyright 2012 The MathWorks, Inc.
% $Revision: 1.1.6.2.2.1 $ $Date: 2012/12/17 21:52:15 $
escapeFcn = @escapeChar; %#ok<NASGU>
escapedStr = regexprep(str, '\\(.|$)', '${escapeFcn($1)}');
end
%--------------------------------------------------------------------------
function c = escapeChar(c)
switch c
case '0' % Null.
c = char(0);
case 'a' % Alarm.
c = char(7);
case 'b' % Backspace.
c = char(8);
case 'f' % Form feed.
c = char(12);
case 'n' % New line.
c = char(10);
case 'r' % Carriage return.
c = char(13);
case 't' % Horizontal tab.
c = char(9);
case 'v' % Vertical tab.
c = char(11);
case '\' % Backslash.
case '' % Unescaped trailing backslash.
c = '\';
otherwise
warning(message('MATLAB:strescape:InvalidEscapeSequence', c, c));
end
end