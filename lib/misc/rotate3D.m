%% rotate3D
% rotates a 3D structure

%%
function rotate3D(Hfig, n, fnm, EL)
% created 2024/08/06 by Bas Kooijman

%% Syntax
% h = <../rotate3D.m *rotate3D*> (Hfig, n, fnm, refpoint1, refpoint2) 

%% Description
% Rotates a 3D structure around z-axis and optionally saves it in an animated png file
%
% Input:
%
% * Hfig: figure handle 
% * n: optional number of views for a 360 degrees rotation (default 30)
% * fnm: optional output filename (extension .png is added automatically). No name, no save
% * refY: optional scalar for view on y-axis (default 90)
% * refZ: optional scalar for view on z-axis (default 100)
%
% Output:
% 
% * h : rotation handle

%% Remarks
% If fnm is specified, a temporatry subdir is created; 
% Assumes that system can find by the open-source animated png-assembler apngasm-2.91-bin-win64.exe

if ~exist('n','var') || isempty(n)
  n = 30; theta = 12;
else
 theta = 360/ n;
end

if ~exist('fnm','var'); fnm = ''; end
if ~isempty(fnm); nmDir = fnm; fnm = [fnm, '.png']; mkdir(nmDir); end
if ~exist('EL','var') || isempty(EL); EL = 30; end

for i=0:n-1
  view([i*theta EL])
  pause(0.1)
  if ~isempty(fnm)
     frame = ['000', num2str(i)]; frame = frame(end-2:end);
     plotNm = ['frame', frame, '.png'];
     print([nmDir,'/',plotNm], '-dpng');
  end
end

if isempty(fnm); return; end
WD = pwd; cd(nmDir); 
if ismac || isunix
  system(['apngasm64 ../',fnm,' frame*.png']);
else
  system(['powershell apngasm64 ../',fnm,' frame*.png']);
end
delete *.png
cd(WD);
rmdir(nmDir)

