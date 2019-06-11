%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


function savetofile(in,file)

id=fopen(file,'wt');

nr=length(in);
for i=1:nr
    fprintf(id,'%s\n',in{i});
end
    
fclose(id);
