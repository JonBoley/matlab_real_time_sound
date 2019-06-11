%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_loudness < rt_measurer
    properties
        noisy_buffer;
        loudness_buffer;
    end
    
    methods
        %% creator
        function obj=rt_loudness(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='Loudness';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',0.5);  % buffer for computation MUST be >0.4 sec!
            parse(pars,varargin{:});
            add(obj.p,param_float('integrationPeriod',pars.Results.integrationPeriod));
            
            s='Loudness estimates the perceived Loudness of a sound';
            s=[s,'using the matlab implementaiton of ''integratedLoudness'''];
            s=[s,'https://uk.mathworks.com/help/audio/ref/integratedloudness.html'];
            obj.descriptor=s;
        end
        
        function post_init(obj)
            l=getvalue(obj.p,'integrationPeriod');
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            
            obj.loudness_buffer=circbuf1(mm);
        end
        
        function loudness=calculate(obj,sig)
            fs=obj.parent.SampleRate;
            push(obj.noisy_buffer,sig);
            % length of analysis window
            l=getvalue(obj.p,'integrationPeriod');
            cutsig=get(obj.noisy_buffer,l*obj.parent.SampleRate);
            
            %% calculate the loudness using the inbuild matlab model
            loudness=integratedLoudness(cutsig,fs);
            
            push(obj.loudness_buffer,loudness);
            
            x=1:getlength(obj.loudness_buffer);
            y=get(obj.loudness_buffer);
            measax=obj.measurement_axis;
            
            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                plot(measax,x,y,'.-');
                 set(measax,'xlim',[0 length(x)],'ylim',[-40 20]);
        end
        end
        
        function close(obj)
        end
        
    end
end


