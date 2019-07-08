function codebooks=build_codebook(featvec,nr_cluster_means)

% nr boxes:
nr_boxes=size(featvec{1},1);
vals=[];
% create one big matrix for each box size:
% http://iieta.org/sites/default/files/Journals/AMA/AMA_B/60.2_01.pdf
for j=1:nr_boxes
    vals{j}=zeros(length(featvec),size(featvec{1},2)); % 189 x 48
    for i=1:length(featvec)  % build a matrix of vectors of this box over time
        vals{j}(i,:)=featvec{i}(j,:);
    end
end

% k-means clustering for each of the boxes
codebooks=[];
for j=1:nr_boxes
    X=vals{j};
    [~,c] = kmeans(X,nr_cluster_means);
    codebooks{j}=c;
end

end