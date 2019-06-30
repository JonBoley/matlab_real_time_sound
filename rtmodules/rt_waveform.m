%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_waveform < rt_visualizer
    
    properties
        stim_buffer;
        x_vals
    end
    
    methods
        function obj=rt_waveform(parent,varargin)
            obj@rt_visualizer(parent,varargin{:});
            obj.fullname='Waveform';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
            
            obj.descriptor='shown is the physical pressure amplitude of the sound waveform as a function of time. The unit on the y-axis is Pascal';
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj);
            obj.stim_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth)); %zeros(parent.Fs*obj.plotwidth,1);
            
            ax=obj.viz_axes;
            if ~isempty(ax)
                xlabel(ax,'time (sec)')
                ylabel(ax,'amplitude (Pa)')
            end
            obj.x_vals=0:1/obj.parent.SampleRate:obj.parent.PlotWidth-1/obj.parent.SampleRate;
            %             pmax=obj.P0*power(10,obj.parent.max_file_level/20); % calibrate this to the assumed maximum amplitude of a wav file
            g=getvalue(obj.p,'zoom');
            ppmax=2/g;
            set(ax,'xlim',[min(obj.x_vals) max(obj.x_vals)],'ylim',[-ppmax ppmax]);
            
        end
        
        function plot(obj,sig)
            buf=obj.stim_buffer;
            %             global_time=obj.parent.global_time;
            push(buf,sig);
            y=get(buf);
            y=y(1:length(obj.x_vals));
            %             allx=linspace(global_time,global_time+obj.parent.PlotWidth,length(y));
            g=getvalue(obj.p,'zoom');
            ppmax=2/g; % 100 dB
            
            ax=obj.viz_axes;
            if ~isempty(ax)
                plot(ax,obj.x_vals,y,'k');
                set(ax,'ylim',[-ppmax ppmax]);
                
            end
        end
    end
end