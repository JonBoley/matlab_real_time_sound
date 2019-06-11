%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% class based basilar membrane, part of the caim

classdef caim_bmm
    properties
        fcoefs;
        zf1;
        zf2;
        zf3;
        zf4;
        buffer;
        parent;
    end
    
    methods
        
        function obj=caim_bmm(parent)
            obj.parent=parent;
            
            EarQ = 9.26449;				%  Glasberg and Moore Parameters
            minBW = 24.7;
            cfs=parent.centre_frequencies;
            
            sr=parent.sample_rate;
            
            ERB = cfs/EarQ + minBW;
            B=1.019*2*pi*ERB;
            A0 = sr;    A2 = 0;    B0 = 1;
            B1 = -2*cos(2*cfs*pi*sr)./exp(B*sr);
            B2 = exp(-2*B*sr);
            A11 = -(2*sr*cos(2*cfs*pi*sr)./exp(B*sr) + 2*sqrt(3+2^1.5)*sr*sin(2*cfs*pi*sr)./ ...
                exp(B*sr))/2;
            A12 = -(2*sr*cos(2*cfs*pi*sr)./exp(B*sr) - 2*sqrt(3+2^1.5)*sr*sin(2*cfs*pi*sr)./ ...
                exp(B*sr))/2;
            A13 = -(2*sr*cos(2*cfs*pi*sr)./exp(B*sr) + 2*sqrt(3-2^1.5)*sr*sin(2*cfs*pi*sr)./ ...
                exp(B*sr))/2;
            A14 = -(2*sr*cos(2*cfs*pi*sr)./exp(B*sr) - 2*sqrt(3-2^1.5)*sr*sin(2*cfs*pi*sr)./ ...
                exp(B*sr))/2;
            gain = abs((-2*exp(4*1i*cfs*pi*sr)*sr + 2*exp(-(B*sr) + 2*1i*cfs*pi*sr).*sr.* ...
                (cos(2*cfs*pi*sr) - sqrt(3 - 2^(3/2))* sin(2*cfs*pi*sr))) .* ...
                (-2*exp(4*1i*cfs*pi*sr)*sr + 2*exp(-(B*sr) + 2*1i*cfs*pi*sr).*sr.* ...
                (cos(2*cfs*pi*sr) + sqrt(3 - 2^(3/2)) * sin(2*cfs*pi*sr))).* ...
                (-2*exp(4*1i*cfs*pi*sr)*sr + 2*exp(-(B*sr) + 2*1i*cfs*pi*sr).*sr.* ...
                (cos(2*cfs*pi*sr) - sqrt(3 + 2^(3/2))*sin(2*cfs*pi*sr))) .* ...
                (-2*exp(4*1i*cfs*pi*sr)*sr + 2*exp(-(B*sr) + 2*1i*cfs*pi*sr).*sr.* ...
                (cos(2*cfs*pi*sr) + sqrt(3 + 2^(3/2))*sin(2*cfs*pi*sr))) ./ ...
                (-2 ./ exp(2*B*sr) - 2*exp(4*1i*cfs*pi*sr) +  ...
                2*(1 + exp(4*1i*cfs*pi*sr))./exp(B*sr)).^4);
            allfilts = ones(length(cfs),1);
            obj.fcoefs = [A0*allfilts A11 A12 A13 A14 A2*allfilts B0*allfilts B1 B2 gain];
            obj.zf1=zeros(length(cfs),2);    
            obj.zf2=zeros(length(cfs),2);    
            obj.zf3=zeros(length(cfs),2);    
            obj.zf4=zeros(length(cfs),2);
        end
        
        function obj=step(obj,input)
            
            A0  = obj.fcoefs(:,1);
            A11 = obj.fcoefs(:,2);
            A12 = obj.fcoefs(:,3);
            A13 = obj.fcoefs(:,4);
            A14 = obj.fcoefs(:,5);
            A2  = obj.fcoefs(:,6);
            B0  = obj.fcoefs(:,7);
            B1  = obj.fcoefs(:,8);
            B2  = obj.fcoefs(:,9);
            gain= obj.fcoefs(:,10);
            obj.buffer = zeros(obj.parent.num_channels, obj.parent.window_length);
            
            for c = 1:obj.parent.num_channels
                [y1,obj.zf1(c,:)]=filter([A0(c)/gain(c) A11(c)/gain(c),A2(c)/gain(c)],[B0(c) B1(c) B2(c)], input,obj.zf1(c,:));
                [y2,obj.zf2(c,:)]=filter([A0(c) A12(c) A2(c)],[B0(c) B1(c) B2(c)], y1,obj.zf2(c,:));
                [y3,obj.zf3(c,:)]=filter([A0(c) A13(c) A2(c)],[B0(c) B1(c) B2(c)], y2,obj.zf3(c,:));
                [y4,obj.zf4(c,:)]=filter([A0(c) A14(c) A2(c)],[B0(c) B1(c) B2(c)], y3,obj.zf4(c,:));
                obj.buffer(c, :) = y4;
            end
        end
    end
    
end
