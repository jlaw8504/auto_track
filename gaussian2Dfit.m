function [rst, resnorm] = gaussian2Dfit(I, cxi, cyi, size, sigma)

cx = round(cxi);
cy = round(cyi);

half_size = round((size + 1)/2);
full_size = half_size * 2 + 1;

loop_flag = 1;

while loop_flag
    try
        roi = I(cy-half_size:cy+half_size, cx-half_size:cx+half_size); % crop the image
        loop_flag = 0;
    catch
        half_size = half_size - 1;
        full_size = half_size * 2 + 1;
    end
end

x = -half_size:half_size;
y = -half_size:half_size; 
my = ones(full_size,1)*x;
mx = my';
ix = reshape(mx,[1,full_size*full_size]);
iy = reshape(my,[1,full_size*full_size]);
z = reshape(roi,[1,full_size*full_size]);
data = [iy;ix];


i_mean = min(min(roi));   
scale = max(max(roi)) - i_mean; 
pars = [0 0 0 i_mean sigma sigma scale]; 



lb = [min(x), min(y), -2*pi, i_mean/2, sigma/8, sigma/8, 1]; %lower bound
ub = [max(x), max(y), 2*pi, i_mean*2, sigma*4, sigma*4, 1.5*scale + i_mean]; %upper bound


opts = optimoptions(@lsqcurvefit,'Display','off');
[rst, resnorm]=lsqcurvefit(@gaussian2D, pars, data, z, lb, ub, opts); %least square currve fitting
