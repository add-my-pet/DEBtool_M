%% dirfield3
% Direction field for a user-defined set of ode's for 2 variables. 


%%
function f = dirfield3(nm, x, y, z, d)
  % created by Bas Kooijman 2000/01/30
  
  %% Syntax
  % f = <../dirfield3.m *dirfield3*> (nm, x, y, z, d)

  %% Description
  % The direction field for a user-defined set of ode's for 3 variables. 
  %
  % Input:
  %
  % * nm: name of user-defined function for [dx, dy, dz];
  %      required structure: dxyz = nm(xyz)
  % * x: nx-vector of values for x-variable
  % * y: ny-vector of values for y-variable
  % * z: nz-vector of values for z-variable
  % * d: scalar with multiplier for [dx, dy, dz]
  %
  % Output:
  %
  % * f: (nx*ny*nz, 6)- matrix with
  %       (xi, yj, zk,  xi+ d * dxi, yj + d * dyi, zk + d * dzk)
  
  %% Remarks
  % see <dirfield.m *dirfield*>

  nx = length(x); ny = length(y); nz = length(z); f = zeros(nx * ny * nz,6);
  
  for i = 1:nx
    for j = 1:ny
      for k = 1:nz
        eval(['dxyz = d * ', nm, '([x(i); y(j); z(k)]);']);
        f(k + nz * (j - 1) + nz * ny * (i - 1),:) = ...
	    [x(i), y(j), z(k), dxyz(1), dxyz(2), dxyz(3)];
      end
    end
  end