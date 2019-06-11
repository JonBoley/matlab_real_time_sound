%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_asl < rt_measurer
    properties
%         clean_buffer;
        noisy_buffer;
        asl_buffer;
    end
    
    methods
        %% creator
        function obj=rt_asl(parent,varargin)
            obj@rt_measurer(parent,varargin{:});
            obj.fullname='ASL: active speech level';
            pre_init(obj);  % add the parameter gui
                 pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',1);
            parse(pars,varargin{:});
            add(obj.p,param_number('integrationPeriod',pars.Results.integrationPeriod));
            
            s='active speech level described is the perceived instantaneous level of speech sounds';
            s=[s,'in https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-P.56-201112-I!!PDF-E&type=items.'];
            s=[s,'Active speech level measurement following ITU-T P.56 Author: Lu Huo, LNS/CAU, December, 2005, Kiel.'];
            obj.descriptor=s;
            
        end
        
       function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.asl_buffer=circbuf1(mm);
            
        end
        
        function ActiveSpeechLevel=calculate(obj,sig)
                    
            fs=obj.parent.SampleRate;
            
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            deg_data=get(obj.noisy_buffer,ll);
            
            
            ActiveSpeechLevel=asl_meter(deg_data,fs);
            push(obj.asl_buffer,ActiveSpeechLevel);

            x=1:getlength(obj.asl_buffer);
            y=get(obj.asl_buffer);
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            set(measax,'ylim',[-35 0],'xlim',[1 length(x)]);
            
        end
        
        function close(obj)
        end
        
    end
end


