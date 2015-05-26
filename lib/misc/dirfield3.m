function f = dirfield3(nm, x, y, z, d)
  %
  %% Input
  %  nm: name of user-defined function for [dx, dy, dz]
  %      required structure: dxyz = nm(xyz)
  %  x: nx-vector of values for x-variable
  %  y: ny-vector of values for y-variable
  %  z: nz-vector of values for z-variable
  %  d: scalar with multiplier for [dx, dy, dz]
  %
  %% Output
  %  f: (nx * ny * nz), 6- matrix with
  %       (xi, yj, zk,  xi+ d * dxi, yj + d * dyi, zk + d * dzk)
  %
  %% Remarks
  %  see dirfield

  %% Code
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