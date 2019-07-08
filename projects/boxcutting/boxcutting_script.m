
% % script to run a simple hearing aid with real time controls
% clear all
% clc
% close all force

addpath(genpath('../../rttools'));
addpath(genpath('../../rtmodules'));
addpath(genpath('../../thirdparty'));

filename='../../randomwavs/BKBE0602.WAV';
[x,fs]=audioread(filename);
l=length(x)/fs;

l=1;

fs=16000;
mymodel=rt_model('SampleRate',fs,'FrameLength',128,'Channels',1,'Duration',l,'OverlapAdd',0,'PlotWidth',l);
add_module(mymodel,rt_input_file(mymodel,'filename',filename));
% add_module(mymodel,rt_spectrum(mymodel));
add_module(mymodel,rt_sai_boxcutting(mymodel));

% gui(mymodel);
initialize(mymodel);
run_once(mymodel);
close(mymodel);


res=mymodel.measurement_result;
% nr boxes:
nr_boxes=size(res{1},1);
clear vals
% create one big matrix for each box size:
% http://iieta.org/sites/default/files/Journals/AMA/AMA_B/60.2_01.pdf
for j=1:nr_boxes
    vals{j}=zeros(length(res),size(res{1},2)); % 189 x 48
    for i=1:length(res)  % build a matrix of vectors of this box over time
        vals{j}(i,:)=res{i}(j,:);
    end
end

% k-means clustering for each of the boxes
nrklusters=64;
cluster_centres=zeros(nr_boxes,nrklusters);
for j=1:nr_boxes
    X=vals{j};
    [idx,c] = kmeans(X,nrklusters);
    cluster_centres(j,:)=c(j,:);
end


