%% fig:altri_troglodytes
%% bib:Kend40
%% out:kend40w kend40o
%% Troglodytes aedon: wet weight and carbon dioxide production at age

aW_Ta = [2 0.01178 10;
	 4 0.1028  10;
	 7 0.383   10;
	10 0.8679  10;
	12 1.5003  10];

aCO2_Ta = [2   0.83 5;
	   4   2.88 4;
	   7  10.56 2;
	  10  19.44 4;
	  12  31.44 5];

%% we must have decreasing times for embryo-data fitting
aW_Ta = aW_Ta(5:-1:1,:); aCO2_Ta = aCO2_Ta(5:-1:1,:);
