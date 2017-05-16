function f = gaussian2D(pars, cords), 

xi = cords(1, :);
yi = cords(2, :);


center_x = pars(1);
center_y = pars(2);
theta = pars(3); 
g_mean = pars(4); 
sigma_x = pars(5);
sigma_y = pars(6);
scale = pars(7); 


dx = (xi - center_x);
dy = (yi - center_y);
x = dx*cos(theta) - dy*sin(theta);
y = dx*sin(theta) + dy*cos(theta);


exp_x = exp(-0.5*x.*x/(sigma_x*sigma_x));
exp_y = exp(-0.5*y.*y/(sigma_y*sigma_y));
f = g_mean + scale*exp_x.*exp_y;


