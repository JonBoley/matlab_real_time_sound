% tool
% 
%   INPUT VALUES:
%  
%   RETURN VALUE:
%
% 
% This external file is included as part of the 'aim-mat' distribution package
% (c) 2011, University of Southampton
% Maintained by Stefan Bleeck (bleeck@gmail.com)
% download of current version is on the soundsoftware site: 
% http://code.soundsoftware.ac.uk/projects/aimmat
% documentation and everything is on http://www.acousticscale.org

%   Copyright 2019 Stefan Bleeck, University of Southampton
function savetofile(in,file)

id=fopen(file,'wt');

nr=length(in);
for i=1:nr
    fprintf(id,'%s\n',in{i});
end
    
fclose(id);
