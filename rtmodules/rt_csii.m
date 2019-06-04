
classdef rt_csii < rt_measurer
    properties
        clean_buffer;
        noisy_buffer;
        csii_buffer;
    end
    
    methods
        %% creator
        function obj=rt_csii(parent,varargin)
            obj@rt_measurer(parent,varargin{:});
            obj.fullname='CSII: Coherence and speech intelligibility index';
            pre_init(obj);  % add the parameter gui
                 pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',1);
            parse(pars,varargin{:});
            add(obj.p,param_number('integrationPeriod',pars.Results.integrationPeriod));
            
        end
        
       function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.csii_buffer=circbuf1(mm);
            
        end
        
        function csii=calculate(obj,sig)
        clean=obj.parent.clean_stim;
            if isempty(obj.parent.clean_stim) % forgot to switch on noise!
                clean=sig;
                disp('HASPI needs noise switched on! Taking given stimulus as clean stimulus, result will be close to 1')
            end
            
            
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,clean);
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            ref_data=get(obj.clean_buffer,ll); % get the part during integration tiem
            deg_data=get(obj.noisy_buffer,ll);
            
            
            csii = my_CSII(ref_data, deg_data,fs);
            push(obj.csii_buffer,csii);

            x=1:getlength(obj.csii_buffer);
            y=get(obj.csii_buffer);
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            
        end
        
        function close(obj)
        end
        
    end
end


