function s = verify_paths_twochannel(s, step_num, step_size)
fn = fieldnames(s);
h = figure;
for n = 1:numel(fn)
    for j = 1:2
        for i = 1:size(s.(fn{n}).path1,1)
            %show the tif image of plane i
            if j == 1
                imshow(s.(fn{n}).im(:,:,s.(fn{n}).path1(i,4)),[]);
            else
                imshow(s.(fn{n}).im(:,:,s.(fn{n}).path2(i,4)),[]);
            end
            %hold the image
            hold on;
            %scatter plot the x_mu1 and y_mu1
            if n == 1
                marker = 'go';
            else
                marker = 'ro';
            end
            if j == 1
                scatter(s.(fn{n}).path1(i,1),...
                    s.(fn{n}).path1(i,2),marker)
            else
                scatter(s.(fn{n}).path2(i,1),...
                    s.(fn{n}).path2(i,2),marker)
            end
            title(sprintf('%s, Channel%d, path%d, t=%d/%d',...
                s.(fn{n}).name,...
                n,...
                j,...
                i,...
                size(s.(fn{n}).path1,1)),...
                'Interpreter','none');
            xlabel('Error = Space; Abondon Hope = Esc')
            hold off;
            %maximize figure window
            set(gcf,'position',get(0,'screensize'))
            %wait for user to click the image
            [~,~,button]=ginput(1);
            if button == 32 %if user hits spacebar
                warning('User detects tracking error');
                %parse s for total z-stack
                ori_mat = s.(fn{n}).im;
                %parse the z-stack based on step num and i
                stack = ori_mat(:,:,(step_num*(i-1))+1:step_num*i);
                %pass stack to function that will open new window and allow
                %user to scrub through raw stack to find foci themselves
                [x,y,plane] = stack_tracker_fixer(stack);
                %convert plane to plane_total
                total_plane = plane + step_num*(i-1);
                %rewrite path1 value
                if j == 1
                    s.(fn{n}).path1(i,:) = [x,y,plane*step_size,total_plane];
                else
                    s.(fn{n}).path2(i,:) = [x,y,plane*step_size,total_plane];
                end
            elseif button == 27 %esc key
                s = []; %set data structure to empty
                close(h); %close the figure
                return; %go back to auto_track_two_channel
            end
        end
    end
end
close(h);