%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_loudnessfastl < rt_measurer
    properties
        noisy_buffer;
        loudness_buffer;
    end
    
    methods
        %% creator
        function obj=rt_loudnessfastl(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='Loudness (Fastl)';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            cas={'fast (only show loudness)';'slow (full Barkscale)'};
            addParameter(pars,'Visualization','slow (full Barkscale)');
            
            addParameter(pars,'integrationPeriod',0.5);  % buffer for computation MUST be >0.4 sec!
            parse(pars,varargin{:});
            add(obj.p,param_float('integrationPeriod',pars.Results.integrationPeriod));
            add(obj.p,param_popupmenu('Visualization',pars.Results.Visualization,'list',cas));
            
            s='Loudness (Fastl) estimates the perceived Loudness of a sound';
            s=[s,'using the implementaiton from Hugo Fastl available here'];
            s=[s,'https://www.salford.ac.uk/research/sirc/research-groups/acoustics/psychoacoustics/sound-quality-making-products-sound-better/accordion/sound-quality-testing/matlab-codes'];
            s=[s,'described in ISO BS 532/R and DIN 45631'];
            obj.descriptor=s;
            
        end
        
        function post_init(obj)
            l=getvalue(obj.p,'integrationPeriod');
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.loudness_buffer=circbuf1(mm);
            
            measax=obj.measurement_axis;

            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                measax=obj.measurement_axis;
                cla(measax);
                hold(measax,'on')
            end
        end
        
        function loudness=calculate(obj,sig)
            
            
            if has_changed(obj.p)
                post_init(obj)
                set_changed_status(obj.p,0);
            end
            
            fs=obj.parent.SampleRate;
            push(obj.noisy_buffer,sig);
            % length of analysis window
            l=getvalue(obj.p,'integrationPeriod');
            cutsig=get(obj.noisy_buffer,l*obj.parent.SampleRate);
            
            
            %% calculate the loudness using the inbuild matlab model
            %             loudness=integratedLoudness(cutsig,fs);
            
            Pref=60;  % reference loudness
            % Mod = 0 for free field
            % Mod = 1 for diffuse field
            Mod=0;
            
            cutsig=resample(cutsig,32000,fs);
            [loudness,N_single] = loudness_1991(cutsig, Pref, 32000, Mod);
            
            push(obj.loudness_buffer,loudness);
            
            measax=obj.measurement_axis;
            
            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                
                viz= getvalue(obj.p,'Visualization');
                switch viz
                    case 'fast (only show loudness)'
                        hold(measax,'off')
                        x=1:getlength(obj.loudness_buffer);
                        y=get(obj.loudness_buffer);
                        measax=obj.measurement_axis;
                        plot(measax,x,y,'.-');
                        set(measax,'xlim',[0 length(x)],'ylim',[0 20]);
                        
                    case 'slow (full Barkscale)'
                        
                        cla(measax);
                        hold(measax,'on')
                        
                        x=[.1:.1:24];
                        plot(measax,x,N_single,'-');
                        set(measax,'xlim',[0 24],'ylim',[0 (max(N_single)+1)]);
                        ylabel(measax,'N´ [sone/Bark]')
                        xlabel(measax,'z [Bark]')
                        text(measax,1,0.2,'N [sone] =')
                        text(measax,4.5,0.2,num2str(loudness))
                end
            end
        end
        
        
    end
end


