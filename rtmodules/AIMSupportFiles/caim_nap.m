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
            % logic for calibration: a 0dB sound will produce a zero value
            % (and all quieter ones too). A 100 dB sound will give the full
            % range of 1
            
            %             my_eps=2.2204e-16; % for generic compatilility. This is what i have on my mac with the corrent installation
            P0=2*1E-5;     % reference sound pressure level
            
            %inp=abs(inp);   % abs takes all values into account, positive and negative. More information, but less physiological
            pinp=inp;
            pinp(inp<P0)=P0; % half wave rectification is more physiological
            linp = log(pinp); % log compression
            linp=linp-log(P0); % now the lowest point is always 0
            linp=linp./abs(log(P0));
            
            for ch=1:obj.parent.num_channels
                [outc,obj.zi(ch,:)]=filter(obj.coeff,1,linp(ch,:),obj.zi(ch,:));
                obj.buffer(ch,:)=outc;
            end
            
            
            %             obj.buffer=linp;  % no low pass filtering
            
        end
    end
end
