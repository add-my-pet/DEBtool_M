%% this script illustrates the use of spline, ispline, rspline, knots
%% see also mydata_smooth

%% path('../../lib/misc/',path); % set path to library of DEBtool

%% generate a set of data for illustration
x = linspace(-2,2,30)'; % vector used to generate data
data = [x, exp(-x.^2) + .1 * rand(30,1)];

%% find approximating spline
X = (-2:2)'; % absissa for knots using 5 equispaced knots
x = linspace(-2.5,2.5,100)'; % absicca for spline evaluation

XY = knot(X,data); % find knot coordinates; no clamping
y = spline(x,XY); % find spline ordinates; no clamping

XYlr = knot(X,data,0,0); % find knot coordinates; double clamping at value 0
%% get spline ordinates and first three derivatives; double clamping
[ylr dylr ddylr dddylr] = spline(x,XYlr,0,0);
%% get integrated values; double clamping at value 0
ixylr = ispline(x,XYlr,0,0); 

%% find roots for level lev
lev = .9; rX = rspline(XY,0,0,lev);
%% compose plot data
rXY = [rX(1) 0; rX(1) lev; rX(2) lev; rX(2) 0];

%% plot results
subplot(1,2,1)
xy = [x,y]; xylr = [x,ylr];
plot(data(:,1), data(:,2),'.r', ...
    x, y, 'g', XY(:,1), XY(:,2),'*g', ...
    x, ylr, 'b', rXY(:,1), rXY(:,2), 'm')

subplot(1,2,2)
xy1 = [x, dylr]; xy2 = [x, ddylr]; xy3 = [x, dddylr]; xy0 = [x, ixylr];
plot(xy, ixylr, 'm', ...
    x, dylr, 'g', ...
    x, ddylr, 'r', ...
    x, dddylr, 'b')
