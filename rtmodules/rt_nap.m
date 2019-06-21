%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_nap < rt_visualizer
    
    properties
        aimmodel;
        nap_buffer;
        xlab;
        ylab;
            end
    
    methods
        function obj=rt_nap(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin{:});
            obj.fullname='Neural activity pattern';
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
            
            s='neural activity pattern represents graphically the activity in the auditory brainstem';
            s=[s,'accoding to the auditory image model'];
            s=[s,'implementation by Stefan Bleeck and followig the paper:'];
            s=[s,'Bleeck, Stefan, Ives, Tim and Patterson, Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica, 90 (4), 781-787.'];
            obj.descriptor=s;
            
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            
            num_channels=getvalue(obj.p,'numberChannels');
            lowfre=getvalue(obj.p,'lowest_frequency');
            highfre=getvalue(obj.p,'highest_frequency');
            
            sample_rate=1/obj.parent.SampleRate;
            
            
            window_length=obj.parent.FrameLength;
            obj.aimmodel=caim(sample_rate,num_channels,lowfre,highfre,window_length);
            obj.aimmodel=setmode(obj.aimmodel,'NAP'); % I only want the NAP.
            
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
            set(ax,'YTickLabel',obj.ylab);
            
            xt=get(ax,'xtick');
            xtt=xt/getlength(obj.nap_buffer)*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=sprintf('%2.2f',xtt(i));
            end
              % create an interesting color map: from white to black
% nr_colors=100;
%                     c(:,:)=1; % first make all white
%                     c(1:nr_colors,1)=linspace(1,0,nr_colors);
%                     c(1:nr_colors,2)=linspace(1,0,nr_colors);
%                     c(1:nr_colors,3)=linspace(1,0,nr_colors);
%                     colormap(vax,c);
            
            colormap(ax,parula(128));
            view(ax,0,270);
            set(ax,'CLim',[0 64])
            
            set(ax,'xticklabel',obj.xlab)
            set(ax,'yticklabel',obj.ylab)
        end
        
        function plot(obj,sig)
            
            if has_changed(obj.p)
                p1=getparameter(obj.p,'numberChannels');
                p2=getparameter(obj.p,'lowest_frequency');
                p3=getparameter(obj.p,'highest_frequency');
                if has_changed(p1) || has_changed(p2)|| has_changed(p3)
                    post_init(obj);
                    set_changed_status(obj.p,0);
                end
            end
            
            
            ax=obj.viz_axes;
            [~,nap]=step(obj.aimmodel,sig);
            push(obj.nap_buffer,nap');
            vals=get(obj.nap_buffer)'; % vals come with values between 0 and 1
            vals=vals.*128;
            z=getvalue(obj.p,'zoom ');
            vals=vals.*z;
            image(vals,'parent',ax);
%    max(max(vals))
        end
     
    end
end