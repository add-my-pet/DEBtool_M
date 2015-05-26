function q = find_par(nm,i,f,s,p)
  %% q = find_par(nm,i,s,p)
  %% nm: string with name of function
  %% i: scalar with i index of parameter
  %% f: factor on p(i) such that p(i) < q(i) < f p(i)
  %% s: scalar with stress factor at f = 1
  %% p: vector with parameters, see r_v1, r_iso
  %% q: vector with parameters as in p, but the value of q(i) is
  %%    such that r_max|q = s * r_max|p
  
  eval(['rm = ',nm,'(p,1);']); % max spec growth rate in blank
  rs = s * rm; % max stressed spec growth rate
  q = p; % copy input to output
  nf = 10; R = zeros(nf,2); 
  fac = linspace(1, f, nf)';
  R(:,1) = p(i) * fac;
  
  for j = 1:nf % scan factor range
    q(i) = p(i) * fac(j);
    if i == 5 &  length(p) > 8 % effect on kappa -> change Lb and Lp
      q(8) = p(8) * (1 - q(5))/ (fac(j) - q(5)); % Eq (3.46) {112}
      q(9) = p(9) * (1 - q(5))/ (fac(j) - q(5)); % Eq (3.46) {112}
    end    
    eval(['R(j,2) = ',nm,'(q,1);']);
  end
  rp = rspline(R, rs); % find root using cubic spline
  [nr k] = size(rp); warn = 1;
  if f > 1
    for j = 1:nr % scan roots
      if rp(j) > p(i) & rp(j) < f * p(i) 
        q(i) = rp(j); warn = 0;
        break
      end
    end
  else
    for j = 1:nr % scan roots
      if rp(j) < p(i) && rp(j) > f * p(i) 
        q(i) = rp(j); warn = 0;
        break
      end
    end
  end
  
  if warn ~= 0
    fprintf('Warning: root outside scanned interval \n');
    q(i) = rp(1);
  end
