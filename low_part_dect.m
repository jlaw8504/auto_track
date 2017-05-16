function [coords1,coords2] = low_part_dect(im,scale,step_num,pixel_size,step_size);
%% Run lowpass filtering on the image
im_lowpass = denoise_fft(im,scale);

%% Create intensity distance from brightest pixel matrix
%find max pixel of single stack timepoint

for i = 1:(size(im_lowpass,3)/step_num)
    %isolate a single stack from timelapse and run variance_area on single
    %z-stack, function will highlight areas surrouned by high variance
    im_stk = im_lowpass(:,:,(step_num*(i-1))+1:step_num*i);
    %find max voxel in stack
    [max1_int,max1_idx] = max(im_stk(:));
    [row(i,1),col(i,1),plane(i,1)] = ind2sub(size(im_stk),max1_idx);
    %initially set row2,col2,and plane2 to row,col,and plane for 1st
    %iteration of while loop
    row2(i,1) = row(i,1); col2(i,1) = col(i,1); plane2(i,1) = plane(i,1);
    %set max1 to nan
    im_stk(row(i,1),col(i,1),plane(i,1)) = nan;
    while norm([row(i,1)-row2(i,1),col(i,1)-col2(i,1)]) < 5
        %calc max2
        [max2_int,max2_idx] = max(im_stk(:));
        [row2(i,1),col2(i,1),plane2(i,1)] = ind2sub(size(im_stk),max2_idx);
        im_stk(row2(i,1),col2(i,1),plane2(i,1)) = nan;
    end
    total_plane(i,1) = plane(i,1) + step_num*(i-1);
    total_plane2(i,1) = plane2(i,1) + step_num*(i-1);
end

%concatenate the row col and plane information
coords1 = [col*pixel_size,row*pixel_size,plane*step_size,total_plane];
coords2 = [col2*pixel_size,row2*pixel_size,plane2*step_size,total_plane2];
end

