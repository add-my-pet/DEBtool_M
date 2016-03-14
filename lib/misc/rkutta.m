%% rkutta
% Runge Kutta 5 integration of a set of ode's

%%
function  [tx, xt] = rkutta (fn, x0, tmax, dt)
  %  Created: 2000/10/07 by Bas Kooijman; modified 2009/09/29

  %% Syntax
  % [tx, xt] = <../rkutta.m *rkutta*> (fn, x0, tmax, dt)
  
  %% Description
  % Runge Kutta 5 integration of a set of ode's specified by 'fn' with fixed or dynamic step size.
  % Integrates user-defined system of ODE according to the Runge Kutta 5
  % Method: Press et al 1992 Numerical Recipes in C, Cambridge UP, p 716
  %
  % Input:
  %
  % * fn: string, for user-defined function of structure dx = fn (x, t)
  %
  %        dx, x are column vectors of equal lengths, t is a scalar
  %
  % * x0: column vector, value of vector x at t=0
  %
  % * tmax: scalar, max value of t, starting from t = 0
  %
  %      if tmax = Inf or if not specified:
  %      integration continues till fn(x)/x'*dt*fn(x)/x < norm
  %
  % * dt: scalar, fixed step size; If not specified: step size control 
  %
  % Output:
  %
  % * xt: matrix with times and x(t) values starting with t=0 and x0
  
  %% Remarks
  % Requires: user-defined function 'fn' 
  
  %% Example of an user definition of function:
  % Function dx = monod(x, t)
  %  dx = - 0.5 * x/ (0.1 + x);
  %% Example of use
  % rkutta("monod",1,10) or rkutta("monod",1,10,.01). 
  
  rkutta_imax = 10000; % max integration steps if stepsize adaptable
  rkutta_accuracy = 1e-10; % accuracy of integration if stepsize is adapt.
  rkutta_norm = 5e-3; % norm for criterion if integration period is Inf
  
  t = 0; i = 1; x = x0; [nx n1] = size(x0); 
 
  a = [1;0.2;0.3;0.6;1;7/8];
  b2 = 0.2; b3 = [3;9]/40; b4 = [0.3;-0.9;1.2]; b5 = [-11;135;-140;70]/54;
  b6 = [1631;175;575;44275;253]./[55296;512;13824;110592;4096];
  c = [37;0;250;125;0;512]./[378;1;621;594;1;1771];
  d = c - [2825;0;18575;13525;277;1]./[27648;1;48384;55296;14336;4];

  str = ['k1 = dt*', fn, '(x, t); ', ...
   'k2 = dt*', fn, '(x + k1*b2, t + dt*a(2)); ', ...
   'k3 = dt*', fn, '(x + [k1 k2]*b3, t + dt*a(3)); ', ... 
	 'k4 = dt*', fn, '(x + [k1 k2 k3]*b4, t + dt*a(4));', ...
	 'k5 = dt*', fn, '(x + [k1 k2 k3 k4]*b5, t + dt*a(5));', ...	 
	 'k6 = dt*', fn, '(x + [k1 k2 k3 k4 k5]*b6, t + dt*a(6));' ...
	 ];
 
 if (tmax == Inf) || (exist('tmax','var') == 0) % integrate till norm
   if exist('dt','var') == 1                   % fixed step size
     xt = x0; tx = t; crit = 1;
     while (crit > rkutta_norm) && (i <= rkutta_imax)
       eval(str);
       x = x + [k1 k2 k3 k4 k5 k6]*c;
       t = t + dt; i=i+1;
       xt = x; tx = t; 
       crit = k1./(dt*max(1e-4,x)); %  criterion is sum of squared
       crit = crit'*crit; % relative derivetives
     end
     if i >= rkutta_imax
       fprintf(['Warning: no convergence with ', ...
           num2str(rkutta_imax), ' integration steps \n']);
     end
     xt = xt';
   else                                  % adaptive step size
     xt = x; tx = t; dt = 0.01; crit = 1;
     while (crit > rkutta_norm) && (i <= rkutta_imax)
       eval(str);
       error = max(abs([k1 k2 k3 k4 k5 k6]*d));
       if error >= rkutta_accuracy
         dt = 0.9*dt*(rkutta_accuracy/error)^0.25;
       else
         dt = 0.9*dt*(rkutta_accuracy/error)^0.2;
         x = x + [k1 k2 k3 k4 k5 k6]*c;
         t = t + dt; i=i+1;
         xt = x; tx = t; 
         crit = k1./(dt*max(1e-4,x)); % criterion is sum of squared
         crit = crit'*crit; % relative derivetives
       end
     end
     if i >= rkutta_imax
       fprintf(['Warning: no convergence with ', num2str(rkutta_imax), ...
           ' integration steps \n']);
     end 
     xt = xt';
   end

 else % integrate till tmax

   if exist('dt','var') == 1                   % fixed step size
     xt = zeros(tmax/dt, nx); tx = zeros(tmax/dt, 1);
     xt(1,:) = x'; tx(1) = t;
     while t <= tmax
       eval(str);
       x = x + [k1 k2 k3 k4 k5 k6]*c;
       t = t + dt; i=i+1;
       xt(i,:) = x'; tx(i) = t; 
     end

   else                                  % adaptive step size
     xt(1,:) = x'; tx(1) = t; dt = 0.01;
     while (t <= tmax) && (i <= rkutta_imax)
       eval(str);
       error = max(abs([k1 k2 k3 k4 k5 k6]*d));
       if error >= rkutta_accuracy
         dt = 0.9*dt*(rkutta_accuracy/error)^0.25;
       else
       	 dt = 0.9*dt*(rkutta_accuracy/error)^0.2;
         x = x + [k1 k2 k3 k4 k5 k6]*c;
         t = t + dt; i=i+1;
         xt(i,:) = x'; tx(i) = t;
       end
     end
     if i >= rkutta_imax
       fprintf(['Warning: no convergence with ', num2str(rkutta_imax), ...
           ' integration steps \n']);
     end
    
   end
 end
