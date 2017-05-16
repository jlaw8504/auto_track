for n = 1:4
    for r = row-n:row+n
        display(r/size(test_plane,1)*100);
        for c = col-n:col+n
            
            try
                [~, resnorm1(r,c)] = gaussian2Dfit(test_plane, c, r, 5, 2);
            catch
                resnorm1(r,c) = nan;
            end
        end
    end
end