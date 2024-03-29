%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_strobes < rt_visualizer
    
    properties
        strobebuf;
        aimmodel;
        nap_buffer;
        xlab;
        ylab;
        xt_start=0;
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
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
            
            
           s='stabilized auditory image represents graphically the activity in the auditory brainstem';
            s=[s,'accoding to the auditory image model.'];
            s=[s,'This module shows the strobes'];
            s=[s,'implementation by Stefan Bleeck and followig the paper:'];
            s=[s,'Bleeck, Stefan, Ives, Tim and Patterson, Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica, 90 (4), 781-787.'];
            obj.descriptor=s;
            
            
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            %             setPlotWidth(obj.parent,0.03);
            
            sample_rate=1/obj.parent.SampleRate;
            num_channels=getvalue(obj.p,'numberChannels');
            lowFreq=getvalue(obj.p,'lowest_frequency');
            highFreq=getvalue(obj.p,'highest_frequency');
            
            
            window_length=obj.parent.FrameLength;
            obj.aimmodel=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
            obj.aimmodel=setmode(obj.aimmodel,'STROBES'); % I only want the strobes.
            
            obj.nap_buffer=circbuf(round(obj.parent.PlotWidth*obj.parent.SampleRate),num_channels);
            
            imagesc(get(obj.nap_buffer)','parent',ax);
            set(ax,'ylim',[1 num_channels]);
            set(ax,'xlim',[1 getlength(obj.nap_buffer)]);
            fs=obj.aimmodel.centre_frequencies;
            
            obj.ylab=get(ax,'YTickLabel');
            for i=1:length(obj.ylab)
                l=fs(str2double(obj.ylab{i}));
                ll{i}=sprintf('%2.2f',l/1000);
            end
            obj.ylab=ll;%(end:-1:1);
            xlabel(ax,'time (sec)')
            ylabel(ax,'frequency (kHz)')
            
            xt=get(ax,'xtick');
            xtt=xt/getlength(obj.nap_buffer)*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=sprintf('%2.2f',xtt(i));
            end
            obj.strobebuf=circbuf1.empty;
            for i=1:num_channels % nr channel
                obj.strobebuf(i)=circbuf1(100); % max 100 strobes
            end
            
            
            colormap(ax,parula(128));
            view(ax,0,270);
            set(ax,'CLim',[0 64])
            
            set(ax,'xticklabel',obj.xlab)
            set(ax,'yticklabel',obj.ylab)
            obj.xt_start=getlength(obj.nap_buffer);
        end
        
        function plot(obj,sig)
            set(obj.viz_axes,'NextPlot','replaceall');
            
            
            ax=obj.viz_axes;
            [~,nap,cstrobes]=step(obj.aimmodel,sig);
            push(obj.nap_buffer,nap');
            vals=get(obj.nap_buffer)';
            z=getvalue(obj.p,'zoom');
            random_calibrtion_value=2;
            vals=vals.*random_calibrtion_value;
            vals=vals.*z;
            image(vals,'parent',ax);
            
            view(ax,0,270);
            set(ax,'ylim',[1 size(obj.nap_buffer.data,2)]);
            set(ax,'xlim',[1 size(obj.nap_buffer.data,1)]);
            hold(ax,'on')
            set(ax,'xticklabel',obj.xlab)
            set(ax,'yticklabel',obj.ylab)
            
            tfull=ceil(obj.parent.PlotWidth*obj.parent.SampleRate);
            toffset=obj.parent.FrameLength;
            strobx=zeros(size(obj.strobebuf,2)*100,1);
            stroby=zeros(size(obj.strobebuf,2)*100,1);
            obj.xt_start=obj.xt_start-toffset; % defines the zero point for the strobes (going left)
            
            for ch=1:size(obj.strobebuf,2) % frequency
                add(obj.strobebuf(ch),-toffset); % shift all existing spikes to the left
            end
            
            for ch=1:size(obj.strobebuf,2) % frequency
                ccs=double(cstrobes(ch,cstrobes(ch,:)>0)); % only the ones >0
                x=tfull-toffset+ccs;  % always fill up the buffer on the right
                push(obj.strobebuf(ch),x);
            end
            
            c=1;
            for ch=1:size(obj.strobebuf,2) % frequency
                xx=get(obj.strobebuf(ch));
                s2=xx(xx>0);
                if ~isempty(s2)
                    stroby(c:c+length(s2)-1)=ch;
                    strobx(c:c+length(s2)-1)=s2;
                    c=c+length(s2)-1;
                end
            end
            
            strobx=strobx(strobx>0);
            stroby=stroby(stroby>0);
            plot(ax,strobx,stroby,'ro','markerfacecolor','r');
            
        end
    end
end