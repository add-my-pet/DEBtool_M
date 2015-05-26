function lim_tb
global ab_get_tb xb_get_tb

lb = .01; y = zeros(1000,1);
  
for i = 1:1000
    g = i;
    xb_get_tb = g/ (1 + g);
    ab_get_tb = 3 * g * xb_get_tb^(1/3)/ lb;
    y(i) = quad(@dget_tb, 1e-8, xb_get_tb);
end
    plot(1:1000,y,'r')
    y(1000)
    
end

