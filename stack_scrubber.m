function stack_scrubber( stack )
%STACK_SCRUBBER Function to go through a 3D matrix of an image stack
%   Parse a 3D matrix, alter the 3rd dimension (plane) using left and right
%   arrow keys on keyboard

%get size of the matrix
[~,~,planes] = size(stack);
%set plane variable n to 1
n = 1;
%instantiate a kill variable
kill = 0;
%show the first plane
f1 = figure;
imshow(stack(:,:,n),[]);
title(strcat(num2str(n),'/',num2str(planes)))
%Start a while loop that parses arrow keys to navigate planes
while kill == 0
    [~,~,button]=ginput(1);
    switch button
        case 30 %up
            n = planes;
        case 31 %down
            n = 1;
        case 28 %left
            if n ~= 1
                n = n - 1;
            end
        case 29 %right
            if n ~= planes
                n = n + 1;
            end
        case 32 %space
            kill = 1;
    end
    if kill == 1
        close(f1);
    else
        imshow(stack(:,:,n),[]);
        title(strcat(num2str(n),'/',num2str(planes)))
    end
end

end

