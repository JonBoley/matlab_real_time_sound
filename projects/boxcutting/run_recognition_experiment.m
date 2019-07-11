
% framework script: use a trained codebook and attempt to identify n
% speakers (in quiet). Output: confusion matrix of identified speakers

clear all
clc

tic
addpath(genpath('../../rttools'));
addpath(genpath('../../rtmodules'));
addpath(genpath('../../thirdparty'));

nr_cluster_means=16;        % k-means clustering: how many centroids?
subjects=30:39; % these are the subject numbers
nr_test=10; % how many wavs I use for testing


% create a list of files that I want to test
ood=cd('./testing');
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
            if nr_c==nr_test
                break % finished with learning
            end
        end
    end
    cd(od); % go back up
end
cd(ood)


% load the full codebook of trained speakers
load fullcodebooks fullcodebooks

fullresult=zeros(size(fullfiles));

for i=1:size(fullfiles,1)
    for j=1:size(fullfiles,2)
        x_file=fullfiles{i,j};
        tic
        test_dic=create_one_dictionary(x_file);
        
        
        nr_boxes=size(test_dic{1},1); %64
        nr_frames=length(test_dic);  %351 changes with stimulus
        nr_subjects=length(fullcodebooks); %9?
        nr_cluster_means=size(fullcodebooks{1}{1},1); %16
        
        % now find out which of the codebooks this one is closest to:
        % Firstly, for every frame and every box, the Euclidean distance is
        % computed between every centroid in the codebook for that specific box,
        % and the current feature vector for that box. For each one of the frames,
        % the minimum of these distances is the reconstruction value for that frame
        % using the codebook for that specific box.
        % Afterwards, the process is repeated over the total number of frames and
        % those values, for each box, can be averaged over all of the frames, i.e. for
        % the whole speech utterance. This results in the mean reconstruction value
        % for every box. The process can be repeated for each one the speaker
        % models.
        
        mindist_speaker=zeros(nr_subjects,nr_boxes);
        for subject_nr=1:nr_subjects % for every test_subject in the learned codebook
            mindistframe=zeros(nr_frames,nr_boxes);
            for frame_nr=1:nr_frames % for every frame
                mindistbox=zeros(nr_boxes,1);
                for box_nr=1:nr_boxes   % and for every box
                    % calculate eucledean distance between current feature vector and every centroid of the box
                    dist=[];
                    for cluster_nr=1:nr_cluster_means
                        current_feature_vec=test_dic{frame_nr}(box_nr,:);
                        current_learned_centroid=fullcodebooks{subject_nr}{box_nr}(cluster_nr,:);
                        dist(cluster_nr)=sqrt(sum(power(current_feature_vec-current_learned_centroid,2)));
                    end
                    mindistbox(box_nr)=min(dist);
                end
                mindistframe(frame_nr,:)= mindistbox;
            end
            mindist_speaker(subject_nr,:)=mean(mindistframe);
        end
        
        
        % The speaker that is most likely to be the target speaker is the one
        % who has the largest number of boxes corresponding to the smallest
        % average reconstruction value.
        
        smallestboxwinner=zeros(nr_subjects,1);
        for box_nr=1:nr_boxes   % and for every box
            [~,indx]=min(mindist_speaker(:,box_nr));
            smallestboxwinner(indx)=smallestboxwinner(indx)+1;
        end
        
        [nrh,winner]=max(smallestboxwinner);
        
        fprintf('I predict that this utterance (from %d) came from speaker %d (with %d hits)\n',i,winner,nrh);
        
        
        fullresult(i,j)=winner;
        toc
    end
end

% make and plot a confusion matrix
confusion_matrix=zeros(size(fullresult));

for i=1:size(fullfiles,1)
    for j=1:size(fullfiles,2) 
        confusion_matrix(i,fullresult(i,j))=confusion_matrix(i,fullresult(i,j))+1;
    end
end

confusion_matrix

toc