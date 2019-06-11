%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_haspi < rt_measurer
    properties
        clean_buffer;
        noisy_buffer
        haspi_buffer;
    end
    
    methods
        %% creator
        function obj=rt_haspi(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='HASPI (impaired speech intellegibility)';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',1);
            addParameter(pars,'Audiogram',[0,10,15,20,25,30]);
            addParameter(pars,'SpeechLevel',65);
            
            parse(pars,varargin{:});
            add(obj.p,param_audiogram('Audiogram',pars.Results.Audiogram));
            
            add(obj.p,param_number('SpeechLevel',pars.Results.SpeechLevel));
            add(obj.p,param_number('integrationPeriod',pars.Results.integrationPeriod));
            
            s='haspi measures the speech intelligibility when considering a hearing loss';
            s=[s,'Kates, James & Arehart, Kathryn. (2014). The hearing-aid speech perception index (HASPI).'];
            s=[s,' Speech Communication. 65. 10.1016/j.specom.2014.06.002. '];
            s=[s,'From the abstract: This paper presents a new index for predicting speech intelligibility for normal-hearing '];
            s=[s,'and hearing-impaired listeners. The Hearing-Aid Speech Perception Index (HASPI) is based on a model of the auditory'];
            s=[s,'periphery that incorporates changes due to hearing loss. The index compares the envelope and'];
            s=[s,'temporal fine structure outputs of the auditory model for a reference signal to the outputs of the model for the '];
            s=[s,'signal under test. The auditory model for the reference signal is set for normal hearing, while the model for the test signal '];
            s=[s,'incorporates the peripheral hearing loss. The new index is compared to indices based on measuring the coherence between '];
            s=[s,'the reference and test signals and based on measuring the envelope correlation between the two signals. HASPI '];
            s=[s,'is found to give accurate intelligibility predictions for a wide range of signal degradations including speech '];
            s=[s,'degraded by noise and nonlinear distortion, speech processed using frequency compression, noisy speech processed '];
            s=[s,'through a noise-suppression algorithm, and speech where the high frequencies are replaced by the output of a '];
            s=[s,'noise vocoder. The coherence and envelope metrics used for comparison give poor performance for at least one of '];
            s=[s,'these test conditions.'];
            s=[s,'Implemenation from source code from the author.'];
            s=[s,'The parameters set the hearing loss as the audiogram data'];
            
            obj.descriptor=s;
            obj.requires_noise=1;  % this module requires that noise is switched on
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.haspi_buffer=circbuf1(mm);
            
        end
        
        function haspi=calculate(obj,sig)
            
            clean=obj.parent.clean_stim;
            if isempty(obj.parent.clean_stim) % forgot to switch on noise!
                clean=sig;
                disp('HASPI needs noise switched on! Taking given stimulus as clean stimulus, result will be close to 1')
            end
            
            
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,clean);
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            ref_data=get(obj.clean_buffer,ll); % get the part during integration tiem
            deg_data=get(obj.noisy_buffer,ll);
            
            % haspi doesn't like lots of zeros, so if the first 100 values
            % are zero, just return 0
            if sum(ref_data(1:10))==0
                haspi=0;
                return
            end
            
            
            
            Level1=getvalue(obj.p,'SpeechLevel');
            % HL		(1,6) vector of hearing loss at the 6 audiometric frequencies
            %			  [250, 500, 1000, 2000, 4000, 6000] Hz.
            HL=getvalue(obj.p,'Audiogram');
            haspi = HASPI_v1(ref_data,fs,deg_data,fs,HL,Level1);
            push(obj.haspi_buffer,haspi);
            
            x=1:getlength(obj.haspi_buffer);
            y=get(obj.haspi_buffer)';
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            % set(measax,'ylim',[0 1]);
            
            
        end
    end
end


