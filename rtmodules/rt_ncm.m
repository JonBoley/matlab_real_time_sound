
classdef rt_ncm < rt_measurer
    properties
        noisy_buffer;
        ncm_buffer;
        clean_buffer
    end
    
    methods
        %% creator
        function obj=rt_ncm(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='NCM';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',0.5);  % buffer for computation MUST be >0.4 sec!
            parse(pars,varargin{:});
            add(obj.p,param_float('integrationPeriod',pars.Results.integrationPeriod));
            
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.ncm_buffer=circbuf1(mm);
        end
        
        function ncm_val=calculate(obj,sig)
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,obj.parent.clean_stim);
            push(obj.noisy_buffer,sig);
            
            ref_data=get(obj.clean_buffer);
            deg_data=get(obj.noisy_buffer);
            
            %             Sampling frequency for NCM needs to be either 8000 or 16000 Hz
            ref_data=resample(ref_data,16000,fs);
            deg_data=resample(deg_data,16000,fs);
            
            ncm_val= NCM(ref_data, deg_data,16000);
            
            push( obj.ncm_buffer,ncm_val);
            
            x=1:getlength(obj.ncm_buffer);
            y=get(obj.ncm_buffer);
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
        end
        
        function close(obj)
        end
        
    end
end


