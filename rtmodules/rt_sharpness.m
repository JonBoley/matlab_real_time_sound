%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_sharpness < rt_measurer
    properties
        noisy_buffer;
        sharp_buffer;
    end
    
    methods
        %% creator
        function obj=rt_sharpness(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='Sharpness (Fastl)';
            
            obj.descriptor='Implementation of Hugo Fastl''s Sharpness estimator. Source code from https://www.salford.ac.uk/research/sirc/research-groups/acoustics/psychoacoustics/sound-quality-making-products-sound-better/accordion/sound-quality-testing/matlab-codes, slightly modified for speed and suppressing outputs. Can be modified much more for speed if required.';
            
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            %             cas={'fast (only show loudness)';'slow (full Barkscale)'};
            %             addParameter(pars,'Visualization','slow (full Barkscale)');
            
            addParameter(pars,'integrationPeriod',0.4);
            parse(pars,varargin{:});
            add(obj.p,param_number('integrationPeriod',pars.Results.integrationPeriod));
            
            s='Loudness estimates subjective loudness perception based on ISO 532 B / DIN 45 631';
            s=[s,'% Source: BASIC code in J Acoust Soc Jpn (E) 12, 1 (1991)'];
            s=[s,'implementation from https://www.salford.ac.uk/research/sirc/research-groups/acoustics/psychoacoustics/sound-quality-making-products-sound-better/accordion/sound-quality-testing/matlab-codes'];
           obj.descriptor=s; 
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.sharp_buffer=circbuf1(mm);
            
            measax=obj.measurement_axis;
            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                
                cla(measax);
                hold(measax,'off')
            end
        end
        
        function sharp=calculate(obj,sig)
            
            
            if has_changed(obj.p)
                post_init(obj)
                set_changed_status(obj.p,0);
            end
            
            fs=obj.parent.SampleRate;
            
            
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            deg_data=get(obj.noisy_buffer,ll);
            
            
            %% calculate the loudness using the inbuild matlab model
            %             loudness=integratedLoudness(cutsig,fs);
            
            Pref=60;  % reference loudness
            % Mod = 0 for free field
            % Mod = 1 for diffuse field
            Mod=0;
            
            deg_data=resample(deg_data,32000,fs);
            [~,N_single] = loudness_1991(deg_data, Pref, 32000, Mod);
            sharp = sharpness_Fastl(N_single);
            
            push(obj.sharp_buffer,sharp);
            
            x=1:getlength(obj.sharp_buffer);
            y=get(obj.sharp_buffer);
            measax=obj.measurement_axis;
            
            if ~isempty(measax)  % only plot when a measurement axis exists, if not, probably run from a script
                
                plot(measax,x,y,'.-');
                set(measax,'ylim',[0 2]);
            end
        end
        
        function close(obj)
        end
        
    end
end


