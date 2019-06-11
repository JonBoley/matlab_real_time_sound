%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

classdef rt_spectrum < rt_visualizer
    
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
            addParameter(pars,'WindowLength',30);
            addParameter(pars,'NumberFFTbins','256');
            addParameter(pars,'Overlap',20);
            addParameter(pars,'WindowFunction','blackmanharris');
            addParameter(pars,'zoom',1);
            
            parse(pars,varargin{:});
            list={'16';'32';'64';'128';'256';'512';'1024';'2048'};
            wins={'blackmanharris';'hamming';'nuttallwin';'hann'};
            add(obj.p,param_float('WindowLength',pars.Results.WindowLength,'unittype',unit_time,'unit','msec'));
            add(obj.p,param_float('Overlap',pars.Results.Overlap,'unittype',unit_time,'unit','msec'));
            %             add(obj.p,param_int('Overlap',pars.Results.Overlap));
            add(obj.p,param_popupmenu('NumberFFTbins',pars.Results.NumberFFTbins,'list',list));
            add(obj.p,param_popupmenu('WindowFunction',pars.Results.WindowFunction,'list',wins));
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',0,'maxvalue',3));
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            
            nfft=str2double(getvalue(obj.p,'NumberFFTbins'));
            
            overlap=ceil(getvalue(obj.p,'Overlap','sec')*obj.parent.SampleRate);
            WindowLength=getvalue(obj.p,'WindowLength','sec');
            winl=ceil(WindowLength*obj.parent.SampleRate);
            if winl<overlap
                overlap=ceil(winl/2);
            end
            windowname=getvalue(obj.p,'WindowFunction');
            eval(sprintf('obj.window=%s(winl);',windowname));
            
            zstim=zeros(ceil(obj.parent.SampleRate*obj.parent.PlotWidth),1);
            obj.stim_buffer=circbuf1(length(zstim));
            
            [s,obj.freq,t] = spectrogram(zstim,obj.window,overlap,nfft,obj.parent.SampleRate);
            %             nr_fr=ceil(obj.parent.PlotWidth*obj.parent.SampleRate/obj.parent.FrameLength);
            nr_fr=size(s,2);
            buf=circbuf(nr_fr,nfft/2+1);
            obj.spec_buffer=buf;
            dd=get(obj.spec_buffer);
            
            imagesc(dd','parent',ax);
            set(ax,'Xlim',[1 getlength(buf)],'Ylim',[1 getheight(buf)]);
            view(ax,0,270);
            
            [s,obj.freq,t] = spectrogram(zstim,obj.window,overlap,nfft,obj.parent.SampleRate);
            yt=get(ax,'YTick');
            for i=1:length(yt)
                obj.ylab{i}=sprintf('%3.1f',obj.freq(yt(i))/1000);
            end
            set(ax,'YTickLabel',obj.ylab);
            
            
            xt=get(ax,'xtick');
            xtt=xt/nr_fr*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=sprintf('%2.1f',xtt(i));
            end
            set(ax,'XTickLabel',obj.xlab);
            
            xlabel(ax,'time (sec)')
            ylabel(ax,'frequency (kHz)')
            title(ax,obj.fullname);
            
            colormap(ax,parula(256));
            set_changed_status(obj.p,0);
        end
        
        
        
        function plot(obj,sig)
            ax=obj.viz_axes;
            
            if has_changed(obj.p)
                if has_changed(getparameter(obj.p,'WindowLength')) ||...
                        has_changed(getparameter(obj.p,'Overlap')) ||...
                        has_changed(getparameter(obj.p,'NumberFFTbins')) ||...
                        has_changed(getparameter(obj.p,'WindowFunction'))
                    post_init(obj);
                    set_changed_status(obj.p,0);
                end
            end
            %             fs=obj.parent.SampleRate;
            nfft=str2double(getvalue(obj.p,'NumberFFTbins'));
            %             WindowLength=getvalue(obj.p,'WindowLength');
            overlap=ceil(getvalue(obj.p,'Overlap','sec')*obj.parent.SampleRate);
            
            sigbuf=obj.stim_buffer;
            %             specbuf=obj.spec_buffer;
            
            push(sigbuf,sig); %
            sigfull=get(sigbuf); % full signal
            
            
            s = spectrogram(sigfull,obj.window,overlap,nfft,obj.parent.SampleRate);
            
            %             sigclip=sigfull(end-len+1:end);
            %             s=spectrogram(sigclip,obj.window,overlap,nfft,fs);
            s=abs(s);
            g=getvalue(obj.p,'zoom');
            s=log(s);
            s=s*20*g;  % max value by try and error
            
            %             dd=get(specbuf)';
            imagesc(s,'parent',ax);
            
            
            
            
        end
    end
end
