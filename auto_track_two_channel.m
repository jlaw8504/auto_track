function [rc_array, msd_mat, s] = auto_track_two_channel(filename, fiducial_channel)
%%AUTO_TRACK_TWO_CHANNEL Calculate mean squared displacement and radius of
%%confinement for two foci with corresponding fidicucial foci in a seperate
%%image channel.
%
%   inputs :
%       filename : String containing the filename of the image hyperstack
%       file to analyze.
%
%       fiducial_channel : Integer, either 1 or 2, specifying which channel
%       should be used as the fiducial mark/marks. Usually spindle pole
%       body channel. I
%
%   output :
%       rc_array : Two-value vector of radii of confinement of each foci
%       in filename1 images after setting their position relative to the
%       foci in fiducial_filename images.  The column order is the same for
%       rc_array and msd_mat.
%
%       msd_mat : 2D matrix of the mean squared displacement of each foci
%       in filename1 images after setting their position relative to the
%       foci in fiducial_filename images. Each row represents the MSD value
%       of a foci at a given timestep/(tau). The order of the rows is
%       timestep*1, timestep*2, timestep*3, etc. Each column reprsents a
%       foci. The column order is the same for rc_array and msd_mat.

%% Hardcoded Variables
scale = 5; %1/x times max possible radius in frequency space
step_num = 23; %steps
pixel_size = 133.33; %nm
step_size = 300; %nm
%% Load in the hyperstack
hyper = readTiffStack(filename);
idx1 = 1:2:size(hyper,3);
idx2 = 2:2:size(hyper,3);
if fiducial_channel == 2
    s.main.im = hyper(:,:,idx1);
    s.fid.im = hyper(:,:,idx2);
else
    s.main.im = hyper(:,:,idx2);
    s.fid.im = hyper(:,:,idx1);
end
%% Pull out fieldnames and start for loop
fn = fieldnames(s);
for n=1:numel(fn)
    %first pass at pulling out coordinate information
    %main channel
    [s.(fn{n}).coords1,s.(fn{n}).coords2] = low_part_dect(...
        s.(fn{n}).im,scale,step_num,pixel_size,step_size);
    %correct for foci switching between the two foci
    [s.(fn{n}).path1, s.(fn{n}).path2] =...
        while_cost(s.(fn{n}).coords1, s.(fn{n}).coords2);
    % paths back to pixels
    s.(fn{n}).path1 = [s.(fn{n}).path1(:,1:2)/pixel_size,...
        s.(fn{n}).path1(:,3:4)];
    s.(fn{n}).path2 = [s.(fn{n}).path2(:,1:2)/pixel_size,...
        s.(fn{n}).path2(:,3:4)];
end
%% Verifty paths
s = verify_paths_twochannel(s, step_num, step_size);
if isempty(s)
    return
end
for n=1:numel(fn)
    %% Loop through paths and gaussian fit particles
    for i =1:size(s.(fn{n}).path1,1)
        s.(fn{n}).I1 = double(s.(fn{n}).im(:,:,s.(fn{n}).path1(i,4)));
        s.(fn{n}).I2 = double(s.(fn{n}).im(:,:,s.(fn{n}).path2(i,4)));
        s.(fn{n}).cxi1 = s.(fn{n}).path1(i,1); %x-coordinate path1
        s.(fn{n}).cyi1 = s.(fn{n}).path1(i,2); %y-coordinate path1
        s.(fn{n}).cxi2 = s.(fn{n}).path2(i,1); %x-coordinate path2
        s.(fn{n}).cyi2 = s.(fn{n}).path2(i,2); %y-coordinate path2
        s.(fn{n}).roi_size = 5; %pixels (sizexsize area)
        s.(fn{n}).roi_sigma = 2; %pixels
        %guassian2D and guassian2Dfit from Xiaohu Wan's SpeckleTracker
        %Program
        [s.(fn{n}).rst1(i,:), s.(fn{n}).resnorm1(i,1)] = gaussian2Dfit(...
            s.(fn{n}).I1,...
            s.(fn{n}).cxi1,...
            s.(fn{n}).cyi1,...
            s.(fn{n}).roi_size,...
            s.(fn{n}).roi_sigma);
        [s.(fn{n}).rst2(i,:), s.(fn{n}).resnorm2(i,1)] = gaussian2Dfit(...
            s.(fn{n}).I2,...
            s.(fn{n}).cxi2,...
            s.(fn{n}).cyi2,...
            s.(fn{n}).roi_size,...
            s.(fn{n}).roi_sigma);
        s.(fn{n}).x_mu1(i,1) = s.(fn{n}).cxi1 + s.(fn{n}).rst1(i,1);
        s.(fn{n}).y_mu1(i,1) = s.(fn{n}).cyi1 + s.(fn{n}).rst1(i,2);
        s.(fn{n}).x_mu2(i,1) = s.(fn{n}).cxi2 + s.(fn{n}).rst2(i,1);
        s.(fn{n}).y_mu2(i,1) = s.(fn{n}).cyi2 + s.(fn{n}).rst2(i,2);
    end
end
[rc_array, msd_mat] = fiducial_mark_motion(s, pixel_size);
