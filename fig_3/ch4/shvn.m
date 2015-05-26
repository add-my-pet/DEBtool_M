function shvn
    Berg2007a

    gset term postscript color solid "Times-Roman" 30
    gset nokey
    gset xtics 0.002
    gset xrange [0:.011]
    gset ytics 10
    gset yrange [0:45]

 ##   gset yrange [0:.01]
    gset output "vn.ps"
    plot(data(:,2), data(:,5),"*g")
