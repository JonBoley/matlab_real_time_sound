
classdef rt_stoi < rt_measurer
    properties
        clean_buffer;
        noisy_buffer
        stoi_buffer;
    end
    
    methods
        %% creator
        function obj=rt_stoi(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='STOI (speech intellegibility)';
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
            obj.stoi_buffer=circbuf1(mm);
            
        end
        
        function stoi=calculate(obj,sig)
            
            clean=obj.parent.clean_stim;
            if isempty(obj.parent.clean_stim) % forgot to switch on noise!
                clean=sig;
                disp('STOI needs noise switched on! Taking given stimulus as clean stimulus, result will be close to 1')
            end
            
            
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,clean);
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            ref_data=get(obj.clean_buffer,ll); % get the part during integration tiem
            deg_data=get(obj.noisy_buffer,ll);
            
%             % stoi doesn't like lots of zeros, so if the first 100 values
%             % are zero, just return 0
%             if sum(ref_data(1:10))==0
%                 stoi=0;
%                 return
%             end
%             
            
%   Copyright 2019 Stefan Bleeck, University of Southampton
          
            stoi = mystoi(ref_data, deg_data,fs);
            push(obj.stoi_buffer,stoi);
            
            x=1:getlength(obj.stoi_buffer);
            y=get(obj.stoi_buffer)';
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            set(measax,'ylim',[0 1]);
            
            
        end
        
    end
end


