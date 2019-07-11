%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% calculate the pitch strength (and pitches) using the auditory image model

classdef rt_sai_ps < rt_measurer
    
    properties
        aimmodel;
        buffer;
        xlab;
        ylab;
        
        f_p_buf; % frequency pitch buffer
        f_ps_buf; % frequency pitchstrength buffer
        t_p_buf; % temp pitch buffer
        t_ps_buf; % temp pitchstrength buffer

        % for debugging
        napbuffer;
        threshbuf;
        strobebuf;
        
        sai;
        
    end
    
    
    methods
        function obj=rt_sai_ps(parent,varargin)  %init
            obj@rt_measurer(parent,varargin{:});
            
            obj.fullname='Stabilized auditory image';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            
            addParameter(pars,'numberChannels',50);
            addParameter(pars,'lowest_frequency',100);
            addParameter(pars,'highest_frequency',6000);
            meastype={'fast';'slow'};
            addParameter(pars,'MeasureDisplay',meastype{1});
            parse(pars,varargin{:});
            
            add(obj.p,param_number('numberChannels',pars.Results.numberChannels));
            add(obj.p,param_number('lowest_frequency',pars.Results.lowest_frequency));
            add(obj.p,param_number('highest_frequency',pars.Results.highest_frequency));
            add(obj.p,param_popupmenu('MeasureDisplay',pars.Results.MeasureDisplay,'list',meastype));
            
            
            s='stabilized auditory image represents graphically the activity in the auditory brainstem';
            s=[s,'accoding to the auditory image model'];
            s=[s,'implementation by Stefan Bleeck and followig the paper:'];
            s=[s,'Bleeck, Stefan, Ives, Tim and Patterson, Roy D. (2004) Aim-mat: the auditory image model in MATLAB. Acta Acustica united with Acustica, 90 (4), 781-787.'];
            s=[s,'Here we are using the SAI to estimate current pitch and pitch strength'];
            
            obj.descriptor=s;
            
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_measurer(obj);
            ax2=obj.measurement_axis;
            
            
            sample_rate=1/obj.parent.SampleRate;
            num_channels=getvalue(obj.p,'numberChannels');
            lowFreq=getvalue(obj.p,'lowest_frequency');
            highFreq=getvalue(obj.p,'highest_frequency');
            
            window_length=obj.parent.FrameLength;
            obj.aimmodel=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
            obj.aimmodel=setmode(obj.aimmodel,'SAI');
            obj.buffer=circbuf(round(0.035*obj.parent.SampleRate),num_channels);
            
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.t_p_buf=circbuf1(mm);
            obj.t_ps_buf=circbuf1(mm);
            obj.f_p_buf=circbuf1(mm);
            obj.f_ps_buf=circbuf1(mm);
            
            
            if ~isempty(ax2)
                cla(ax2,'reset')
            end
            
        end
        
        
        
        % calculate the dual profile!
        function pitch=calculate(obj,sig)
            
            [~,nap,strobes,sai]=step(obj.aimmodel,sig);
            obj.sai=sai;  % save for later
            
            fs=obj.parent.SampleRate;
            
            temp_profile=sum(sai,1);   % temporal profile
            freq_profile=sum(sai,2);  % frequency profile
            
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
                        pitch.temp_pitches=tloc(i);
                        pitch.temp_strengthes=tp(i);
                    end
                end
            end
            
            
            % frequency peak second
            [fpks,floc,fw,fp]=findpeaks(freq_pr_hz,'SortStr','descend','MinPeakProminence',0.2);
            % the width depends on log frequency, so we need to calculate
            % with q-values instead:
            fqs=log(floc).*fw;
            
            floc=disp_freq(floc);
            fpks=double(fpks);
            
            
            found=0;
            pitch.pitch=0;
            pitch.strength=0;
            for i=1:length(fpks)
                %                 if tw(i)<20 && tp(i)>0.2
                if fqs(i)>20 && fw(i)<20 && fp(i)>0.2
                    if ~found
                        found=1;
                        pitch.freq_pitches=floc(i);
                        pitch.freq_strengthes=fp(i);
                    end
                end
            end
            
            
            % calculate the final ONE value of the predicted pitch and
            % pitch strengths for temporal and frequency pitch
            if ~isempty(tloc) && ~isempty(tloc)
                temp_pitch=tloc(1);
                temp_strength=tp(1);
            else
                temp_pitch=0;
                temp_strength=0;
            end
            if ~isempty(floc) 
                freq_pitch=floc(1);
                freq_strengh=fp(1);
            else
                freq_pitch=0;
                freq_strengh=0;
            end
            
            
            push(obj.t_p_buf,temp_pitch);
            push(obj.t_ps_buf,temp_strength);
            push(obj.f_p_buf,freq_pitch);
            push(obj.f_ps_buf,freq_strengh);
            
            
            meax=obj.measurement_axis;
            
            if ~isempty(meax)
                
                type=getvalue(obj.p,'MeasureDisplay');
                switch type
                    case 'slow'
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
                    case 'fast'
                        x=1:getlength(obj.f_ps_buf);
                        y1=get(obj.f_p_buf);
                        y2=get(obj.f_ps_buf)*100;
                        y3=get(obj.t_p_buf);
                        y4=get(obj.t_ps_buf)*100;

                        plot(meax,x,y1,'r.',x,y2,'g.',x,y3,'b.',x,y4,'k.');
%                         set(meax,'xlim',[0 length(x)],'ylim',[0 20]);
                        legend(meax,{'frequency pitch','frequency pitch strength','temporal pitch','temporal pitch srength'},'location','southeast');
                end
            end
        end
    end
end