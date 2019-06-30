%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_input_oscillator < rt_input
    properties
        osc;
        sigphase=0;
        sigenvphase=0;
        mynoisegenerator
        noisecalib;
        sigontimephase=0; % counter that measures if pulses are on or off
    end
    
    methods
        function obj=rt_input_oscillator(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            obj.fullname='Waveform generator';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'SignalType','sine');
            addParameter(pars,'Frequency',1000);
            addParameter(pars,'Amplitude',80);
            addParameter(pars,'NumTones',1);
            addParameter(pars,'DutyCycle',0.5);
            addParameter(pars,'Width',0.5);
            addParameter(pars,'TimeConstant',0.01);
            addParameter(pars,'Period',0.01);
            addParameter(pars,'NoiseColor','pink');
            addParameter(pars,'NrPulses',4);
            addParameter(pars,'PulsesEvery',1);
            
            parse(pars,varargin{:});
            
            add(obj.p,param_popupmenu('SignalType',pars.Results.SignalType,'list',{'sine';'square';'sawtooth';'ramped';'damped';'pulses';'noise'}));
            add(obj.p,param_float_slider('Frequency',pars.Results.Frequency,'unittype',unit_frequency,'unit','Hz','minvalue',50,'maxvalue',20000,'scale','log'));
            add(obj.p,param_float_slider('Amplitude',pars.Results.Amplitude,'minvalue',0,'maxvalue',obj.MAXVOLUME));
            add(obj.p,param_int('NumTones',pars.Results.NumTones,'minvalue',1,'maxvalue',20));
            add(obj.p,param_float_slider('DutyCycle',pars.Results.DutyCycle,'minvalue',0,'maxvalue',1));
            add(obj.p,param_float_slider('Width',pars.Results.Width,'minvalue',0,'maxvalue',1));
            add(obj.p,param_float_slider('TimeConstant',pars.Results.TimeConstant,'minvalue',0.001,'maxvalue',0.05,'unittype',unit_time,'unit','sec','scale','log'));
            add(obj.p,param_float_slider('Period',pars.Results.Period,'minvalue',0.005,'maxvalue',0.05,'unittype',unit_time,'unit','sec','scale','log'));
            add(obj.p,param_int('NrPulses',pars.Results.NrPulses));
            add(obj.p,param_float('PulsesEvery',pars.Results.PulsesEvery,'minvalue',0.1,'maxvalue',2,'unittype',unit_time,'unit','sec'));
            
            noisecols={'pink';'white';'brown';'blue';'purple'};
            add(obj.p,param_popupmenu('NoiseColor',pars.Results.NoiseColor,'list',noisecols));
            
            warning('off','MATLAB:system:nonRelevantProperty');  % othrwise we get useless warnings
            
            obj.input_source_type='oscillator'; % this is a switch for later identification for calibration
%             obj.show=1; % present this to the user, although it's an input
            obj.descriptor='Signal generator combining several methods of signal generation. Used are build in methods dsp.Colorednoise and audiooscillator. Ramped and Damped are own code';
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_input(obj);
            % calibrate to the right level: all signal amplitudes are
            % reported in Pascal
            db=getvalue(obj.p,'Amplitude');
            amp=obj.P0*power(10,db/20);
            
            % change the max frequency, only now we know the sr:
            p=getparameter(obj.p,'Frequency');
            p.maxvalue=obj.parent.SampleRate/2;
            
            type=getvalue(obj.p,'SignalType');
            switch type
                case 'pulses'
                    obj.sigontimephase=0;
                case 'ramped'
                case 'damped'
                case 'noise'
                    color=getvalue(obj.p,'NoiseColor');
                    obj.mynoisegenerator=dsp.ColoredNoise('Color',color,'SamplesPerFrame',obj.parent.FrameLength);
                    % i don't know what the amplitude of the noise is, so
                    % set the rms to a fixed value
                    m=[];
                    for i=1:100
                        n=obj.mynoisegenerator();
                        m=[m;n];
                    end
%                     obj.noisecalib=max([max(m) -min(m)])*0.95;
                    obj.noisecalib=rms(m)*0.95;
                otherwise
                    obj.osc=audioOscillator('SignalType',getvalue(obj.p,'SignalType'),...
                        'Frequency',getvalue(obj.p,'Frequency'),...
                        'Width',getvalue(obj.p,'Width'),...
                        'NumTones',getvalue(obj.p,'NumTones'),...
                        'DutyCycle',getvalue(obj.p,'DutyCycle'),...
                        'Amplitude',amp,...
                        'SamplesPerFrame',obj.parent.FrameLength,...
                        'SampleRate',obj.parent.SampleRate);
            end
            set_changed_status(obj.p,0);
        end
        
        function sig=read_next(obj)
            type=getparameter(obj.p,'SignalType');
            nrt=getparameter(obj.p,'NumTones');
            pue=getparameter(obj.p,'PulsesEvery');
            per=getparameter(obj.p,'Period');
            if has_changed(type) || has_changed(nrt) || has_changed(pue) || has_changed(per)
                post_init(obj);
            end
            
            if has_changed(obj.p)
                % calibrate to the right level: all signal amplitudes are
                % reported in Pascal
                db=getvalue(obj.p,'Amplitude');
                amp=obj.P0*power(10,db/20);
                obj.osc.Frequency=getvalue(obj.p,'Frequency');
                obj.osc.Amplitude=amp;
                obj.osc.Width=getvalue(obj.p,'Width');
                obj.osc.DutyCycle=getvalue(obj.p,'DutyCycle');
                set_changed_status(obj.p,0);
            end
            %             sr=obj.parent.SampleRate;
            %             len=obj.parent.FrameLength;
            switch getvalue(type)
                case 'pulses'
                    sig=genpulses(obj);
                    db=getvalue(obj.p,'Amplitude');
                    amp=obj.P0*power(10,db/20);
                    sig=sig.*amp;
                case 'ramped'
                    sig=genramped(obj);
                    db=getvalue(obj.p,'Amplitude');
                    amp=obj.P0*power(10,db/20);
                    sig=sig.*amp;
                case 'noise'
                    sig=obj.mynoisegenerator();
                    sig=sig/obj.noisecalib;
                    db=getvalue(obj.p,'Amplitude');
                    amp=obj.P0*power(10,db/20);
                    sig=sig.*amp;
                case 'damped'
                    sig=gendamped(obj);
                    db=getvalue(obj.p,'Amplitude');
                    amp=obj.P0*power(10,db/20);
                    sig=sig.*amp;
                otherwise
                    sig=obj.osc();
            end
            sig=calibrate_inp(obj,sig);
        end
        
        function s=gendamped(obj)  % generates damped sinusoids with exponential decay
            fc=getvalue(obj.p,'Frequency','Hz');
            damped_time=getvalue(obj.p,'TimeConstant','sec');
            period_length=getvalue(obj.p,'Period','sec');
            sr=obj.parent.SampleRate;
            len=obj.parent.FrameLength;
            x=sin((2*pi*fc*(obj.sigphase:len+obj.sigphase-1)/sr)); % create a sine wave
            obj.sigphase=obj.sigphase+len;
            env=zeros(len,1); %  % now the envelope create an empty return
            time_const=damped_time/0.69314718;
            for i=1:length(env) % just in case, use the whole signal
                obj.sigenvphase=obj.sigenvphase+1/sr;
                if obj.sigenvphase>period_length
                    obj.sigenvphase=0;
                end
                t=obj.sigenvphase;
                env(i)= exp(-(t)/time_const);
            end
            s=x'.*env;
        end
        
        function s=genramped(obj)  % generates damped sinusoids with exponential decay
            fc=getvalue(obj.p,'Frequency','Hz');
            damped_time=getvalue(obj.p,'TimeConstant','sec');
            period_length=getvalue(obj.p,'Period','sec');
            
            
            sr=obj.parent.SampleRate;
            len=obj.parent.FrameLength;
            x=sin((2*pi*fc*(obj.sigphase:len+obj.sigphase-1)/sr)); % create a sine wave
            obj.sigphase=obj.sigphase+len;
            env=zeros(len,1); %  % now the envelope create an empty return
            time_const=damped_time/0.69314718;
            
            for i=1:length(env) % just in case, use the whole signal
                obj.sigenvphase=obj.sigenvphase+1/sr;
                if obj.sigenvphase>period_length
                    obj.sigenvphase=0;
                end
                t=obj.sigenvphase;
                env(i)= exp((t)/time_const);
            end
            
            % calibrate
            maxv=exp((period_length)/time_const);
            s=x'.*env/maxv;
        end
        
        
        function s=genpulses(obj)
            % generates damped sinusoids with exponential decay
            
            fc=getvalue(obj.p,'Frequency','Hz');
            damped_time=getvalue(obj.p,'TimeConstant','sec');
            period_length=getvalue(obj.p,'Period','sec');
            pulsesevery=getvalue(obj.p,'PulsesEvery','sec');
            nrpulses=getvalue(obj.p,'NrPulses');
            
            sr=obj.parent.SampleRate;
            len=obj.parent.FrameLength;
            
            % simulate the number of pulses by simply switching off the rest of the the time.
            ontime=nrpulses*period_length;
            
            
            x=sin((2*pi*fc*(obj.sigphase:len+obj.sigphase-1)/sr)); % create a sine wave
            obj.sigphase=obj.sigphase+len;
            
            if obj.sigphase>100000
                obj.sigphase=rem(obj.sigphase, ceil(period_length*sr));
            end

            
            % now the envelope
            env=zeros(len,1); % create an empty return
            time_const2=damped_time/5.52; % empirical by solving below
            
            for i=1:length(env) % just in case, use the whole signal
                obj.sigontimephase=obj.sigontimephase+1/sr;
                if obj.sigontimephase>pulsesevery
                    obj.sigontimephase=0;
                    obj.sigenvphase=0;
                end
                if obj.sigontimephase>ontime
                    env(i)=0;
                else
                    obj.sigenvphase=obj.sigenvphase+1/sr;
                    
                    if obj.sigenvphase>period_length
                        obj.sigenvphase=0;
                    end
                    t=obj.sigenvphase;
                    
                    % build a gammatone 4th order
                    env(i)= power(t,3)*exp(-(t)/time_const2);
                end
            end
            
            tt=3*time_const2;%calibration
            maxv=power(tt,3)*exp(-(tt)/time_const2);
            s=x'.*env/maxv;
        end
        
        function sig=calibrate_inp(obj,sig)
            maxamp=obj.P0*power(10,(obj.MAXVOLUME-3)/20);
            calib=20*log10(maxamp/1); % how many more dB because of pascale
%             calib=calib-40; % to get it in the right ballpark
            fac=power(10,(calib+obj.parent.input_gain)/20);
            sig=sig.*fac;
        end
        
    end
end

