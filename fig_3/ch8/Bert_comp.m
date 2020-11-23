%% fig:Bert_comp
%% bib: tab:Bert_comp
%% out:cbert

%% von Bertalanffy growth rate as function of ultimate volume

%% lenght (mm), shape coeff, r_B(1/a), Celsius % species ref
%% miscellaneous
misc = [ ...
%% Ascomycetes (yeast)
0.00459 0.806 11830  30; % Saccharomyces carlsbergensis \cite{BergLjun82}
%% Unicellulars
0.0043  1     2891   20; % Actinophrys spec. \cite{Syng35}
2.79    0.01  832.2  23; % Amoeba proteus \cite{Pres57}
2.969   0.01  1638   17; % Paramecium caudatum \cite{SchmSyng25}
%% Ctenophora
15.04   0.702 33.27  20; % Pleurobrachia pileus \cite{Grev71}
8.851   3.90  11.61  26; % Mnemiopsis mccradyi \cite{ReevBake75}
%% Rotifera
0.240   1     193.7  20; % Asplanchna girodi \cite{RobeSalt81}
%% Cheatognata
9.431   0.15  44.80  21 ; % Sagitta hispida \cite{Reev70}
%% Echinodermata
46.10   0.70  3.913  29; % Lytechenus variegatus \cite{Kell83}
34.50   0.696 0.4590 12; % Echinocardium cordatum \cite{DuinJenn84}
36.70   0.696 0.5320 14; % Echinocardium cordatum \cite{DuinJenn84}
44.90   0.696 0.4960 16; % Echinocardium cordatum \cite{DuinJenn84}
%% Tunicata
0.829   0.520 56.56  20; % Oikopleura longicauda \cite{FenaGors83}
0.952   0.560 63.97  20];% Oikopleura dioica \cite{FenaGors83}
%% Annelida + Mollusca + Brachiopoda
moll = [ ...
14.5    1     12.04  20; % Dendrobeana veneta 
112.2   1     4.840  20; % Aplysia californica \cite{PereAdki82}
30.94   0.397 0.8116 25; % Urosalpinx cinerea \cite{Fran71}
106.5   0.543 1.121  25; % Achatina achatina \cite{Hoda82}
25.06   0.68  1.098  20; % Helix aspera \cite{DanBail82}
46.93   0.310 0.4296 17; % Patella vulgata \cite{WrigHart81}
21.92   0.716 0.6213 17; % Monodonta lineata \cite{WillKend81}
7.538   1     4.879  25; % Biomphalaria pfeifferi \cite{Meul72}
15.37   1     10.81  20; % Lymnaea stagnalis \cite{Slui83}
9.888   1     3.316  16; % Helicella virgata \cite{Pome69}
21.57   0.423 3.00   11; % Macoma baltica \cite{Gilb73}
29.24   0.558 2.221  30; % Cerastoderma glaucum \cite{Ivel79}
37.76   0.471 0.1961 13; % Venus striatula \cite{Anse61}
142.2   0.187 0.5830 17; % Ensis directus \cite{SwenLeop85}
95.92   0.394 0.1045 17; % Mytilus edulis \cite{RodhRode84}
162.3   0.388 0.1671 18; % Placopecten magellanicus \cite{MacDThom85}
191.2   0.394 0.3555 17; % Perna canaliculus \cite{Hick79}
74.62   2.05  0.1331 20; % Hyridella menziesi \cite{Jame85}
91.31   0.407 0.1866 17; % Mya arenaria \cite{Brou79}
455.3   0.398 0.4201 17; % Loligo pealei \cite{Summ71}
918.2   0.398 0.2122 17; % Loligo pealei \cite{Summ71}
48.39   0.640 0.3140 17];% Terebratalia transversa \cite{Pain69}
%% Crustacea
crus = [ ...
2.366   0.526 44.25  20; % Daphnia pulex \cite{Rich58}
2.951   0.520 61.32  25; % Daphnia longispina \cite{InglWood37}
5.136   0.526 35.04  20; % Daphnia  magna \cite{Kooy86}
2.813   0.526 66.80  20; % Daphnia magna \cite{Kooy86}
1.049   0.480 58.25  20; % Daphnia cucullata \cite{Vijv80}
1.717   0.520 47.52  20; % Daphnia hyalina \cite{Vijv80}
0.7503  0.520 39.89  20; % Ceriodaphnia pulchella \cite{Vijv80}
1.038   0.520 49.28  20; % Ceriodaphnia reticulata \cite{Kooy86}
0.4115  0.560 52.63  20; % Chydorus sphaericus \cite{Vijv80}
1.380   0.520 46.50  20; % Diaphanosoma brachyurum \cite{Vijv80}
8.632   0.300 26.96  20; % Leptodora kindtii \cite{Vijv80}
0.5289  0.520 38.73  20; % Bosmina longirostris \cite{Vijv80}
0.4938  0.520 66.90  20; % Bosmina coregoni \cite{Vijv80}
6.295   0.215 8.863  12; % Calanus pacificus \cite{OtaLand84}
11.02   0.635 1.025  18; % Dissodactylus primitivus \cite{PohlTelf82}
9.013   0.635 1.362  18; % Dissodactylus primitivus \cite{PohlTelf82}
12.91   0.197 1.008  10; % Euphasia pacifica \cite{MaucFish69}
186.6   0.939 0.05543 10;% Homarus vulgaris \cite{Hewe74}
9.707   1     0.2711 18; % Cancer pagurus \cite{Benn74}
115.6   1     0.3513 18; % Cancer pagurus \cite{Benn74}
25.73   0.882 0.4795 17; % Dichelopandalus bonnieri \cite{AlAdBowe77}
4.355   1     3.300  15; % Gammarus pulex \cite{SutcCarr81}
4.089   1     2.218  15; % Gammarus pulex \cite{SutcCarr81}
15.27   0.262 13.52  15];% Calliopius laeviusculus \cite{Dagg76}
%% Uniramia
unir = [ ...
3.903   0.351 6.600  20; % Tomocerus minor \cite{JoosVelt70}
3.652   0.351 4.948  20; % Orchesella cincta \cite{JoosVelt70}
3.034   0.351 6.52   20; % Isotomata viridis \cite{JoosVelt70}
1.981   0.351 3.416  20; % Entomobrya nivalis \cite{JoosVelt70}
1.181   0.351 9.840  20; % Lepidocyrtus cyaneus \cite{JoosVelt70}
1.281   1     6.817  20; % Orchesella cincta \cite{Jans85}
1.745   1     2.388   4; % Phaenopsectra coracina \cite{Aaga82}
2.782   1     6.328  20; % Diura nanseni \cite{Baek81}
1.024   1     2.493  20; % Capnia pygmaea \cite{Baek81}
10.82   1     44.82  36; % Locusta migratoria \cite{LougTobe69}
4.053   1     21.88  15; % Chironomus plumosus \cite{IneiRies79}
3.211   1     52.74  15];% Chironomus plumosus \cite{IneiRies79}
%% Chondrichthyes
chon = [ ...
695.9   0.184 0.1874 17; % Raja montaqui \cite{Hold72}
1589    0.184 0.1018 17; % Raja brachyura \cite{Hold72}
1303    0.184 0.0163 17; % Raja clavata \cite{Hold72}
952.7   0.184 0.1557 17; % Raja clavata \cite{Hold72}
542.9   0.184 0.2787 19; % Raja erincea \cite{RichMerr63}
4230    0.165 0.1100 18];% Prionace glauca \cite{Stev75}
%% Osteichthyes
oste = [ ...
2120    0.198 0.05396 23;% Accipenser stellatus \cite{Bert38}
157.0   0.200 0.5847 17; % Clupea sprattus \cite{IlesJohn62}
397.3   0.203 0.3295 15; % Coregonus lavaretus \cite{Bage70}
385.4   0.225 0.2495 15; % Salvelinus willughbii \cite{FrosKipl80}
328.9   0.224 0.3545 15; % Salvelinus willughbii \cite{FrosKipl80}
585.8   0.216 0.4769 17; % Salmo trutta \cite{HuntJone72}
576.2   0.240 0.2921 13; % Salmo trutta \cite{Camp71}
420.2   0.240 0.4157 15; % Salmo trutta \cite{Crai82}
155.2   1     0.9546 16; % Oncorhynchus tschawytscha \cite{CadwEden81}
459.6   0.240 0.4656 15; % Thymallus thymallus \cite{Hell69}
948.7   0.209 0.2101 15; % Esox lucius \cite{BregKenn80}
703.6   0.209 0.4016 15; % Esox lusius \cite{BregKenn80}
2091    0.199 0.04503 15;% Esox masquinongy \cite{Muir60}
441.6   0.258 0.1661 15; % Rutilus rutilus \cite{CragJone69}
252.6   0.258 0.3329 15; % Leuciscus leuciscus \cite{CragJone69}
1036    0.206 0.1265 30; % Barbus grypus \cite{AlHaAlMe81}
546.0   0.225 0.1142 15; % Abramis brama \cite{Gold81}
61.72   0.250 0.9366 25; % Gambusia holbrookii \cite{Fran53}
50.58   0.252 1.667  21; % Poecilia reticulata \cite{Ursi67}
1265    0.222 0.2075 12; % Merluccius merluccius \cite{Bage54}
1009    0.193 0.09768 15;% Lota lota \cite{Hews55}
898.6   0.222 0.08626 12;% Gadus merlangus \cite{Bowe54}
772.8   0.222 0.08626 12;% Gadus merlangus \cite{Bowe54}
1089    0.222 0.1308 10; % Gadus morhua \cite{Kohl64}
106.5   1     0.2000 17; % Gadus aeglefinus \cite{BeveHolt57}
124.0   0.238 1.091  18; % Atherina presbyter \cite{TurnBamb81}
52.41   0.250 1.019  17; % Gasterosteus aculeatus \cite{JoneHyne50}
41.28   0.200 1.777  17; % Pungitius pungitius \cite{JoneHyne50}
232.8   0.243 0.5047 30; % Nemipterus marginatus \cite{PaulMart80}
509.2   0.258 0.0717 17; % Labrus bergylta \cite{DippBrid77}
152.1   0.319 0.3350 22; % Ellerkeldia huntii \cite{Jone80}
61.86   1     0.1415 15; % Lepomis gibbosus \cite{Mitt84}
71.62   1     0.1292 15; % Lepomis macrochirus \cite{Mitt84}
317.9   0.250 0.1615 14; % Perca fluviatilis \cite{ShafMait71}
129.6   1     3.542  37; % Tilapia species \cite{LoyaFish69}
746.3   0.258 0.1758 27; % Liza vaigiensis \cite{GranSpai75c}
595.0   0.258 0.3350 27; % Mugil cephalus \cite{GranSpai75}
635.3   0.258 0.2725 27; % Valamugil seheli \cite{GranSpai75}
1373    0.231 0.1155 20; % Seriola dorsalis \cite{Baxt60}
140.9   0.147 0.7305 18; % Ammodytes tobianus \cite{Reay73}
2745    0.266 0.1481 30; % Thunnus albacares \cite{NoseHiya65}
3689    0.266 0.06623 17;% Thunnus thynnus \cite{Tiew57}
69.55   0.250 0.4011 18; % Coryphoblennius galerita \cite{Milt83}
48.80   0.252 2.466  14; % Pomatoschistus norvegicus \cite{GibsEzzi81}
154.9   0.250 0.7519 17; % Gobio gobio \cite{Mann80}
174.8   0.250 0.4165 17; % Gobio gobio \cite{KennFitz72}
213.9   0.295 0.2082 18; % Gobius cobitis \cite{Gibs70}
79.89   0.200 0.4790 17; % Gobius paganellus \cite{Mill61}
65.82   0.252 0.5628 12; % Lesueurigobius friesii \cite{Nash82}
63.72   0.252 0.6826 14; % Lesueurigobius friesii \cite{GibsEzzi78}
150.5   0.250 0.2464 18; % Blennius pholis \cite{Milt83}
93.55   0.200 0.4544 14; % Arnoglossus laterna \cite{GibsEzzi80}
632.7   1     0.04797 14; % Hypoglossus hypoglossus \cite{Sout62}
669.4   0.266 0.2165  14; % Scophthalmus maximus \cite{Jone72}
495.3   0.272 0.3247  14; % Scophthalmus maximus \cite{Jone72}
142.1   1     0.0950 17; % Pleuronectes platessa \cite{BeveHolt57}
78.41   1     0.4200 17];% Solea vulgaris \cite{BeveHolt57}
%% Amphibia
amph = [ ...
12.79   1     15.75  33; % Rana tigrina \cite{DashHota80}
8.201   1     30.97  26; % Rana sylvatica \cite{Wilb77}
26.40   0.353 3.960  14; % Triturus vulgaris \cite{Dolm83}
40.40   0.353 4.080  14];% Triturus cristatus \cite{Dolm83}
%% Reptilia
rept = [ ...
182.1   0.500 0.2707 22;  % Emys orbicularis \cite{Comf79}
161.8   0.500 0.3453 22;  % Emys orbicularis \cite{Comf79}
539.0   0.075 0.3734 20;  % Vipera berus \cite{From69}
3283    0.075 0.2552 20;  % Eunectes notaeus \cite{Petz84}
2946    0.075 0.2030 20]; % Eunectes notaeus \cite{Petz84}
%% Aves
aves = [ ...
114.7   1     15.60  39.5; % Eudyptula minor nov. \cite{Kins60}
191.8   1     15.31  39.5; % Pygoscelis papua \cite{VolkTriv80}
163.6   1     16.88  39.5; % Pygoscelis antarctica \cite{VolkTriv80}
159.9   1     15.47  39.5; % Pygoscelis adeliae \cite{VolkTriv80}
188.7   1     14.32  39.5; % Pygoscelis adeliae \cite{Tayl62}
250.0   1     8.508  39.5; % Aptenodytes patagonicus \cite{Ston60}
63.16   1     62.96  39.5; % Pterodroma cahow \cite{Wing72}
79.2    1     20.08  39.5; % Pterodroma phaeopygia \cite{Harr70}
83.90   1     41.55  39;   % Puffinus puffinus \cite{Broo90}
229.1   1     5.541  39.5; % Diomedea exulans \cite{Tick68}
41.53   1     26.37  39.5; % Oceanodroma leucorhoa \cite{RickWhit80}
44.73   1     23.28  39.5; % Oceanodroma furcata \cite{BoerWhee80}
149.5   1     18.18  39.5; % Phalacrocorax auritus \cite{Dunn75}
101.1   1     13.03  39.5; % Phaethon rubricaudata \cite{Diam74}
72.79   1     18.77  39.5; % Phaethon lepturus \cite{Diam74}
80.01   1     11.82  39.5; % Sula sula \cite{Diam74}
172.7   1     12.41  39.5; % Sula bassana \cite{Nels78}
158.0   1     18.36  39.5; % Cionia cionia \cite{Creu85}
116.8   1     11.31  39.5; % Phoeniconaias minor \cite{Berr75}
68.19   1     42.63  39.5; % Florida caerulea  \cite{Wers79}
117.3   1     17.75  39.5; % Anas platyrhynchos \cite{Hetz83}
151.3   1     17.04  39.5; % Anas platyrhynchos \cite{Hetz83}
145.5   1     10.26  39.5; % Anas platyrhynchos \cite{MilbHend37}
154.8   1     13.14  39.5; % Anas platyrhynchos \cite{Rudo78}
181.5   1     7.895  39.5; % Anser anser \cite{MilbHend37}
103.7   1     27.57  39.5; % Buteo buteo \cite{PoppVos82}
95.99   1     27.90  39.5; % Buteo buteo \cite{PoppVos82}
66.16   1     46.77  39.5; % Falco subbuteo \cite{Bijl80}
256.1   1     4.340  39.5; % Meleagris gallopavo \cite{ClayNixe78}
296.2   1     3.657  39.5; % Meleagris gallopavo \cite{ClayNixe78}
100.3   1     6.610  39.5; % Phasianus colchicus \cite{MilbHend37}
118.8   1     5.004  39.5; % Phasianus colchicus \cite{MilbHend37}
136.5   1     4.625  39.5; % Gallus domesticus \cite{Park82}
153.5   1     4.522  39.5; % Gallus domesticus \cite{Park82}
85.17   1     7.807  39.5; % Bonasia bonasia \cite{BergKlau78}
56.90   1     10.81  39.5; % Colinus virginianus \cite{RoseKlim71}
55.41   1     14.94  39.5; % Coturnix coturnix \cite{BrisTall73}
51.66   1     14.45  39.5; % Rallus aquaticus \cite{Sigm58}
67.05   1     20.00  39.5; % Gallinula chloropus \cite{Engl83}
47.41   1     39.46  39.5; % Philomachus pugnax \cite{ScheStie85}
59.94   1     29.09  39.5; % Philomachus pugnax \cite{ScheStie85}
103.4   1     10.63  39.5; % Haematopus moquini \cite{Hock84}
42.76   1     66.39  39.5; % Chlidonias leucopterus \cite{Kapo79}
57.94   1     22.21  39.5; % Sterna fuscata \cite{Brow76}
50.15   1     33.97  39.5; % Sterna dougalli \cite{LeCrColl72}
46.74   1     35.29  39.5; % Sterna hirundo \cite{LeCrColl72}
76.07   1     32.98  39.5; % Rissa tridactyla \cite{MaunThre72}
115.1   1     16.53  39.5; % Larus argentatus \cite{Spaa71}
131.3   1     17.42  39.5; % Catharacta skua \cite{Ston56}
100.5   1     40.69  39;   % Catharacta skua \cite{Furn87}
104.8   1     60.29  39;   % Catharacta maccormicki \cite{Furn87}
83.90   1     41.55  30;   % Stercorarius longicaudus  \cite{Furn87}
59.66   1     23.73  39.5; % Ptychoramphus aleuticus \cite{Verm81}
45.49   1     49.29  39.5; % Cuculus canoris \cite{Wyll81}
50.26   1     38.56  39.5; % Cuculus canoris \cite{Wyll81}
52.02   1     42.11  39.5; % Cuculus canoris \cite{Wyll81}
52.44   1     39.91  39.5; % Cuculus canoris \cite{Wyll81}
42.36   1     46.98  39.5; % Glaucidium passerinum \cite{Scho80}
41.86   1     41.57  39.5; % Glaucidium passerinum \cite{Scho80}
64.94   1     36.54  39.5; % Asio otus \cite{Wijn84}
68.25   1     21.68  39.5; % Tyto alba \cite{Groo83}
98.26   1     16.43  39.5; % Strix nebulosa \cite{Mikk81}
94.59   1     12.96  39.5; % Steatornis capensis \cite{Snow61}
37.44   1     45.55  39.5; % Apus apus \cite{Weit83}
16.33   1     58.44  33;   % Selasphorus rufus \cite{Cons80}
16.12   1     69.86  33;   % Amazilia fimbriata \cite{Have52}
70.11   1     28.52  39.5  ; % Ramphastos dicolorus \cite{Breh69}
40.83   1     82.71  41;   % Sturnus vulgaris \cite{West73}
34.16   1     73.37  41;   % Bombycilla cedrorum \cite{Rick68}
31.19   1     69.64  41;   % Petrochelidon pyrrhonota \cite{Rick68}
36.62   1     49.82  41;   % Toxostoma curvirostre \cite{Rick68}
35.53   1     59.43  41;   % Tyrannus tyrannus \cite{Murp83}
25.59   1     108.2  41;   % Sylvia atricapilla \cite{Bert76}
52.34   1     39.82  41;   % Garrulus glandarius \cite{Keve85}
32.79   1     65.85  41;   % Campylorhynchus brunneicap. \cite{Rick75}
25.88   1     138.7  41;   % Emberiza schoeniclus \cite{Blum82}
22.29   1     105.9  41;   % Troglodytes aedon \cite{Arms55}
22.41   1     76.78  41;   % Phylloscopus trochilus \cite{Scho82}
27.47   1     59.90  41;   % Parus major \cite{Bale73}
23.40   1     75.74  41;   % Parus ater \cite{Lohr77}
9.910   2.913 55.19  41;   % Motacilla flava \cite{DittDitt84}
35.94   1     75.16  41;   % Agelaius phoeniceus \cite{CronThom80}
40.66   1     65.28  41;   % Agelaius phoeniceus \cite{CronThom80}
44.84   1     49.68  41;   % Gymnorhinus cyanocephalus \cite{BateBald73}
30.81   1     75.98  41];  % Eremophila alpestris \cite{BeasFran83}
%% Mammalia
mamm = [ ...
148.6   1     2.736  35.5; % Macropus parma \cite{Mayn76}
261.6   1     2.397  35.5; % Macropus fuliginosus \cite{Pool76}
137.8   1     1.754  35.5; % Trichosurus caninus \cite{How76}
139.3   1     3.715  35.5; % Trichosurus vulpecula \cite{Lyne64}
100.5   0.961 4.743  35.5; % Perameles nasuta \cite{Lyne64}
116.6   1     1.728  35.5; % Setonix brachyurus \cite{Tynd73}
26.58   1     30.92  37; % Suncus murinus \cite{Dryd68}
29.88   1     20.64  37; % Suncus murinus \cite{Dryd68}
65.00   0.294 32.97  36; % Sorex minutus \cite{Hutt76}
30.68   1     8.775  35.5; % Desmodus rotundus \cite{Schm78}
1648    0.244 0.1490 37; % Homo sapiens \cite{Came84}
148.3   1     5.034  37; % Lepus europaeus \cite{Broe82}
116.6   1     6.507  37; % Oryctolagus cuniculus \cite{Tynd73}
27.09   1     21.54  38; % Notomys mitchellii \cite{Cric74}
23.85   1     23.94  38; % Notomys cervinus \cite{Cric74}
27.43   1     20.03  38; % Notomys alexis \cite{Cric74}
24.88   1     13.00  38; % Pseudomys novaehollandiae \cite{Kemp76}
234.4   1     5.117  38; % Castor canadensis \cite{AlekCowa69}
34.24   1     15.09  38; % Mus musculus \cite{Park82}
31.87   1     22.33  38; % Mus musculus \cite{Park82}
33.98   1     26.66  38; % Mus musculus \cite{Park82}
171.5   0.280 9.333  38; % Rattus fuscipes \cite{TaylHorn71}
75.23   1     9.286  38; % Rattus norvegicus \cite{Park82}
64.87   1     8.231  38; % Tachyoryctes splendens \cite{Rahm80}
37810   0.188 0.05884 37; % Balaenoptera musculus \cite{Smal71}
26200   0.188 0.2240 37; % Balaenoptera musculus \cite{Lock81}
25000   0.188 0.2160 37; % Balaenoptera musculus \cite{Lock81}
22250   0.180 0.2220 37; % Balaenoptera physalus \cite{Lock81}
21000   0.180 0.2221 37; % Balaenoptera physalus \cite{Lock81}
15300   0.197 0.1337 37; % Balaenoptera borealis \cite{Lock81}
14800   0.197 0.1454 37; % Balaenoptera borealis \cite{Lock81}
3056    0.254 0.2700 37; % Delphinapterus leucas \cite{Gewa76}
3589    0.254 0.1876 37; % Delphinapterus leucas \cite{Gewa76}
387.2   1     4.168  37; % Canis domesticus \cite{Park82}
178.1   1     2.870  37; % Lutra lutra \cite{Step57}
197.7   1     2.692  37; % Lutra lutra \cite{Step57}
486.4   1     0.4787 37; % Pagaphilus groenlandicus \cite{LaviBarc81}
5580    0.254 0.1492 37; % Mirounga leonina  \cite{Laws53}
2933    0.254 0.3094 37; % Mirounga leonina \cite{Laws53}
1799    1     0.1185 37; % Mirounga leonina \cite{Bryd69}
704.0   1     0.3661 37; % Mirounga leonina \cite{Bryd69}
685.4   1     0.3001 37; % Leptonychotes weddelli \cite{Bryd69}
1392    1     0.1016 37; % Loxodonta a.africana \cite{Laws66}
1723    1     0.07173 37; % Loxodonta a.africana \cite{Laws66}
470.2   1     1.263  37; % Rangifer tarandus \cite{McEw68}
534.4   1     1.000  37; % Rangifer tarandus \cite{McEw68}
815.4   1     0.9957 38.5; % Bos domesticus \cite{Park82}
712.6   1     0.5930 37]; % Alces alces \cite{HeptNasi74}

%% correction for differences in shape
Misc = misc(:,[1 3]); Misc(:,1) = Misc(:,1) .* misc(:,2); lMisc = log10(Misc); 
Moll = moll(:,[1 3]); Moll(:,1) = Moll(:,1) .* moll(:,2); lMoll = log10(Moll); 
Crus = crus(:,[1 3]); Crus(:,1) = Crus(:,1) .* crus(:,2); lCrus = log10(Crus); 
Unir = unir(:,[1 3]); Unir(:,1) = Unir(:,1) .* unir(:,2); lUnir = log10(Unir); 
Chon = chon(:,[1 3]); Chon(:,1) = Chon(:,1) .* chon(:,2); lChon = log10(Chon); 
Oste = oste(:,[1 3]); Oste(:,1) = Oste(:,1) .* oste(:,2); lOste = log10(Oste); 
Amph = amph(:,[1 3]); Amph(:,1) = Amph(:,1) .* amph(:,2); lAmph = log10(Amph); 
Rept = rept(:,[1 3]); Rept(:,1) = Rept(:,1) .* rept(:,2); lRept = log10(Rept); 
Aves = aves(:,[1 3]); Aves(:,1) = Aves(:,1) .* aves(:,2); lAves = log10(Aves); 
Mamm = mamm(:,[1 3]); Mamm(:,1) = Mamm(:,1) .* mamm(:,2); lMamm = log10(Mamm); 

%% remove unicellulars
lMisc(1:4,:) = []; misc(1:4,:) = [];

%% expected relationship
TA = 8000; T1 = 20+273; 
kM =20; %% 1/a, mean maintenance rate coefficient at T1 (value uncertain)
v = 80; %% mm/a, mean energy conductance at T1
L = 10 .^ linspace(-1, 4, 100)';
rB = 1 ./ (3/ kM + 3 * L/ v); er = log10([L, rB]);

kM =400; %% 1/a, mean maintenance rate coefficient at T1 (value uncertain)
rB = 1 ./ (3/ kM + 3 * L/ v); er1 = log10([L, rB]);

%% gset term postscript color solid "Times-Roman" 35

subplot(1,2,1);
%% gset output "cberta.ps"
plot(lMisc(:,1), lMisc(:,2), '.r', ...
     lMoll(:,1), lMoll(:,2), '.g', ... 
     lCrus(:,1), lCrus(:,2), '.b', ...
     lUnir(:,1), lUnir(:,2), '.m', ...
     lChon(:,1), lChon(:,2), '.c', ...
     lOste(:,1), lOste(:,2), '.y', ...
     lAmph(:,1), lAmph(:,2), '.k', ... 
     lRept(:,1), lRept(:,2), '+r', ...
     lAves(:,1), lAves(:,2), '+g', ...
     lMamm(:,1), lMamm(:,2), '+b')
legend('miscellaneous', 'mollusca', 'crustacea', 'uniramia', 'chondrichthyes', ...
    'osteichthyes', 'amphibia', 'reptilia', 'aves', 'mammalia');
title('not corrected for temperature')
xlabel('log body length, mm')
ylabel('log van Bert growth rate, 1/a')

subplot(1,2,2);
%% gset output "cbert.ps"

%% correction for difference in temperature, cf (2.20) {53}
lMisc(:,2) = lMisc(:,2) -  TA/T1 + TA ./ (273 + misc(:,4));
lMoll(:,2) = lMoll(:,2) -  TA/T1 + TA ./ (273 + moll(:,4));
lCrus(:,2) = lCrus(:,2) -  TA/T1 + TA ./ (273 + crus(:,4));
lUnir(:,2) = lUnir(:,2) -  TA/T1 + TA ./ (273 + unir(:,4));
lChon(:,2) = lChon(:,2) -  TA/T1 + TA ./ (273 + chon(:,4));
lOste(:,2) = lOste(:,2) -  TA/T1 + TA ./ (273 + oste(:,4));
lAmph(:,2) = lAmph(:,2) -  TA/T1 + TA ./ (273 + amph(:,4));
lRept(:,2) = lRept(:,2) -  TA/T1 + TA ./ (273 + rept(:,4));
lAves(:,2) = lAves(:,2) -  TA/T1 + TA ./ (273 + aves(:,4));
lMamm(:,2) = lMamm(:,2) -  TA/T1 + TA ./ (273 + mamm(:,4));

plot(lMisc(:,1), lMisc(:,2), '.r', ...
     lMoll(:,1), lMoll(:,2), '.g', ... 
     lCrus(:,1), lCrus(:,2), '.b', ...
     lUnir(:,1), lUnir(:,2), '.m', ...
     lChon(:,1), lChon(:,2), '.c', ...
     lOste(:,1), lOste(:,2), '.y', ...
     lAmph(:,1), lAmph(:,2), '.k', ... 
     lRept(:,1), lRept(:,2), '+r', ...
     lAves(:,1), lAves(:,2), '+g', ...
     lMamm(:,1), lMamm(:,2), '+b', ...
     er(:,1), er(:,2), '-r', ...
     er1(:,1), er1(:,2), '-g')
legend('miscellaneous', 'mollusca', 'crustacea', 'uniramia', 'chondrichthyes', ...
    'osteichthyes', 'amphibia', 'reptilia', 'aves', 'mammalia');
title ('corrected for temperature = 25 C')
xlabel ('log body length, mm')
ylabel ('log van Bert growth rate, 1/a')