%% Hardcoded Variables
scale = 5; %1/x times max possible radius in frequency space
step_num = 21; %steps
pixel_size = 133; %nm
step_size = 300; %nm
ens_dist_delta = [];

gfp_files = dir('*GFP*.tif');
for n = 1:length(gfp_files)
    [~,name,~] = fileparts(gfp_files(n).name);
    %Open Image
    im_cell = bfopen(gfp_files(n).name);
    %convert to 3D matrix
    im = bf2mat(im_cell);
    %mkdir
    mkdir(name);
    [coords1,coords2] = low_part_dect(im,scale,step_num,pixel_size,step_size);
    [path1, path2] = while_cost(coords1, coords2);
    im_writer(path1,path2,im,name);
    %convert paths and coords back to pixels
    coords1 = [coords1(:,1:2)/pixel_size,coords1(:,3:4)];
    coords2 = [coords2(:,1:2)/pixel_size,coords2(:,3:4)];
    path1 = [path1(:,1:2)/pixel_size,path1(:,3:4)];
    path2 = [path2(:,1:2)/pixel_size,path2(:,3:4)];
    %% Loop through paths and gaussian fit particles
    for i =1:size(path1,1)
        I1 = double(im(:,:,path1(i,4)));
        I2 = double(im(:,:,path2(i,4)));
        cxi1 = path1(i,1); %x-coordinate path1
        cyi1 = path1(i,2); %y-coordinate path1
        cxi2 = path2(i,1); %x-coordinate path2
        cyi2 = path2(i,2); %y-coordinate path2
        roi_size = 5; %pixels (sizexsize area)
        roi_sigma = 2; %pixels
        %guassian2D and guassian2Dfit from Xiaohu Wan's SpeckleTracker
        %Program
        [rst1(i,:), resnorm1(i,1)] = gaussian2Dfit(I1, cxi1, cyi1, roi_size, roi_sigma);
        [rst2(i,:), resnorm2(i,1)] = gaussian2Dfit(I2, cxi2, cyi2, roi_size, roi_sigma);
        x_mu1(i,1) = cxi1 + rst1(i,1);
        y_mu1(i,1) = cyi1 + rst1(i,2); 
        x_mu2(i,1) = cxi2 + rst2(i,1);
        y_mu2(i,1) = cyi2 + rst2(i,2);
        distance(i,1) = sqrt((x_mu1(i,1)-x_mu2(i,1))^2 +(y_mu1(i,1)-y_mu2(i,1))^2);
    end
    dist_delta = [distance(1:end-1,1),diff(distance)];
    [rc, msd] = auto_midpoint_motion(x_mu1, y_mu1, x_mu2, y_mu2, pixel_size);
    save(strcat(name,'_data.mat'),'coords1','coords2','path1','path2',...
        'name','scale','step_num','step_size', 'rst1', 'resnorm1',...
        'x_mu1','y_mu1','x_mu2','y_mu2','rst2','resnorm2','rc','msd',...
        'pixel_size','dist_delta', 'roi_size', 'roi_sigma');
    movefile(strcat(name,'_001','.tif'),strcat(cd,filesep,name));
    movefile(strcat(name,'_002','.tif'),strcat(cd,filesep,name));
    movefile(strcat(name,'_data.mat'),strcat(cd,filesep,name));
    ens_rc(n,1) = rc;
    msd_cell{n} = msd;
    ens_dist_delta = [ens_dist_delta;dist_delta];
    clearvars -except gfp_files n scale step_num pixel_size step_size ens_rc msd_cell...
        ens_dist_delta
end

