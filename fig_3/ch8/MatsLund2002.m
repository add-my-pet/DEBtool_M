%% fig:MatsLuns2002
%% bib:MatsLund2002					
%%    Matscheko, N. and Lundstedt, S. and Svensson, L. and Harju, M. and
%%    Tysklind, M. 2002					
%%    Environmental Toxicology and Chemistry 21: 1724 -- 1729
%%    Accumulation and elimination of 16 polycyclic aromatic compounds in
%%      the earthworm (Eisenia fetida).					
%% out:MatsLund2002

%% k_e \propto K_ow^0.5; temp 22 oC

%% PAC
%% log Kow	ke(1/d)		
PAC = [ ...
4.46979866	-0.52758621;
4.4966443	-0.53793103;
5.20805369	-0.66206897;
5.06040268	-0.69310345;
5.81208054	-1.00344828;
5.81208054	-1.04482759;
6.26845638	-1.18965517;
6.32214765	-1.18965517;
6.55033557	-1.15862069;	
6.61744966	-1.21034483;
7.00671141	-1.2];

%% PCB
%% log Kow	ke(1/d)			log Kow	ke(1/d)
PCB =[ ...
5.51677852	-0.93103448;
5.62416107	-0.96206897;
6.10738255	-1.02413793;
6.12080537	-1.07586207;
6.18791946	-1.03448276;
6.25503356	-1.09655172;
6.34899329	-1.02413793;
6.38926174	-1.14827586;
6.44295302	-1.21034483;
6.46979866	-1.18965517;
6.88590604	-1.29310345;
6.84563758	-1.46896552;
6.81879195	-1.47931034;
6.91275168	-1.42758621;
7.00671141	-1.46896552;
7.5033557	-1.47931034;
7.46308725	-1.55172414;
7.40939597	-1.54137931];

%% p = nrregr('lin05', 1, [PAC;PCB]);
p = nrregr('lin05', 1, PAC);
x = [4.4 ;6.5]; y = lin05(p(:,1), x);
%% p = nrregr('linear', [1;.5], [PAC;PCB]);
%% x = [4.4 ;6.5]; y = linear(p(:,1), x);

%% gset term postscript color solid 'Times-Roman' 40
%% gset output 'MatsLund2002.ps'

plot(PAC(:,1), PAC(:,2), '.r', PCB(:,1), PCB(:,2), '.b', x, y, 'g')
legend('PAC', 'PCB')
title('elimination rates at 22 C')


