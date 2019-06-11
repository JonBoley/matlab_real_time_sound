%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef caim_nap
    properties
        buffer;
        parent;
        lpFilt;
        zi;
        coeff;
    end
    
    methods
        function obj=caim_nap(parent)
            obj.parent=parent;
            
            %initialization            % design a fresh filter
            lowpass_cutoff=1200;
            lpFilt = designfilt('lowpassfir',...
                'SampleRate',1/obj.parent.sample_rate,....
                'PassbandFrequency',lowpass_cutoff, ...
                'StopbandFrequency',2400,...
                'PassbandRipple',2, ...
                'StopbandAttenuation',50,...
                'DesignMethod','equiripple');
            obj.coeff=lpFilt.Coefficients;
            
            %                                      fvtool(obj.lpFilt)
            zi=filter(obj.coeff,1,ones(length(obj.coeff)-1,1),filtic(obj.coeff,1,1));
            obj.zi=ones(obj.parent.num_channels,length(zi));
            
        end
        
        function obj=step(obj,inp)
            meps=2.2204e-16; % for generic compatilility. This is what i have on my mac with the corrent installation
            %inp=abs(inp);   % abs takes all values into account, positive and negative. More information, but less physiological 
            pinp=inp;
            pinp(inp<meps)=meps; % half wave rectification is more physiological
%             inp=inp.*power(2,15);
            linp = log(pinp); % log compression
            linp=linp-log(meps); % now the lowest point is always 0 
%             
            for ch=1:obj.parent.num_channels
                [outc,obj.zi(ch,:)]=filter(obj.coeff,1,linp(ch,:),obj.zi(ch,:));
                obj.buffer(ch,:)=outc;
            end
            
%             obj.buffer=linp;  % no low pass filtering
            
        end
    end
end
