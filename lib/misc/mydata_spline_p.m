closeplot

nt = 1000; t = (1:nt)'; % choose independent variable values
data = [t, 10 * sin(2 * pi * t/365) + randn(nt,1)]; % generate 'data'

x = [0 100 150 200 250 300 365]'; % choose knot-abcissa values

xy = knot_p(x, data); % obtain knots for periodic spline

y = spline_p(t, xy);  % obtain dependent variable values

plot(t, data(:,2), '.m', t, y, 'b')
      