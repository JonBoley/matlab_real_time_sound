


classdef rt_waveform < rt_visualizer
    
    properties
        stim_buffer;
        %         xzoomout=16;
    end
    
    methods
        function obj=rt_waveform(parent,varargin)
            obj@rt_visualizer(parent,varargin{:});
            obj.fullname='Waveform';
            obj.descriptor='shown is the physical pressure amplitude of the sound waveform as a function of time. The unit on the y-axis is Pascal';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj);
            obj.stim_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth)); %zeros(parent.Fs*obj.plotwidth,1);
            
            ax=obj.viz_axes;
            if ~isempty(ax)
                xlabel(ax,'time (sec)')
                ylabel(ax,'amplitude (Pa)')
            end
        end
        
        function plot(obj,sig)
            buf=obj.stim_buffer;
            global_time=obj.parent.global_time;
            push(buf,sig);
            y=get(buf);
            allx=linspace(global_time,global_time+obj.parent.PlotWidth,length(y));
            pmax=obj.P0*power(10,obj.parent.max_file_level/20); % calibrate this to the assumed maximum amplitude of a wav file
            g=getvalue(obj.p,'zoom');
            ppmax=pmax/g*10;
            
            ax=obj.viz_axes;
            if ~isempty(ax)
                plot(ax,allx,y,'k');
            end
            set(ax,'xlim',[min(allx) max(allx)],'ylim',[-ppmax ppmax]);
        end
    end
end