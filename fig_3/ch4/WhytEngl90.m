%% fig:WhytEngl90
%% bib:WhytEngl90
%% out:WhytEngl90

%% Whyte J.N.C., Englar J.R. and Carswell (1990). Aquaculture 90, 157-172.
%% kcal/100 g wet weight in starved oyster; time in days

tE = [ ...
        5.084	62.584;
       14.888 	63.307;
       29.603   62.041;
       59.043   57.700;
       88.166	57.519;
      117.147 	56.072;
      141.581	47.028;
      176.028 	46.667;
      205.169	42.326;
      294.332	36.537;
      395.598	22.067];

tProt = [ ...
   5.084	29.302;
  14.888	30.026;
  29.603	30.026;
  59.043	26.951;
  88.166	28.036;
 117.147	28.760;
 141.581	22.791;
 176.028	22.248;
 205.169	20.078;
 294.332	23.333;
 395.598	12.119];

tLip = [ ...
   5.084	16.279;
  14.888	15.736;
  29.603	16.641;
  59.043	14.470;
  88.166	15.375;
 117.147	15.375;
 141.581	13.385;
 176.028	13.566;
 205.169	13.566;
 294.332	13.023;
 395.598	 6.693];

tCarb = [ ...
   5.084	16.641;
  14.888	17.003;
  29.603	15.194;
  59.043	15.917;
  88.166	14.109;
 117.147	11.576;
 141.581	11.034;
 176.028	10.672;
 205.169	 8.863;
 294.332	 7.235;
 395.598	 2.713];

p = nrregr('lin4', ones(8,1), tE, tProt, tLip, tCarb);

t = [0;400];
[EE EProt ELip ECarb] = lin4(p(:,1),t,t,t,t);

%% gset term postscript color solid "Times-Roman" 35
%% gset output "WhytEngl90_fig1.ps"
%% gset nokey

%% gset xtics 100
%% gset ytics 20
plot (tE(:,1), tE(:,2), '.r', tProt(:,1), tProt(:,2), '.g', ...
    tLip(:,1), tLip(:,2), '.b', tCarb(:,1), tCarb(:,2), '.k', ...
    t, EE, 'r', t, EProt, 'g', ...
    t, ELip, 'b', t, ECarb, 'k')
legend('total energy', 'protein', 'lipid', 'carbohydrate')
xlabel('time, d')
ylabel('energy kcal/100 g wet weight')

fprintf('hit a key to proceed \n');
pause;

JCE = p([4 6 8],1) * 4.184 ./ [401; 616; 516]; JEM = sum(JCE);
MCE = JCE/ JEM;
MC0 = p([3 5 7],1) * 4.184 ./ [401; 616; 516]; MV0 = sum(MC0);
tm = MV0/JEM; t = [0; tm];
MCE = [t, [MCE'; MCE']];
MCE(:,3) = MCE(:,2) + MCE(:,3);
MCE(:,4) = MCE(:,3) + MCE(:,4);
t = linspace(0,tm,500)';
MCV = [t, (MC0(1) + t * JCE(1)) ./ (MV0 + t * JEM), ...
       (MC0(2) + t * JCE(2)) ./ (MV0 + t * JEM), ...
       (MC0(3) + t * JCE(3)) ./ (MV0 + t * JEM)];
MCV(:,3) = MCV(:,2) + MCV(:,3);
MCV(:,4) = MCV(:,3) + MCV(:,4);

%% gset term postscript color solid 'Times-Roman' 20
%% gset output 'WhytEngl90_fig2.ps'
%% gset nokey
%% gset yrange [0:1]
%% gset ytics .2
plot(MCV(:,1), MCV(:,2), 'g', ...
     MCV(:,1), MCV(:,3), 'b', ...
     MCV(:,1), MCV(:,4), 'm', ... 
     MCE(:,1), MCE(:,2), 'g', ... 
     MCE(:,1), MCE(:,3), 'b', ...
     MCE(:,1), MCE(:,4), 'm')
legend('protein', 'lipid', 'carbohydrate')
xlabel('time till reserve depletion, d')
ylabel('cumulative composition')

     
