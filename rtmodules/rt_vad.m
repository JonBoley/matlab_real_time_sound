
classdef rt_vad < rt_waveform
    
    properties
        vadbuffer;
        %         VAD_cst_param;
        myVAD;
    end
    
    methods
        function obj=rt_vad(parent,varargin)  %init  
             obj@rt_waveform(parent,varargin{:});
            obj.fullname='Voice Activity Detection';
            
             pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'FFTLength',256);
            addParameter(pars,'Window','Hann');
            addParameter(pars,'SidelobeAttenuation',60);
            addParameter(pars,'SilenceToSpeechProbability',0.2);
            addParameter(pars,'SpeechToSilenceProbability',0.1);

            parse(pars,varargin{:});
            
            add(obj.p,param_number('FFTLength',pars.Results.FFTLength));
            add(obj.p,param_generic('Window',pars.Results.Window));
            add(obj.p,param_number('SidelobeAttenuation',pars.Results.SidelobeAttenuation));
            add(obj.p,param_number('SilenceToSpeechProbability',pars.Results.SilenceToSpeechProbability));
            add(obj.p,param_number('SpeechToSilenceProbability',pars.Results.SpeechToSilenceProbability));
           
        end
        
        function obj=post_init(obj) % called the second times around
            post_init@rt_waveform(obj);
            
            obj.myVAD = voiceActivityDetector( ...
                'FFTLength',getvalue(obj.p,'FFTLength'),...
                'Window',getvalue(obj.p,'Window'),...
                'SilenceToSpeechProbability',getvalue(obj.p,'SilenceToSpeechProbability'),...
                'SpeechToSilenceProbability',getvalue(obj.p,'SpeechToSilenceProbability'));
            
            obj.vadbuffer=circbuf1(obj.parent.SampleRate*obj.parent.PlotWidth);
            
            set(obj.viz_axes,'NextPlot','replace all');
            %             % Initialize VAD parameters
            %             obj.VAD_cst_param = vadInitCstParams;
            %             clear vadG729
            
            
            
            %             % check if we have a long enough frame length (we need 80!). If not, adjust it:
            %             sr=obj.parent.Fs;
            %             nrneeded=ceil(80/8000*sr);
            %             if nrneeded>obj.parent.frame_length
            %                 disp(fprintf('need more frame length! %d',nrneeded));
            %             end
        end
        
        function plot(obj,sig)

            if has_changed(obj.p)
                obj=post_init(obj);
                set_changed_status(obj.p,0);
            end
            
            set(obj.viz_axes,'NextPlot','replaceall');
            
            plot@rt_waveform(obj,sig);
            
            
            ax=obj.viz_axes;
            buf=obj.vadbuffer;
            hold(ax,'on')
            
            
            global_time=obj.parent.global_time;
            Fs=obj.parent.SampleRate;
            
            [probability,~] = obj.myVAD(sig);
            push(buf,ones(size(sig))*probability);
            
            
            
            
            %             a=resample(sig,8000,obj.parent.Fs);
            %             b=a(1:80);
            %             decision = vadG729(b, obj.VAD_cst_param);
            %
            %             if decision==1
            %                 obj.vadbuffer=push(obj.vadbuffer,sig);
            %             else
            %                 obj.vadbuffer=push(obj.vadbuffer,zeros(size(sig)));
            %             end
            allx=global_time:1/Fs:global_time+obj.parent.PlotWidth-1/Fs;
            plot(ax,allx,get(buf),'r');
            
        end
    end
end