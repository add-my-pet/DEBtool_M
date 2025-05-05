%% rotate3D
% rotates a 3D structure

%%
function rotate3D(Hfig, fnm, EL)
% created 2024/08/06 by Bas Kooijman

%% Syntax
% <../rotate3D.m *rotate3D*> (Hfig, n, fnm, refpoint1, refpoint2) 

%% Description
% Rotates a 3D plot around z-axis and optionally saves it in an animated png file
%
% Input:
%
% * Hfig: figure handle 
% * fnm: optional output filename (extension .png is added automatically). No name, no save
% * EL: optional scalar for view on xy-plane (default 30)
%
% Output:
% 
% * if fnm is specified file fnm.png is written that rotates if opened with a browser

%% Remarks
% If fnm is specified, a temporatry subdir is created; 
% Assumes that system can find by the open-source animated png-assembler apngasm-2.91-bin-win64.exe

%% Example of use
% see mydata_rotate3D

  n = 100; % number of frames
  theta = 360/ n;% rotation increment

  axis vis3d

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
  system(['apngasm64 ../',fnm,' frame*.png 1 5']);
else
  system(['powershell apngasm64 ../',fnm,' frame*.png 1 5']);
end

delete *.png
cd(WD);
rmdir(nmDir)

