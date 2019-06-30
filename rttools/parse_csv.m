
%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)





function r=parse_csv(str,nr)
if nargin<2
    nr=1;
end

if nr==1
    rr=strsplit(str,',');
    for i=1:length(rr)
        r(i)=str2double(rr{i});
    end
elseif nr==2 % do it in pairs (for an audiogram for example)
    rr=strsplit(str,',');
    c=1;
    nre=2*floor(length(rr)/2);
    for i=1:2:nre
        r(c,1)=str2double(rr{i});
        r(c,2)=str2double(rr{i+1});
        c=c+1;
    end
end
