function [rc, msd] = auto_midpoint_motion(x_mu1, y_mu1, x_mu2, y_mu2, pixel_size)
%horzcat data for easier organization
data(:,:,1) = [x_mu1,y_mu1];
data(:,:,2) = [x_mu2,y_mu2];
mid_data = (data(:,:,1) + data(:,:,2))/2;
%since midpoint fiducial means that each foci will have same
%coordinates but opposite sign, only use one marker
sub_data = data(:,:,1) - mid_data;
%% Rc calculations
%sigmas
[~,x_sig] = normfit(sub_data(:,1) - ...
    repmat(mean(sub_data(:,1)),size(sub_data(:,1))));
[~,y_sig] = normfit(sub_data(:,2) - ...
    repmat(mean(sub_data(:,2)),size(sub_data(:,2))));
x_sig_sq = x_sig^2;
y_sig_sq = y_sig^2;
mean_sig_sq = (x_sig_sq + y_sig_sq)/2;
%res_sq calculations
mean_x_res_sq = mean((sub_data(:,1) -...
    repmat(mean(sub_data(:,1)),size(sub_data(:,1)))).^2);
mean_y_res_sq = mean((sub_data(:,1) -...
    repmat(mean(sub_data(:,1)),size(sub_data(:,1)))).^2);
res_sq = mean_x_res_sq + mean_y_res_sq;
%Rc
rc_pix = (5/4)*(sqrt(2*mean_sig_sq + res_sq));
rc = rc_pix * pixel_size;
%% MSD calculations
coords_nm = sub_data(:,1:2) * pixel_size;
%calculate distances from the midpoint (which is set at origin)
%pre-allocate msd matrix
msd = zeros(length(coords_nm)-1,1);
mid_dists = sqrt(coords_nm(:,1).^2 + coords_nm(:,2).^2);
for dt = 1:(length(mid_dists)-1)
    disp_sq = (mid_dists(1+dt:end) - mid_dists(1:end-dt)).^2;
    msd(dt,1) = mean(disp_sq);
end

