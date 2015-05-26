function biomass(H, XY0, XYP, XYS)
%  gset term postscript color solid 'Times-Roman' 35
%  gset output 'biomass.ps'

  plot(H, XY0(:,2), 'g', H, XYP(:,2), 'r', H, XYS(:,2), 'b')
