function [im_biased] = variance_area(im_lowpass)

for plane = 1:size(im_lowpass,3)
    %loop through entire image and find
    for row = 1:size(im_lowpass,1)
        for col = 1:size(im_lowpass,2)
            %calculate the variance of roi of gradually incrasing size
            %loop through different roi sizes
            for n = 1:2
                %parse the im_lowpass for an roi
                try
                    roi = im_lowpass(row-n:row+n,col-n:col+n,plane);
                catch
                    roi = zeros([5,5]);
                end
                var_roi(n) = var(roi(:));
            end
            var_sum(row,col) = sum(var_roi(:));
        end
    end
    %This first loop seems to genereate donuts around foci
    %repeat to try to center donuts
    i = 2; %radius of donut
    %loop through var_sum image and try to centrate donuts using sum
    for row2 = 1:size(var_sum,1)
        for col2 = 1:size(var_sum,2)
            %parse the var_sum for an roi
            try
                roi2 = var_sum(row2-i:row2+i,col2-i:col2+i);
                %multiply by matrix so only borders remain
                border_mat = zeros(i*2+1,i*2+1);
                border_mat(1,:) = 1;
                border_mat(:,1) = 1;
                border_mat(i*2+1,:) = 1;
                border_mat(:,i*2+1) = 1;
                roi2 = roi2 .* border_mat;
                
            catch
                roi2 = zeros([5,5]);
            end
            sum_roi = sum(roi2(:));
            sum_of_var(row2,col2,plane) = sum(sum_roi(:));
        end
    end
end
%normalize the sum_of_var
norm_sov = sum_of_var/max(sum_of_var(:));
im_biased = im_lowpass.*norm_sov;