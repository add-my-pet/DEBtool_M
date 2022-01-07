%% mydata_sod
% script that illustrates the use of sod: scaled outlier distances
% n random points are plotted in lava-color coding that quantify being outlier 

close all
n = 100; % number of species
traits = [[9 9];5+randN(n-1,2)]; % add artificial outlier to random traits
d = sod(traits,[],1); % scaled outlier distances based on F_su
%d = sod(traits,[],0); % scaled outlier distances based on F_sb

color = color_lava(d/(1.1*max(d))); % colors for species
marker = cell(n,1); % txt = cell(n,1);
 for i=1:n
   marker{i} = {'o', 8, 5, color(i,:),  color(i,:)};
   %txt{i} = num2str(i);
 end
plot2i(traits, marker, 'scaled outlier distance');
