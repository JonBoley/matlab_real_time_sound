%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


%% circular buffer for 1Dimensional doubles
classdef circbuf1 < handle
    properties 
        data=[];
        len
    end
    
    methods
        function obj=circbuf1(len)
            obj.len=len;
            obj.data=zeros(len,1);
        end
        function push(obj,x)
            n=length(x);
            obj.data(1:end-n)=obj.data(n+1:end);
            obj.data(end-n+1:end)=x;
        end

         function x=get(obj,n)
             if nargin<2
                 n=obj.len;
             end
            x=obj.data(end-n+1:end);
        end
        function l=getlength(obj)
            l=obj.len;
        end
        
        function add(obj,v)
            obj.data=obj.data+v;
        end
    end
end
    
