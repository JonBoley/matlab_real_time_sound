%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



function res=f2f(value,from1,to1,from2,to2,logstate)
% usage:res=f2f(from1,to1,value1,from2,to2,is_log)
% translates the value from the system from1 to1 to the system from2 to2
% either logarithmic or not

%   Copyright 2019 Stefan Bleeck, University of Southampton
if nargin < 6
    logstate='linlin';
end

if to1==from1
    res=from1;
    return;
end


switch logstate
    case 'loglin'
        m=(to2-from2)/(log(to1)-log(from1));
        c= from2-log(from1)*m;
        res= m*log(value)+c;
    case 'linlog'
        m=(log(to2)-log(from2))/(to1-from1);
        c= log(from2)-m*from1;
        res=exp(m*value+c);
    case 'linlin'
        m=(to2-from2)/(to1-from1);
        c= from2-m*from1;
        res=m*value+c;
end
