  %% mydata_rotate3D
  % demo that produces an animated png picture in 3D; it rotates when openend in a browser, such as Firefox
  % Assumes that operating system can find by the open-source animated png-assembler apngasm-2.91-bin-win64.exe
  % this app is ran outside Matlab 
  
  close all
  z = linspace(1,10,500)'; y = z.*cos(z); x = z.*sin(z); % set data
  
  Hfig = figure;
  plot3(x, y, z, 'r', 'linewidth', 3) % make 3D plot
  hold on
  plot3(x, y, 0*z, 'b', 'linewidth', 3) % make 3D plot
  
  set(Hfig,'units','centimeters', 'position',[2,2,20,20])        
  view([60 20]) % set viewing angle on xy-plane, while rotating around z-axis
  rotate3D(Hfig, 'mydata_rotate3D'); % this writes 100 files in subdir "frames", and deletes them after producing output file
  % you first see a rotating Matlab-fig, where Matlab does the rotation
  % then frame-pictures are written; this takes a while, see progress in Matlab's command-window
  % these frame-pictures are then catenated in the animated png file
  
  % write html-file that includes the animated png-file
  oid = fopen('mydata_rotate3D.html', 'w+'); % open file for reading and writing and deletes old content   
  fprintf(oid, '<!DOCTYPE html><html><body><img src="mydata_rotate3D.png" width="550px"></body></html>\n');           
  fclose(oid);
  web('mydata_rotate3D.html','-browser'); % open browser

  pause(3) % edit this if you want to keep these files
  delete('mydata_rotate3D.html','mydata_rotate3D.png')