%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_sai < rt_visualizer & rt_measurer
    
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
            obj@rt_measurer(parent,varargin{:});
            
            obj.fullname='Stabilized auditory image';
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
            s=[s,'accoding to the auditory image model'];
            s=[s,'implementation by Stefan Bleeck and followig the paper:'];
            s=[s,'Bleeck, Stefan, Ives, Tim and Patterson, Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica, 90 (4), 781-787.'];
            
            
           obj.descriptor=s; 
        
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj);
            post_init@rt_measurer(obj);
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
                    set(vax,'xlim',[1 getlength(obj.buffer)]);
                    fs=obj.aimmodel.centre_frequencies;
                    
                    obj.ylab=get(vax,'YTickLabel');
                    for i=1:length(obj.ylab)
                        l=fs(str2double(obj.ylab{i}));
                        ll{i}=sprintf('%2.2f',l/1000);
                    end
                    obj.ylab=ll;%(end:-1:1);
                    xlabel(vax,'time (sec)')
                    ylabel(vax,'frequency (kHz)')
                    set(vax,'YTickLabel',obj.ylab);
                    
                    xt=get(vax,'xtick');
                    xtt=xt/getlength(obj.buffer)*obj.parent.PlotWidth;
                    for i=1:length(xt)
                        obj.xlab{i}=sprintf('%2.1f',xtt(i)*1000);
                    end
                    set(vax,'xticklabel',obj.xlab);
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
            
            if getvalue(obj.p,'numberChannels')>1
                z=getvalue(obj.p,'zoom');
                sai=sai.*z*40;
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
        
        
        % calculate the dual profile!
        function pitch=calculate(obj,sig)
            if obj.last_update <obj.parent.global_time
                [~,nap,strobes,sai]=step(obj.aimmodel,sig);
                obj.last_update=obj.parent.global_time;
                obj.sai=sai;
            else
                sai=obj.sai;
            end            %
            
            fs=obj.parent.SampleRate;
            
            temp_profile=sum(sai);   % temporal profile
            freq_profile=sum(sai');  % frequency profile
            
            % bring them on the same axis:
            disp_freq=logspace(log10(50),log10(1000),200); % 100 frequencies between 50 and 1000 Hz
            
            % time axis of profile in hz
            tx1=1./[1:length(temp_profile)]*fs;
            ttx1=zeros(size(disp_freq)); %memalloc
            % x-values in temp profile according to disp_fre:
            for i=1:length(disp_freq)
                ttx1(i)=find(tx1<=disp_freq(i),1,'first');
            end
            temp_pr_hz=temp_profile(ttx1);
            
            % and do the same for the frequency axis:
            tx2=obj.aimmodel.centre_frequencies;
            ttx2=zeros(size(disp_freq)); %memalloc
            % x-values in temp profile according to disp_fre:
            for i=1:length(disp_freq)
                ttx2(i)=find(tx2>=disp_freq(i),1,'first');
            end
            freq_pr_hz=freq_profile(ttx2);
            
            % calibration:
            temp_pr_hz=temp_pr_hz/max(temp_pr_hz);
            freq_pr_hz=freq_pr_hz/max(freq_pr_hz);
            
            
            
            
            % now find the peaks and define pitch and pitch strength\
            
            % temporal peak first
            [tpks,tloc,tw,tp]=findpeaks(temp_pr_hz,'SortStr','descend','MinPeakProminence',0.2);
            
            % the width depends on log frequency, so we need to calculate
            % with q-values instead:
            tqs=log(tloc).*tw;
            
            tloc=disp_freq(tloc);
            tpks=double(tpks);
            
            
            found=0;
            pitch.pitch=0;
            pitch.strength=0;
            for i=1:length(tpks)
                %                 if tw(i)<20 && tp(i)>0.2
                if tqs(i)>20 && tw(i)<20 && tp(i)>0.2
                    if ~found
                        found=1;
                        pitch.pitch=tloc(i);
                        pitch.strength=tp(i);
                    end
                end
            end
            
            
            
            meax=obj.measurement_axis;
            
            if ~isempty(meax)
                cla(meax);
                plot(meax,disp_freq,temp_pr_hz,'b.-');
                hold(meax,'on');
                plot(meax,disp_freq,freq_pr_hz,'r.-');
                
                set(meax,'xscale','log')
                set(meax,'ylim',[0 1.1],'xlim',[min(disp_freq) max(disp_freq)]);
                
                %             xtl=logspace(log10(50),log10(1000),10);
                xtl=[50 75 100 150 200 300 500 750];
                set(meax,'xtick',xtl);
                
                if length(tloc)>0
                    plot(meax,tloc,tpks,'og','markerfacecolor','g')
                    legend(meax,{'temporal pitch','frequency pitch','peak candidates'},'location','southeast');
                end
                
                
                for i=1:length(tpks)
                    %                 if tw(i)<20 && tp(i)>0.2
                    if tqs(i)>20 && tw(i)<20 && tp(i)>0.2
                        s=sprintf('%3.1f Hz: ps:%2.2f',tloc(i),tp(i));
                        text(meax,tloc(i)*1.01,tpks(i)+0.05,s);
                    end
                end
                
            end
        end
    end
end