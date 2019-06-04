
classdef rt_spectrum < rt_visualizer & no_show
    
    properties
        spec_buffer;
        ylab;
        xlab;
        freq;
        stim_buffer;
        window;
        maxamp=0;
    end
    
    methods
        function obj=rt_spectrum(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin);
            obj.fullname='Spectrogram';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'WindowLengthbins',256);
            addParameter(pars,'NumberFFTbins','256');
            addParameter(pars,'Overlap',128);
            addParameter(pars,'WindowFunction','hann');
            addParameter(pars,'zoom',1);
            
            
            parse(pars,varargin{:});
            list={'16';'32';'64';'128';'256';'512';'1024';'2048'};
            wins={'hamming';'nuttallwin';'hann'};
            add(obj.p,param_int('WindowLengthbins',pars.Results.WindowLengthbins));
            add(obj.p,param_int('Overlap',pars.Results.Overlap));
            add(obj.p,param_popupmenu('NumberFFTbins',pars.Results.NumberFFTbins,'list',list));
            add(obj.p,param_popupmenu('WindowFunction',pars.Results.WindowFunction,'list',wins));
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',0,'maxvalue',10));
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            
            nfft=str2double(getvalue(obj.p,'NumberFFTbins'));
            WindowLength=getvalue(obj.p,'WindowLengthbins');
            overlap=getvalue(obj.p,'Overlap');
            windowname=getvalue(obj.p,'WindowFunction');
            eval(sprintf('obj.window=%s(WindowLength);',windowname));
            
            zstim=zeros(ceil(obj.parent.SampleRate*obj.parent.PlotWidth),1);
            [s,obj.freq,t] = spectrogram(zstim,obj.window,overlap,nfft,obj.parent.SampleRate);
            
            buf=circbuf(size(s,2),size(s,1));
            obj.spec_buffer=buf;
            dd=get(obj.spec_buffer);
            
            imagesc(dd','parent',ax);
            view(ax,0,270);
            
            
            set(ax,'Xlim',[1 getlength(buf)],'Ylim',[1 getheight(buf)]);
            yt=get(ax,'YTick');
            for i=1:length(yt)
                obj.ylab{i}=num2str(round(obj.freq(yt(i))/1000*10)/10);
            end
            set(ax,'YTickLabel',obj.ylab);
            
            
            xt=get(ax,'xtick');
            xtt=xt/size(s,2)*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=num2str(round(xtt(i)*10)/10);
            end
            
            xlabel(ax,'time (sec)')
            ylabel(ax,'frequency (kHz)')
            obj.stim_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth)); %zeros(parent.Fs*obj.plotwidth,1);
            title(ax,obj.fullname);
            
            colormap(ax,parula);
            set_changed_status(obj.p,0);
        end
        
        
        
        function plot(obj,sig)
            ax=obj.viz_axes;
            
            if has_changed(obj.p)
                if ~has_changed(getparameter(obj.p,'zoom')) % no need to restart - tunable
                    post_init(obj);
                    set_changed_status(obj.p,0);
                end
            end
            fs=obj.parent.SampleRate;
            nfft=str2double(getvalue(obj.p,'NumberFFTbins'));
            len=getvalue(obj.p,'WindowLengthbins');
            overlap=getvalue(obj.p,'Overlap');
            
            sigbuf=obj.stim_buffer;
            specbuf=obj.spec_buffer;
            
            push(sigbuf,sig); %
            sigfull=get(sigbuf); % full signal
            sigclip=sigfull(end-len+1:end);
            s=spectrogram(sigclip,obj.window,overlap,nfft,fs);
            
            %             s=pwelch(sig,obj.window,0,obj.nfft,obj.parent.Fs);
            %             s=1-abs(log(s));
            s=abs(s);
            %             s=64-s;
            g=getvalue(obj.p,'zoom');
            
            s=s*64/34*g;  % max value by try and error
            specbuf=push(specbuf,s');
            dd=get(specbuf)';
            image(dd,'parent',ax);
            %             figure(1)
            %             plot(s);
            %             if max(s)>obj.maxamp
            %                 obj.maxamp=max(s)
            %             end
            %                             set(gca,'ylim',[0 obj.maxamp]);
            
            %   Copyright 2019 Stefan Bleeck, University of Southampton
            %             colormap(ax,parula);
            %             colormap(ax,gray);
            
        end
    end
end
