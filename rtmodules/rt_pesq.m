
classdef rt_pesq < rt_measurer
    properties
        clean_buffer;
        noisy_buffer
        pesq_buffer
    end
    
    methods
        %% creator
        function obj=rt_pesq(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='PESQ (speech quality)';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'gain',1);
            addParameter(pars,'integrationPeriod',0.5);  % buffer for computation MUST be >0.4 sec!
            parse(pars,varargin{:});
            add(obj.p,param_slider('gain',pars.Results.gain,'minvalue',-20, 'maxvalue',20));
            add(obj.p,param_float('integrationPeriod',pars.Results.integrationPeriod));
            
            %
            %             if nargin <2
            %                 name='PESQ (speech quality)';
            %             end
            %             obj@measurer(parent,name);  %% initialize superclass first
            %
            %             obj.parent=parent;
            %
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.pesq_buffer=circbuf1(mm);
        end
        
        function pesq_mos=calculate(obj,sig)
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,obj.parent.clean_stim);
            push(obj.noisy_buffer,sig);
            
            ref_data=get(obj.clean_buffer);
            deg_data=get(obj.noisy_buffer);
            
            % haspi doesn't like lots of zeros, so if the first 100 values
            % are zero, just return 0
            if sum(ref_data(1:10))==0
                pesq_mos=0;
                return
            end
            
            
            pesq_mos = my_pesq(ref_data, deg_data,fs);
            
            push(obj.pesq_buffer,pesq_mos);
            
            x=1:getlength(obj.pesq_buffer);
            y=get(obj.pesq_buffer);
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            
            
        end
    end
end


