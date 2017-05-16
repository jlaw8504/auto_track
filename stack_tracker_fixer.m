function [x,y,plane] = stack_tracker_fixer( stack )
%STACK_SCRUBBER_FIXER Function to go through a 3D matrix of an image stack
%   Parse a 3D matrix, alter the 3rd dimension (plane) using left and right
%   arrow keys on keyboard.  Then prompt user to selct a pixel position.

%get size of the matrix
[~,~,planes] = size(stack);
%set plane variable plane to 1
plane = 1;
%instantiate a kill variable
kill = 0;
%show the first plane
f1 = figure;
imshow(stack(:,:,plane),[]);
title(strcat(num2str(plane),'/',num2str(planes)))
xlabel('Press SPACE to confirm plane');
%Start a while loop that parses arrow keys to navigate planes
while kill == 0
    [~,~,button]=ginput(1);
    switch button
        case 30 %up
            plane = planes;
        case 31 %down
            plane = 1;
        case 28 %left
            if plane ~= 1
                plane = plane - 1;
            end
        case 29 %right
            if plane ~= planes
                plane = plane + 1;
            end
        case 32 %space
            kill = 1;
    end
    imshow(stack(:,:,plane),[]); 
    title(strcat(num2str(plane),'/',num2str(planes)))
    xlabel('Press SPACE to confirm plane');
end
%use imshow to show the selected plane
f2 = figure;
imshow(stack(:,:,plane),[]);
set(gcf,'position',get(0,'screensize'))
title('Please select foci using RIGHT MOUSE CLICK');
%select x and y from plane
[x,y] = getpts;
if length(x) ~= 1 || length(y) ~= 1 %if user accidently clicks twice
    x = x(1);
    y = y(1);
end
xlabel(num2str(x));
ylabel(num2str(y));
%close figure window
close(f2);
end

