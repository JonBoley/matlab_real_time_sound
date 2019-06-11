%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


%% circular buffer for 2Dimensional doubles
% always assume the first dimension is the shifting one!
classdef circbuf < handle
    properties
        data=[];
        len;  % points in x (time)
        ylen;    % points in y
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=circbuf(x,y)
            obj.len=x;
            obj.ylen=y;
            obj.data=zeros(x,y);
        end
        function obj=push(obj,x)
%             n=size(x,2);
            nx=size(x,1);
            obj.data(1:end-nx,:)=obj.data(nx+1:end,:);
            obj.data(end-nx+1:end,:)=x;
        end
        function x=get(obj)
            x=obj.data;
        end
        function l=getlength(obj)
            l=obj.len;
        end
        function l=getheight(obj)
            l=obj.ylen;
        end
    end
end
