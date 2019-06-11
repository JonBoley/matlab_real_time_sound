%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_stoi < rt_measurer
    properties
        clean_buffer;
        noisy_buffer
        stoi_buffer;
    end
    
    methods
        %% creator
        function obj=rt_stoi(parent,varargin)
            obj@rt_measurer(parent,varargin{:});
            obj.fullname='STOI (speech intellegibility)';
            pre_init(obj);  % add the parameter gui
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',1);
            parse(pars,varargin{:});
            add(obj.p,param_number('integrationPeriod',pars.Results.integrationPeriod));
            
            obj.requires_noise=1;  % this module requires that noise is switched on
            
            s='STOI (short time speech intellegibility estimate';
            s=[s, 'implementation from Taal and Jensen'];
            s=[s, '  requires the clean speech'];
            s=[s, ' The output d is expected to have a monotonic '];
            s=[s, 'relation with the subjective speech-intelligibility, where a higher d '];
            s=[s, ' denotes better intelligible speech. See [1, 2] for more details.'];
            s=[s, 'References:'];
            s=[s, '[1] C.H.Taal, R.C.Hendriks, R.Heusdens, J.Jensen "A Short-Time'];
            s=[s, 'Objective Intelligibility Measure for Time-Frequency Weighted Noisy'];
            s=[s, 'Speech", ICASSP 2010, Texas, Dallas. '];
            s=[s, '[2] C.H.Taal, R.C.Hendriks, R.Heusdens, J.Jensen "An Algorithm for '];
            s=[s, ' Intelligibility Prediction of Time-Frequency Weighted Noisy Speech, '];
            s=[s, ' IEEE Transactions on Audio, Speech, and Language Processing, 2011. '];
            obj.descriptor=s;
            
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.stoi_buffer=circbuf1(mm);
            
            obj.requires_noise=1; % this module only runs properly with overlap add switched on
            
            
            s='short-time objective intelligibility (STOI) measure described in [1, 2],  ';
            s=[s, 'is expected to have a monotonic relation with the subjective speech-intelligibility,  '];
            s=[s, 'where a higher d denotes better intelligible speech.  '];
            s=[s, 'Implementation is from C.H. Taal with minor modifications for real time running '];
            s=[s, '%   References: '];
            s=[s, '%      [1] C.H.Taal, R.C.Hendriks, R.Heusdens, J.Jensen "A Short-Time '];
            s=[s, '%      Objective Intelligibility Measure for Time-Frequency Weighted Noisy '];
            s=[s, '%      Speech", ICASSP 2010, Texas, Dallas. '];
            s=[s, '% '];
            s=[s, '%      [2] C.H.Taal, R.C.Hendriks, R.Heusdens, J.Jensen ''An Algorithm for  '];
            s=[s, '%      Intelligibility Prediction of Time-Frequency Weighted Noisy Speech'', '];
            s=[s, '%      IEEE Transactions on Audio, Speech, and Language Processing, 2011. '];
            obj.descriptor=s;
            
        end
        
        function stoi=calculate(obj,sig)
            
            clean=obj.parent.clean_stim;
            if isempty(obj.parent.clean_stim) % forgot to switch on noise!
                clean=sig;
                disp('STOI needs noise switched on! Taking given stimulus as clean stimulus, result will be close to 1')
            end
            
            
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,clean);
            push(obj.noisy_buffer,sig);
            
            l=getvalue(obj.p,'integrationPeriod');
            ll=l*fs;
            ref_data=get(obj.clean_buffer,ll); % get the part during integration tiem
            deg_data=get(obj.noisy_buffer,ll);
            
            %             % stoi doesn't like lots of zeros, so if the first 100 values
            %             % are zero, just return 0
            %             if sum(ref_data(1:10))==0
            %                 stoi=0;
            %                 return
            %             end
            %
            
            
            stoi = mystoi(ref_data, deg_data,fs);
            push(obj.stoi_buffer,stoi);
            
            x=1:getlength(obj.stoi_buffer);
            y=get(obj.stoi_buffer)';
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
            set(measax,'ylim',[0 1]);
            
            
        end
        
    end
end


