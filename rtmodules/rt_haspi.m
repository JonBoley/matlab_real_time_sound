
classdef rt_haspi < rt_measurer
    properties
        clean_buffer;
        noisy_buffer
        haspi_buffer;
    end
    
    methods
        %% creator
        function obj=rt_haspi(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='HASPI (impaired speech intellegibility) VERY SLOW';
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
               obj.haspi_buffer=circbuf1(mm);
            
        end
        
        function haspi=calculate(obj,sig)
            
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
            
            % haspi doesn't like lots of zeros, so if the first 100 values
            % are zero, just return 0
            if sum(ref_data(1:10))==0
                haspi=0;
                return
            end
            
            
            
            Level1=65;
            % HL		(1,6) vector of hearing loss at the 6 audiometric frequencies
            %			  [250, 500, 1000, 2000, 4000, 6000] Hz.
            HL=[0,10,15,20,25,30];
            haspi = HASPI_v1(ref_data,fs,deg_data,fs,HL,Level1);
            push(obj.haspi_buffer,haspi);
            
            x=1:getlength(obj.haspi_buffer);
            y=get(obj.haspi_buffer)';
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            % set(measax,'ylim',[0 1]);
            
            
        end
    end
end


