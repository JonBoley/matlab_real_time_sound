
classdef rt_strobes < rt_visualizer
  
    properties
        strobebuf;
        aimmodel;
        viz_buffer;
        xlab;
        ylab;
    end
    
    
    
    methods
        function obj=rt_strobes(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin{:});
            obj.fullname='Strobes with NAP';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'numberChannels',50);
            addParameter(pars,'lowest_frequency',100);
            addParameter(pars,'highest_frequency',6000);
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            
            add(obj.p,param_number('numberChannels',pars.Results.numberChannels));
            add(obj.p,param_number('lowest_frequency',pars.Results.lowest_frequency));
            add(obj.p,param_number('highest_frequency',pars.Results.highest_frequency));
            add(obj.p,param_float_slider('zoom ',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            
            sample_rate=1/obj.parent.SampleRate;
            num_channels=getvalue(obj.p,'numberChannels');
            lowFreq=getvalue(obj.p,'lowest_frequency');
            highFreq=getvalue(obj.p,'highest_frequency');
            
            
            window_length=obj.parent.FrameLength;
            obj.aimmodel=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
            obj.aimmodel=setmode(obj.aimmodel,'STROBES'); % I only want the strobes.
            
            obj.viz_buffer=circbuf(round(obj.parent.PlotWidth*obj.parent.SampleRate),num_channels);
            
            imagesc(get(obj.viz_buffer)','parent',ax);
            set(ax,'ylim',[1 num_channels]);
            set(ax,'xlim',[1 getlength(obj.viz_buffer)]);
            fs=obj.aimmodel.centre_frequencies;
            
            obj.ylab=get(ax,'YTickLabel');
            for i=1:length(obj.ylab)
                l=fs(str2double(obj.ylab{i}));
                ll{i}=sprintf('%2.2f',l/1000);
            end
            obj.ylab=ll;%(end:-1:1);
            xlabel(ax,'time (sec)')
            ylabel(ax,'frequency (kHz)')
            set(ax,'YTickLabel',obj.ylab);
            
            xt=get(ax,'xtick');
            xtt=xt/window_length*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=num2str(round(xtt(i)*1000)/1000);
            end
            
            for i=1:num_channels % nr channel
                obj.strobebuf{i}=circbuf1(100); % max 100 strobes
            end
            
            setplotwidth(obj.parent,0.05); % otherwise it's too slow!

        end
        
        function plot(obj,sig)
            set(obj.viz_axes,'NextPlot','replaceall');
            
            ax=obj.viz_axes;
            vizbuf=obj.viz_buffer;
            
            [~,nap,cstrobes]=step(obj.aimmodel,sig);
            vizbuf=push(vizbuf,nap');
            
            imagesc(get(vizbuf)','parent',ax);
            view(ax,0,270);
            set(ax,'ylim',[1 size(obj.viz_buffer.data,2)]);
            set(ax,'xlim',[1 size(obj.viz_buffer.data,1)]);
            hold(ax,'on')
            set(ax,'xticklabel',obj.xlab)
            set(ax,'yticklabel',obj.ylab)
            
            
            tg=obj.parent.global_time;
            tfull=obj.parent.PlotWidth;
            toffset=obj.parent.FrameLength/obj.parent.SampleRate;
            sr=obj.parent.SampleRate;
            for ch=1:size(obj.strobebuf,2) % frequency
                ccs=double(cstrobes(ch,cstrobes(ch,:)>0)); % only the ones >0
                x=ccs./sr+tg-toffset;
                push(obj.strobebuf{ch},x);
                xx=get(obj.strobebuf{ch});
                xxp=xx(xx>0);
                t0=tfull-tg;
                xp=t0+xxp;
                s2=xp(xp>0);
                %                 s3=s2(s2>t0);
                if ~isempty(s2)
                    plot(ax,s2*sr,ch,'ro','markerfacecolor','r');
                end
            end
        end
    end
end