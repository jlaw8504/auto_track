function [rc_array, msd_mat] = fiducial_mark_motion(s, pixel_size)

fn = fieldnames(s);
for i=1:numel(fn)
    s.(fn{i}).data(:,:,1) = [s.(fn{i}).x_mu1,s.(fn{i}).y_mu1];
    s.(fn{i}).data(:,:,2) = [s.(fn{i}).x_mu2,s.(fn{i}).y_mu2];
    s.(fn{i}).mid_data = (s.(fn{i}).data(:,:,1) + s.(fn{i}).data(:,:,2))/2;
end
%since midpoint fiducial means that each foci will have same
%coordinates but opposite sign, only use one marker
sd.f1.sub_data = s.main.data(:,:,1) - s.fid.mid_data;
sd.f2.sub_data = s.main.data(:,:,2) - s.fid.mid_data;
sdn = fieldnames(sd);
for n = 1:numel(sdn)   
%% Rc calculations
%sigmas
[~,x_sig] = normfit(sd.(sdn{n}).sub_data(:,1) - ...
    repmat(mean(sd.(sdn{n}).sub_data(:,1)),size(sd.(sdn{n}).sub_data(:,1))));
[~,y_sig] = normfit(sd.(sdn{n}).sub_data(:,2) - ...
    repmat(mean(sd.(sdn{n}).sub_data(:,2)),size(sd.(sdn{n}).sub_data(:,2))));
x_sig_sq = x_sig^2;
y_sig_sq = y_sig^2;
mean_sig_sq = (x_sig_sq + y_sig_sq)/2;
%res_sq calculations
mean_x_res_sq = mean((sd.(sdn{n}).sub_data(:,1) -...
    repmat(mean(sd.(sdn{n}).sub_data(:,1)),size(sd.(sdn{n}).sub_data(:,1)))).^2);
mean_y_res_sq = mean((sd.(sdn{n}).sub_data(:,1) -...
    repmat(mean(sd.(sdn{n}).sub_data(:,1)),size(sd.(sdn{n}).sub_data(:,1)))).^2);
res_sq = mean_x_res_sq + mean_y_res_sq;
%Rc
rc_pix = (5/4)*(sqrt(2*mean_sig_sq + res_sq));
rc_array(n) = rc_pix * pixel_size;
%% MSD calculations
coords_nm = sd.(sdn{n}).sub_data(:,1:2) * pixel_size;
%calculate distances from the midpoint (which is set at origin)
%pre-allocate msd matrix
msd = zeros(length(coords_nm)-1,1);
mid_dists = sqrt(coords_nm(:,1).^2 + coords_nm(:,2).^2);
for dt = 1:(length(mid_dists)-1)
    disp_sq = (mid_dists(1+dt:end) - mid_dists(1:end-dt)).^2;
    msd(dt,1) = mean(disp_sq);
end
msd_mat(:,n) = msd;
end
