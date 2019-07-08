%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_sai < rt_visualizer
    
    properties
        aimmodel;
        buffer;
        xlab;
        ylab;
        
        sai;
        last_update; % timer setting when last updated
        
        % for debugging
        napbuffer;
        threshbuf;
        strobebuf;
        
    end
    
    
    methods
        function obj=rt_sai(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin{:});
            
            obj.fullname='Stabilized auditory image';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            
            addParameter(pars,'numberChannels',50);
            addParameter(pars,'lowest_frequency',100);
            addParameter(pars,'highest_frequency',6000);
            addParameter(pars,'logscale',1);
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            
            add(obj.p,param_number('numberChannels',pars.Results.numberChannels));
            add(obj.p,param_number('lowest_frequency',pars.Results.lowest_frequency));
            add(obj.p,param_number('highest_frequency',pars.Results.highest_frequency));
            add(obj.p,param_checkbox('logscale',pars.Results.logscale));
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
            
            
            s='stabilized auditory image represents graphically the activity in the auditory brainstem';
            s=[s,'accoding to the auditory image model'];
            s=[s,'implementation by Stefan Bleeck and followig the paper:'];
            s=[s,'Bleeck, Stefan, Ives, Tim and Patterson, Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica, 90 (4), 781-787.'];
            
            
            obj.descriptor=s;
            
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj);
            vax=obj.viz_axes;
            ax2=obj.measurement_axis;
            
            
            sample_rate=1/obj.parent.SampleRate;
            num_channels=getvalue(obj.p,'numberChannels');
            lowFreq=getvalue(obj.p,'lowest_frequency');
            highFreq=getvalue(obj.p,'highest_frequency');
            
            window_length=obj.parent.FrameLength;
            obj.aimmodel=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
            obj.aimmodel=setmode(obj.aimmodel,'SAI');
            obj.buffer=circbuf(round(0.035*obj.parent.SampleRate),num_channels);
            obj.parent.PlotWidth=0.035;
            
            if ~isempty(vax)
                set(vax,'NextPlot','replaceall');
                dat=get(obj.buffer)';
                if num_channels>1
                    imagesc(dat,'parent',vax);
                    set(vax,'ylim',[1 num_channels]);
                    if getvalue(obj.p,'logscale')  % we want the x-axis to be logarithmically
                        set(vax,'xlim',[1 200]);
                    else
                        set(vax,'xlim',[1 getlength(obj.buffer)]);
                    end
                    fs=obj.aimmodel.centre_frequencies;
                    
                    obj.ylab=get(vax,'YTickLabel');
                    for i=1:length(obj.ylab)
                        l=fs(str2double(obj.ylab{i}));
                        ll{i}=sprintf('%2.2f',l/1000);
                    end
                    obj.ylab=ll;%(end:-1:1);
                    xlabel(vax,'time (msec)')
                    ylabel(vax,'frequency (kHz)')
                    set(vax,'YTickLabel',obj.ylab);
                    
                    if getvalue(obj.p,'logscale')  % we want the x-axis to be logarithmically
                        xt=get(vax,'xtick');
                        xtt=xt/200*obj.parent.PlotWidth;
                        for i=1:length(xt)
                            obj.xlab{i}=sprintf('%2.1f',xtt(i)*1000);
                        end
                        set(vax,'xticklabel',obj.xlab); 
                    else
                        xt=get(vax,'xtick');
                        xtt=xt/getlength(obj.buffer)*obj.parent.PlotWidth;
                        for i=1:length(xt)
                            obj.xlab{i}=sprintf('%2.1f',xtt(i)*1000);
                        end
                        set(vax,'xticklabel',obj.xlab);
                    end
                    % create an interesting color map: from white to black
                    %                     c=colormap(vax);
                    %                     nr_colors=100;
                    %                     c(:,:)=1; % first make all white
                    %                     c(1:nr_colors,1)=linspace(1,0,nr_colors);
                    %                     c(1:nr_colors,2)=linspace(1,0,nr_colors);
                    %                     c(1:nr_colors,3)=linspace(1,0,nr_colors);
                    %                     colormap(vax,c);
                    colormap(vax,parula(128));
                    
                    
                    view(vax,0,270);
                    set(vax,'CLim',[0 128])
                    
                else % only one channel: for debugging
                    cla(vax,'reset');
                    obj.napbuffer=circbuf1(0.1*obj.parent.SampleRate);  %
                    obj.threshbuf=circbuf1(0.1*obj.parent.SampleRate);  %
                    obj.strobebuf=circbuf1(0.1*obj.parent.SampleRate);  %
                end
            end
            
            if ~isempty(ax2)
                cla(ax2,'reset')
            end
            obj.last_update=-inf;
            
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
            vax=obj.viz_axes;
            
            % this is an (ugly) shortcut to stop operation when called from
            % a sript. I only want to see the measurement results, but
            % can't stop it from trying to run the plot function
            if isempty(vax)
                return
            end
            
            % we are not sure which one is running, vizualization or
            % measurement, therefore we need to find out if we need to
            % update the sai-model
            if obj.last_update <obj.parent.global_time
                [~,nap,strobes,sai]=step(obj.aimmodel,sig);
                obj.last_update=obj.parent.global_time;
                obj.sai=sai;
            else
                sai=obj.sai;
            end
            
            if getvalue(obj.p,'logscale')  % we want the x-axis to be logarithmically
                
                z=getvalue(obj.p,'zoom');
                %                     sai=sai.*z*40;
                %                     image(sai,'parent',vax);
                %                     view(vax,0,270);
                
                
                fs=1/obj.aimmodel.sample_rate;
                disp_freq=logspace(log10(50),log10(1000),200); % 100 frequencies between 50 and 1000 Hz
                
                % time axis of profile in hz
                tx1=1./[1:size(sai,2)]*fs;
                ttx1=zeros(size(disp_freq)); %memalloc
                % x-values in temp profile according to disp_fre:
                for i=1:length(disp_freq)
                    ttx1(i)=find(tx1<=disp_freq(i),1,'first');
                end
                sai2=zeros(size(sai,1),length(disp_freq));
                for i=1:length(ttx1)
                    sai2(:,i)=sai(:,ttx1(i));
                end
                sai2=sai2(:,end:-1:1);
                image(sai2*40*z,'parent',vax);
                view(vax,0,270);
            else
                
                if getvalue(obj.p,'numberChannels')>1
                    z=getvalue(obj.p,'zoom');
                    sai=sai.*z;
                    image(sai,'parent',vax);
                    view(vax,0,270);
                else
                    cla(vax);
                    push(obj.napbuffer,nap);
                    y=get(obj.napbuffer);
                    
                    plot(vax,y);
                    hold(vax,'on')
                    t=obj.aimmodel.strobesmod.threshsave;
                    push(obj.threshbuf,t);
                    y2=get(obj.threshbuf);
                    plot(vax,y2,'g');
                    
                    strob=strobes(strobes>0);
                    
                    sbuf=zeros(size(nap));
                    sbuf(strob)=nap(strob);
                    push(obj.strobebuf,sbuf);
                    y3=get(obj.strobebuf);
                    plot(vax,y3,'ro')
                    
                    set(vax,'ylim',[0 50]);
                    set(vax,'xlim',[1 getlength(obj.strobebuf)]);
                end
            end
                
        end
    end
end