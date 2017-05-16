function [path1, path2] = while_cost(coords1, coords2)
%% Generate all possible assignment matrices
A1 = [1,0;0,1];
A2 = [0,1;1,0];
%set inital timepoint for while loop
t = 1;
while t < size(coords1,1)
    %generate a cost matrix for two coords
    %cost matrix is sum of abs distances in x, y and z and relitive
    %distances in x and y
    C(1,1,t) = abs(coords1(t,1) - coords1(t+1,1))+...
        abs(coords1(t,2) - coords1(t+1,2))+...
        abs(coords1(t,3) - coords1(t+1,3))+...
        abs((coords1(t,1) - coords2(t,1))-...
        (coords1(t+1,1) - coords2(t+1,1)))+...
        abs((coords1(t,2) - coords2(t,2))-...
        (coords1(t+1,2) - coords2(t+1,2)));
    
    C(1,2,t) = abs(coords1(t,1) - coords2(t+1,1))+...
        abs(coords1(t,2) - coords2(t+1,2))+...
        abs(coords1(t,3) - coords2(t+1,3))+...
        abs((coords1(t,1) - coords2(t,1))-...
        (coords2(t+1,1) - coords1(t+1,1)))+...
        abs((coords1(t,2) - coords2(t,2))-...
        (coords2(t+1,2) - coords1(t+1,2)));
    
    C(2,1,t) = abs(coords2(t,1) - coords1(t+1,1))+...
        abs(coords2(t,2) - coords1(t+1,2))+...
        abs(coords2(t,3) - coords1(t+1,3))+...
        abs((coords2(t,1) - coords1(t,1))-...
        (coords1(t+1,1) - coords2(t+1,1)))+...
        abs((coords2(t,2) - coords1(t,2))-...
        (coords1(t+1,2) - coords2(t+1,2)));
    
    C(2,2,t) = abs(coords2(t,1) - coords2(t+1,1))+...
        abs(coords2(t,2) - coords2(t+1,2))+...
        abs(coords2(t,3) - coords2(t+1,3))+...
        abs((coords2(t,1) - coords1(t,1))-...
        (coords2(t+1,1) - coords1(t+1,1)))+...
        abs((coords2(t,2) - coords1(t,2))-...
        (coords2(t+1,2) - coords1(t+1,2)));
    %Assign a large cost penalty if track switches position
    %determine relative coord position in 1st 2 dimensions (X,Y)
    rel1 = abs((coords1(t,1) - coords2(t,1)) - (coords1(t+1,1) - coords2(t+1,1)));
    rel2 = abs((coords1(t,2) - coords2(t,2)) - (coords1(t+1,2) - coords2(t+1,2)));
    %multiply cost matrix by two assigment matrices and sum
    AC1 = C(:,:,t).*A1; AC2 = C(:,:,t).*A2;
    % row 1 is stay, row 2 is switch
    sum_AC(1,t) = sum(AC1(:));
    sum_AC(2,t) = sum(AC2(:));
    %if cost of stay is less than switch
    if sum_AC(1,t) < sum_AC(2,t)
        t = t + 1;
    elseif sum_AC(1,t) > sum_AC(2,t)
        temp2 = coords1(t+1,:);
        temp1 = coords2(t+1,:);
        %alter coords directly
        coords1(t+1,:) = temp1;
        coords2(t+1,:) = temp2;
        
    elseif sum_AC(1,t) == sum_AC(2,t)
        %if the cost is the same (sum of all dimensional differences)
        if abs(coords1(t,1) - coords2(t,1)) >=...
                abs(coords1(t,2) - coords2(t,2))
            dim = 1;
        else
            dim = 2;
        end
        %determine which spot is consistently lower in selcted dimension
        %thus far in the sorting process
        sum_dim1 = sum(coords1(1:t,dim) <= coords2(1:t,dim));
        sum_dim2 = sum(coords2(1:t,dim) <= coords1(1:t,dim));
        %if coord1 and coord2 pattern matches pattern of timelapse thus far
        %iterate, otherwise switch
        if (sum_dim1 > sum_dim2 && coords1(t+1,dim) < coords2(t+1,dim))||...
                (sum_dim1 < sum_dim2 && coords1(t+1,dim) > coords2(t+1,dim))
            t = t+1;
        else
            %use previous coordinates
            temp2 = coords1(t-1,:);
            temp1 = coords2(t-1,:);
            %alter coords directly
            coords1(t+1,:) = temp1;
            coords2(t+1,:) = temp2;
        end
        
    end
end
path1 = coords1;
path2 = coords2;
