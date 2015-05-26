## Type 1 methanotrophy: Ch4 is energy and carbon source

## biomass composition
nHE = 1.8; nOE = .3; nNE = .3; # reserve
nHV = 1.8; nOV = .5; nNV = .1; # structure

## X: CH4
## C: CO2
## H: H2O
## O: O2
## N: NH3
## E: reserve
## V: structure

##   X C H O N E   V
n = [1 1 0 0 0 1   1;   # C
     4 0 2 0 3 nHE nHV; # H
     0 2 1 2 0 nOE nOV; # O
     0 0 0 0 1 nNE nNV];# N

YA_NX = -nNE;
YA_HX = 2 - (3 * YA_NX + nHE)/ 2;
YA_OX = (-YA_HX - nOE)/2;
YM_HE = (-3 * nNE + nHE)/ 2;
YM_OE = -1 + (nOE - YM_HE)/ 2;
YG_NE = nNE - nNV;
YG_HE = (nHE - nHV - 3 * YG_NE)/ 2;
YG_OE = (nOE - nOV - YG_HE)/ 2;

##    X C H      O     N      E V
Y = [-1 1 2     -2     0      0 0;  # assim: cat
     -1 0 YA_HX  YA_OX YA_NX  1 0;  # assim: ana
      0 1 YM_HE  YM_OE nNE   -1 0;  # maint
      0 1 YM_HE  YM_OE nNE   -1 0;  # growth: cat
      0 0 YG_HE  YG_OE YG_NE -1 1]';# growth: ana
## notice transponent!!
## n * Y # must be zero's

jEAm = 1.2; # mol/(mol.h)
kE = 2;     # 1/h
kM = .01;   # 1/h
yEX = 0.8; yXE = 1/yEX; # mol/mol
yVE = 0.8; yEV = 1/yVE; # mol/mol

jEM = yEV * kM;
rm = (jEAm - jEM)/ (jEAm/ kE + yEV);

nr = 100; r = linspace(0,rm,nr);

mE = yEV * (r + kM) ./ (kE - r);
jEA = kE * mE;
jEG = r * yEV;
jEM = ones(1,nr) * kM * yEV;

k = [(yXE - 1) * jEA; jEA; jEM; (1 - yVE) * jEG; yVE * jEG];
j = Y * k;
r = r/rm;

gset term postscript color solid "Times-Roman" 30

gset nokey
gset xrange[0:1]
gset yrange[-2:0.6]
gset xtics .2
gset ytics 1
gset output "methanotrophy_1.ps"

plot(r, j(1,:), "m",\ # X
     r, j(2,:), "k",\ # C
     r, j(4,:), "r",\ # O
     r, j(5,:), "b",\ # N
     r, j(6,:), "g",\ # E
     [0;1], [0;0], "k")


gset yrange[-.5:1]
gset ytics .5
gset output "methanotrophy_2.ps"
plot(r, j(1,:)./j(4,:), "m", \ # X/O
     r, j(5,:)./j(4,:), "b", \ # N/O
     r, j(2,:)./j(4,:), "k", \ # C/O
     [0;1], [0;0],"k")
