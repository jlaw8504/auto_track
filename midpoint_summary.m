counter = 1;
ens_dist_delta = [];
all_files = dir;
for n = 1:size(all_files,1)
    if all_files(n).isdir == 1 && strcmp(all_files(n).name,'.') == 0 && strcmp(all_files(n).name,'..') == 0
        cd(all_files(n).name);
        mat_files = dir('*.mat');
        load(mat_files(1).name);
        ens_rc(counter) = rc;
        msd_cell{counter} = msd;
        ens_dist_delta = [ens_dist_delta;dist_delta];
        counter = counter + 1;
        cd('..');
    end
end
clearvars -except ens_rc msd_cell ens_dist_delta
