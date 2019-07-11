
% main script: create all codebooks from folders with speech files
% basic version: learn from 10 test speakers with 10 files each
 % clear all
 % clc
 % close all force

addpath(genpath('../../rttools'));
addpath(genpath('../../rtmodules'));
addpath(genpath('../../thirdparty'));

nr_cluster_means=16;        % k-means clustering: how many centroids?


subjects=30:39; % these are the subject numbers
nr_learn=10; % how many wavs I use for learning

tic
% create a list of files that I want to learn
ood=cd('./training');
fullfiles=[];
for i=1:length(subjects)
    snr=subjects(i);
    ds=sprintf('s%d',snr);
    od=cd(ds);
    dds=dir;
    nr_c=0;
    for j=1:length(dds)
        if contains(dds(j).name,'.wav')
            nr_c=nr_c+1;
            files=dds(j).name;
            fullfiles{i,nr_c}=fullfile(pwd,files);
            if nr_c==nr_learn
                break % finished with learning
            end
        end
    end
    cd(od); % go back up
end
cd(ood)

fullcodebooks=[];
% do the learnig
for i=1:length(subjects)
    dict{i}=[];
    for j=1:nr_learn
        d=create_one_dictionary(fullfiles{i,j});  % give me one set of features for one person for one file
        nrp=length(dict{i});
        for k=1:length(d)
            dict{i}{nrp+k}=d{k};
        end
    end
    
    cb=build_codebook(dict{i},nr_cluster_means);  % build the codebook for this subject
    fullcodebooks{i}=cb;
end

save fullcodebooks fullcodebooks
toc

return






