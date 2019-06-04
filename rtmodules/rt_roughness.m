
classdef rt_roughness < rt_measurer
    properties
        stim_buffer;
        roughness_buffer;
    end
    
    methods
        %% creator
        function obj=rt_roughness(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='Roughness - fluctuation strength';
            obj.descriptor='from the psysoundpro toolbox (https://sourceforge.net/projects/psysoundpro/)';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            %             addParameter(pars,'waitPeriod',0);
            parse(pars,varargin{:});
            %             add(obj.p,param_number('waitPeriod',pars.Results.waitPeriod));
        end
        
        function obj=post_init(obj)
            post_init@rt_measurer(obj);
            obj.stim_buffer=circbuf1(obj.parent.SampleRate);  % 1 sec
            obj.roughness_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength));
        end
        
        function roughness=calculate(obj,sig)
            
            if sum(get(obj.stim_buffer))==0 %here for the very first time!
                obj.measuring_start_time=obj.parent.global_time;
            end
            
            
            fs=obj.parent.SampleRate;
            
            push(obj.stim_buffer,sig);
            ref_data=get(obj.stim_buffer);
            
            % wait for a second before starting to measure:
            %             if wait_time(obj)>getvalue(obj.p,'waitPeriod')
            
            % roughness implementiaton from University of Salford. Requires
            % 44.1 kHz and exaclty 8192 data points
            updata=resample(ref_data,44100,fs);
            magic_number=8192;
            windata=updata(end-magic_number+1:end);
            roughness_all =roughext(windata,44100);
            roughness=roughness_all{1};
            push(obj.roughness_buffer,roughness);
            
            x=1:getlength(obj.roughness_buffer);
            y=get(obj.roughness_buffer);
            measax=obj.measurement_axis;
            
            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                plot(measax,x,y,'.-');
            end
        end
        
        function close(obj)
        end
        
    end
end


