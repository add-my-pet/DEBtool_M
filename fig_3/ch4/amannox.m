## Amannox by Brocadia

## biomass composition
nHE = 2; nOE = .46; nNE = .25; # reserve
nHV = 2; nOV = .51; nNV = .125;# structure

## C: HCO3-
## H1: H+
## H: H2O
## S: NH3
## N: N2
## N3:NO2-
## N5: NO3-
## E: reserve
## V: structure

##  C H1 H S N N3 N5  E   V
n = [1 0 0 0 0  0  0  1   1;   # C
     1 1 2 3 0  0  0  nHE nHV; # H
     3 0 1 0 0  2  3  nOE nOV; # O
     0 0 0 1 2  1  1  nNE nNV; # N
     -1 1 0 0 0 -1 -1  0   0]; # +

YA_CS = -1/ nNE;
YA_H1S = YA_CS;
YA_HS = (3 + YA_CS * (nHE - 2))/ 2;
YA_N3S = (3 - nOE) * YA_CS + YA_HS;
YM_N3E = (-4 - nHE + 2 * nOE + 3 * nNE)/ 6;
YM_SE = nNE - YM_N3E;
YM_H1E = 1 + YM_N3E;
YM_HE = nOE - 2 * YM_N3E -3;
YG_N3E = YM_N3E - (-4 - nHV + 2 * nOV + 3 * nNV)/ 6;
YG_H1E = YG_N3E;
YG_HE = - 2 * YG_N3E + nOE - nOV;
YG_SE = -YG_N3E + nNE - nNV;

##   C    H1      H     S      N N3      N5       E     V
Y = [0    -1      2     -1     1 -1       0       0     0;  # assim: cat
     YA_CS YA_H1S YA_HS -1     0  YA_N3S -YA_N3S -YA_CS 0;  # assim: ana
     1     YM_H1E YM_HE  YM_SE 0  YM_N3E  0      -1     0;  # maint
     1     YM_H1E YM_HE  YM_SE 0  YM_N3E  0      -1     0;  # growth: cat
     0     YG_H1E YG_HE  YG_SE 0  YG_N3E  0      -1     1]';# growth: ana
## notice transponent!! ; we must have Y * n = 0

rm = .003;
kE = .0127;
kM = .000811;
ySE = 8.8;
yVE = .8; yEV = 1/yVE;

nr = 50; r = linspace(0,rm,nr);

mE = yEV * (r + kM) ./ (kE - r);
jEA = kE * mE;
jEG = r * yEV;
jEM = ones(1,nr) * kM * yEV;

k = [(ySE - nNE) * jEA; nNE * jEA; jEM; (1 - yVE) * jEG; yVE * jEG];
j = Y * k;
r = r/rm;

gset term postscript color solid "Times-Roman" 30

gset nokey
gset xrange[0:1]
gset yrange[-.07:.12]
gset xtics .2
gset ytics .05
gset output "amannox_1.ps"

plot(r',j(1,:)',"k", r', j(2,:)',"m", r', j(3,:)',"b", r', j(4,:), "r")

gset yrange[-.07:.06]
gset output "amannox_2.ps"
plot(r',j(5,:)',"m", r', j(6,:)',"b", r', j(7,:)',"r", r', j(8,:), "g")
