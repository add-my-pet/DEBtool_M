function d = dist_stat(x)
% x: (n,k)-matrix with statistics; all cols have the same units
% d: (n,n)-matrix with distances

n = size(x,1); mx = sum(x,1)/ n; % mean value of statistics
x = x ./ (ones(n,1) * mx);       % remove units
d = zeros(n,n);                  % initiate output
for i = 1:n
    for j = (i+1):n
        D = x(i,:) - x(j,:); 
        d(i,j) = sqrt(D * D'); 
        d(j,i) = d(i,j);
    end
end