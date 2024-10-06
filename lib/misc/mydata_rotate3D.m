  %% mydata_rotate3D
  % demo that produces an animated png picture in 3D; it rotates when opened in a browser, such as Firefox
  % make sure that your operating system can find the open-source animated png-assembler apngasm-2.91-bin-win64.exe
  % this assembler app is ran outside Matlab by Matlab function rotate3D
  
  close all
  z = linspace(0,10,500)'; y = z.*cos(z); x = z.*sin(z); % set data
  
  Hfig = figure; % assign figure-handle for use in rotate3D
  plot3(x, y, z, 'r', 'linewidth', 8) % make 3D plot of data-curve
  hold on % add to figure
  plot3(x, y, 0*z, 'b', 'linewidth', 5) % make projection of data-curve on x,y-plane
  plot3(x([end end],1),y([end end],1),z([1 end],1), ':k', 'linewidth', 2) % connect end-points of both curves
  
  Ax = gca; Ax.XColor = 'none'; Ax.YColor = 'none'; Ax.ZColor = 'none'; % hide all axes
  view([60 20]) % set viewing angle on xy-plane, while rotating around z-axis
  rotate3D(Hfig, 'mydata_rotate3D'); % this writes 100 files in subdir "frames", and deletes them after producing the output file
  % you first see a rotating Matlab-fig, where Matlab does a single rotation inside Matlab
  % then frame-pictures are written; this takes a while, see progress in Matlab's command-window
  % these frame-pictures are catenated in the animated png file that is included in a html file and continuously rotates outside Matlab
  
  % write html-file that includes the animated png-file mydata_rotate3D.png
  oid = fopen('mydata_rotate3D.html', 'w+'); % open file for reading and writing and deletes old content   
  fprintf(oid, '<!DOCTYPE html><html><body><img src="mydata_rotate3D.png" width="800px"></body></html>\n');           
  fclose(oid); close all
  
  web('mydata_rotate3D.html','-browser'); % open html-file in browser

  pause(3) % make sure that your browser has enough time to load the html before deleting it
  delete('mydata_rotate3D.html','mydata_rotate3D.png') % clean-up; edit this if you want to keep these files
  % the result of this demo is only held inside your browser; all help-files are deleted