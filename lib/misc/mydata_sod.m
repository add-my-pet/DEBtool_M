%% mydata_sod
% script that illustrates the use of sod: scaled outlier distances
% n random points are plotted in lava-color coding that quantify being outlier 

n = 10; % number of species
traits = rand(n,2); % trait values
d = sod(traits); % scaled outlier distances


color = color_lava(d/(1.1*max(d))); % colors for species
marker = cell(n,1); txt = cell(n,1);
 for i=1:n
   marker{i} = {'o', 8, 5, color(i,:),  color(i,:)};
   txt{i} = num2str(i);
 end
plot2i(traits, [marker, txt], 'scaled outlier distance');


