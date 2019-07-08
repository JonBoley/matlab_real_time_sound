
% script that attempts to identify the speaker in one wav file (given) to
% the full code book and returns the number of the closest match
clear all
clc

tic
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s2/s2_l_prwgzs.wav'; % nr 1 works! (64 hits out of 64)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s3/s3_l_lbie5s.wav'; % nr 2 works! (62)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s4/s4_l_lwau8a.wav'; % nr 3 works! (62)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s5/s5_l_pbbf5p.wav'; % nr 4 works! (64)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s6/s6_l_lwigzn.wav'; % nr 5 works! (58)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s7/s7_l_lwal6n.wav'; % nr 6 works! (64)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s8/s8_l_pbiu9n.wav'; % nr 7 works! (64)
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s9/s9_l_pbiu9n.wav'; % nr 7 works! (61)

% an unlearned speaker:
% x_file='/Users/bleeck/Google Drive/HA lab/sounds/lombard grid audio/s13/s13_l_lgab1a.wav'; % 32 hits (num5)

load fullcodebooks fullcodebooks

% each SAI has 64 boxes
% each box has one vector of 48 marginal numbers
% each codebook has 16 clusters
% each codebook has 64 boxes * 16 clusters * 48 numbers


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

fprintf('I predict that this utterance came from speaker %d (with %d hits)\n',winner,nrh);

toc
