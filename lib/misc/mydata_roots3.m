%% test root finder root3

%% A = rand(1,1); a = [1, -3*A, 3*A^2, -A^3]';
%% r = roots3(a,0); % get (all) roots
%% [r, a(1)*r.^3 + a(2)*r.^2 + a(3)*r + a(4)*r.^0]
%% return

%% A = 10*rand(3,1); A(1) = A(3);
%% a = [1, -sum(A), A(1)*A(2) + A(1)*A(3) + A(2)*A(3), -prod(A)]';
a = [1.0000  -17.2034   78.9388  -41.8331]';
r = roots3_n(a,1); % get (all) roots
a'
[r, a(1)*r.^3 + a(2)*r.^2 + a(3)*r + a(4)*r.^0]
return

a = 10 * rand(4,1); % generate randomly cubic polynomial coefficient
r = roots3(a); % get (all) roots
%% r = roots3(a,-1); % get imaginary roots
%% r = roots3(a,1); % get real roots

%% give roots and polynomial evaluations
%% the second column must be zeros 
[r, a(1)*r.^3 + a(2)*r.^2 + a(3)*r + a(4)*r.^0]

a = [1.00000  -0.86833  -1.25667  -0.10884]';
r = roots3(a,1); % get real roots
[r, a(1)*r.^3 + a(2)*r.^2 + a(3)*r + a(4)*r.^0]
r = roots(a); % get real roots
[r, a(1)*r.^3 + a(2)*r.^2 + a(3)*r + a(4)*r.^0]
