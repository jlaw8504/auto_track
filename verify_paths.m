function  verify_paths( root_dir )
%VERIFY_PATHS Loop through tracks to verify fitting results of auto_track.m
%   Loop through the root directory, show the .tif images using imshow and
%   plot the paths of that foci over the image to verify accuracy of
%   auto_track.m results

%Create an error folder in the root_dir
mkdir error;
%Create a hopeless-stack folder in the root_dir
mkdir hopeless;
%get list of files and folders from root_dir
files = dir(root_dir);
for n = 1:size(files,1)
    %if the file is a folder
    if files(n).isdir == 1 &&...
            strcmp('.',files(n).name) == 0 &&... %ignore the current direcotry
            strcmp('..',files(n).name) == 0 &&... %and ignore the up directory
            strcmp('error',files(n).name) == 0 &&... %and ignore the error directory
            strcmp('hopeless',files(n).name) == 0   %and ifnore the hopeless directory
        %list all the .mat file in that folder(there should only be one if
        %auto_track.m output is unpreturbed
        %path
        mat_path = strcat(root_dir,filesep,files(n).name,filesep);
        mat_files = dir(strcat(mat_path,'*.mat'));
        %load the mat filev
        load(strcat(mat_path,mat_files(1).name));
        %The tif images are named files(n).name + _001.tif and _002.tif for
        %path1 and path2 respectively
        %load the first path image stack using bioformats plugin
        im_cell1 = bfopen(strcat(mat_path,files(n).name,'_001.tif'));
        %load the second path image stack
        im_cell2 = bfopen(strcat(mat_path,files(n).name,'_002.tif'));
        %parse the cell structure to put image stack in a 3D matrix
        im_mat1 = bf2mat(im_cell1);
        %again for im_cell2
        im_mat2 = bf2mat(im_cell2);
        %loop through the planes (3rd dimension) of the image stack
        %instantiate error_toggle switch and hopeless switch
        error_toggle = 0;
        hopeless = 0;
        for i = 1:size(im_mat1,3)
            %% Path1
            %show the tif image of plane i
            imshow(im_mat1(:,:,i),[]);
            %hold the image
            hold on;
            %scatter plot the x_mu1 and y_mu1
            scatter(x_mu1(i),y_mu1(i),'ro')
            title(files(n).name,'Interpreter','none');
            xlabel('Error = Space; Abondon Hope = Esc')
            hold off;
            %maximize figure window
            set(gcf,'position',get(0,'screensize'))
            %wait for user to click the image
            [~,~,button]=ginput(1);
            if button == 32 %if user hits spacebar
                error_toggle = 1;
                warning('User detects tracking error');
                %parse original image for total z-stack
                ori_cell = bfopen(strcat(root_dir,filesep,...
                    files(n).name,'.tif'));
                %convert cell to matrix
                ori_mat = bf2mat(ori_cell);
                %parse the z-stack based on step num and i
                stack = ori_mat(:,:,(step_num*(i-1))+1:step_num*i);
                %pass stack to function that will open new window and allow
                %user to scrub through raw stack to find foci themselves
                [x,y,plane] = stack_tracker_fixer(stack);
                %convert plane to plane_total
                total_plane = plane + step_num*(i-1);
                %rewrite path1 value
                path1(i,:) = [x,y,plane*step_size,total_plane];
                %redo lsqcurve fit
                I1 = double(stack(:,:,plane));
                cxi1 = path1(i,1); %x-coordinate path1
                cyi1 = path1(i,2); %y-coordinate path1
                %guassian2D and guassian2Dfit from Xiaohu Wan's SpeckleTracker
                %Program
                [rst1(i,:), resnorm1(i,1)] = gaussian2Dfit(I1, cxi1, cyi1, roi_size, roi_sigma);
                x_mu1(i,1) = cxi1 + rst1(i,1);
                y_mu1(i,1) = cyi1 + rst1(i,2);
            elseif button == 27 %esc key
                hopeless = 1; %toggle whole cell as hopeless
                close; %close the figure
                break; %break out of plane for loop
            end
            %% Path2
            %select f1 figure window and repeat for im_mat2
            imshow(im_mat2(:,:,i),[]);
            %hold the image
            hold on;
            %scatter plot the x_mu1 and y_mu1
            scatter(x_mu2(i),y_mu2(i),'go')
            title(files(n).name,'Interpreter','none');
            xlabel('Error = Space; Abondon Hope = Esc')
            hold off;
            set(gcf,'position',get(0,'screensize'))
            %wait for user to click the image
            [~,~,button]=ginput(1);
            if button == 32 %if user hits spacebar
                error_toggle = 1;
                warning('User detects tracking error');
                %parse original image for total z-stack
                ori_cell = bfopen(strcat(root_dir,filesep,...
                    files(n).name,'.tif'));
                %convert cell to matrix
                ori_mat = bf2mat(ori_cell);
                %parse the z-stack based on step num and i
                stack = ori_mat(:,:,(step_num*(i-1))+1:step_num*i);
                %pass stack to function that will open new window and allow
                %user to scrub through raw stack to find foci themselves
                [x,y,plane] = stack_tracker_fixer(stack);
                %convert plane to plane_total
                total_plane = plane + step_num*(i-1);
                %rewrite path1 value
                path2(i,:) = [x,y,plane*step_size,total_plane];
                %redo lsqcurve fit
                I2 = double(stack(:,:,plane));
                cxi2 = path2(i,1); %x-coordinate path1
                cyi2 = path2(i,2); %y-coordinate path1
                %guassian2D and guassian2Dfit from Xiaohu Wan's SpeckleTracker
                %Program
                [rst2(i,:), resnorm2(i,1)] = gaussian2Dfit(I2, cxi2, cyi2, roi_size, roi_sigma);
                x_mu2(i,1) = cxi2 + rst2(i,1);
                y_mu2(i,1) = cyi2 + rst2(i,2);
            elseif button == 27 %esc key
                hopeless = 1; %toggle whole cell as hopeless
                close; %close the figure
                break; %break out of plane for loop
            end
        end %end of plane for loop
        %if an error was ever detected
        if error_toggle == 1 && hopeless == 0
            %move current directory to an error folder in root
            movefile(strcat(root_dir,filesep,files(n).name,'*'),...
                strcat(root_dir,filesep,'error'));
            %make a new directory with same name + fixed
            mkdir(strcat(root_dir,filesep,files(n).name,'_fixed'));
            %rerun auto_midpoint_motion and dist delta
            distance(:,1) = sqrt((x_mu1(:,1)-x_mu2(:,1)).^2 +(y_mu1(:,1)-y_mu2(:,1)).^2);
            dist_delta = [distance(1:(end-1),1),diff(distance)];
            [rc, msd] = auto_midpoint_motion(x_mu1, y_mu1, x_mu2, y_mu2, pixel_size);
            %rerun image writer and save vars in new dir
            cd(strcat(root_dir,filesep,files(n).name,'_fixed'));
            im_writer(path1,path2,ori_mat,name);
            save(strcat(name,'_data.mat'),'coords1','coords2','path1','path2',...
                'name','scale','step_num','step_size', 'rst1', 'resnorm1',...
                'x_mu1','y_mu1','x_mu2','y_mu2','rst2','resnorm2','rc','msd',...
                'pixel_size','dist_delta', 'roi_size', 'roi_sigma');
            cd(root_dir);
        elseif hopeless == 1
            movefile(strcat(root_dir,filesep,files(n).name,'*'),...
                strcat(root_dir,filesep,'hopeless'));
        end %end of if statement for error_toggle
        close all;
    end %end of if statement for directory
end %end of for loop through files of root_dir
end %end of function
