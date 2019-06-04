


% Center Freq. based on number of channels. These values are taken from
% Dorman, Loizou, Rainey, (1997). Speech intelligibility as a function of the number of channels
% of stimulation for signal processors using sine-wave
% and noise-band outputs. JASA

%   Copyright 2019 Stefan Bleeck, University of Southampton
% https://uk.mathworks.com/matlabcentral/fileexchange/69403-cochlear-implant-simulation



classdef rt_ci_sim < rt_manipulator
    properties
        nr_channels;
        Bw;
        Wn;
        blp;
        alp;
        a;
        b;
    end
    
    methods
        function obj=rt_ci_sim(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Cochlear implant simulation';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            types={'NOISE','TONE'};
            addParameter(pars,'NrChannels',8);
            addParameter(pars,'type',types{1});
            addParameter(pars,'EnvCutoff',160);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('NrChannels',pars.Results.NrChannels,'minvalue',2,'maxvalue',9));
            add(obj.p,param_popupmenu('type',pars.Results.type,'list',types));
            add(obj.p,param_float_slider('EnvCutoff',pars.Results.EnvCutoff,'minvalue',1,'maxvalue',500));
            
        end
        
        function post_init(obj) % called the second times around
            
            rate=obj.parent.SampleRate;
            NrChannels=round(getvalue(obj.p,'NrChannels'));
            cutoff=getvalue(obj.p,'EnvCutoff');
            obj.b=[];
            obj.a=[];
            
            switch NrChannels
                case 2
                    Wn = repmat([792; 3392], 1, 2);
                case 3
                    Wn=repmat([0545; 1438; 3793], 1, 2);
                case 4
                    Wn=repmat([0460; 0953; 1971; 4078], 1, 2);
                case 5
                    Wn=repmat([0418; 0748; 1339; 2396; 4287], 1, 2);
                case 6
                    Wn=repmat([0393; 0639; 1037; 1685; 2736; 4443],1, 2);
                case 7
                    Wn=repmat([0377; 0572; 0866; 1312; 1988; 3013; 4565], 1, 2);
                case 8
                    Wn=repmat([0366; 0526; 0757; 1089; 1566; 2252; 3241; 4662], 1, 2);
                case 9
                    Wn=repmat([0357; 0493; 0682; 0942; 1301; 1798; 2484; 3431; 4740], 1, 2);
            end
            obj.Wn = Wn/(rate/2);
            
            
            %     Bandwidth based on number of channels
            switch NrChannels
                case 2
                    Bw=0.5*[-0984 0984; -4215 4215]./(rate/2);
                case 3
                    Bw=0.5*[-0491 0491; -1295 1295; -3414 3414]./(rate/2);
                case 4
                    Bw=0.5*[-0321 0321; -0664 0664; -1373 1373; -2842 2842]./(rate/2);
                case 5
                    Bw=0.5*[-0237 0237; -0423 0423; -0758 0758; -1356 1356; -2426 2426]./(rate/2);
                case 6
                    Bw=0.5*[-0187 0187; -0304 0304; -0493 0493; -0801 0801; -1301 1301; -2113 2113]./(rate/2);
                case 7
                    Bw=0.5*[-0154 0154; -0234 0234; -0355 0355; -0538 0538; -0814 0814; -1234 1234; -1870 1870]./(rate/2);
                case 8
                    Bw=0.5*[-0131 0131; -0189 0189; -0272 0272; -0391 0391; -0563 0563; -0810 0810; -1165 1165; -1676 1676]./(rate/2);
                case 9
                    Bw=0.5*[-0114 0114; -0158 0158; -0218 0218; -0302 0302; -0417 0417; -0576 0576; -0796 0796; -1099 1099; -1519 1519]./(rate/2);
            end
            
            % Find the bandpass cuttoffs
            obj.Wn = obj.Wn + Bw;
            obj.Wn(obj.Wn>1) = 0.99;
            obj.Wn(obj.Wn<0) = 0.01;
            fc=cutoff /(rate/2);
            [obj.blp,obj.alp]=butter(2,fc,'low'); % generate filter coefficients
            
            % Generate lowpass filter coefficients (for envelope extraction):
            
            for i=1:NrChannels
                %     Find the filter coefficients for each bandpass filter
                [obj.b(i,:),obj.a(i,:)] = butter(4,obj.Wn(i,:));
            end
            
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!

            
        end
        
        function vocoded_x=apply(obj,s)
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            
            rate=obj.parent.SampleRate;
            NrChannels=round(getvalue(obj.p,'NrChannels'));
            vocoder_type=getvalue(obj.p,'type');
            
            % Apply high-pass pre-emphasis filter
            pre=0.9378;
            xx=filter([1 -pre], 1, s)';
            
            % Generate noise carrier only for noise vocoders
            if( strcmp(vocoder_type, 'NOISE') )
                noise = rand( length(s),1 );
                noise = noise(:);
            end
            
            vocoded_x=zeros(size(s));
            
            for i=1:NrChannels
                % now filter the input waveform using filter #i
                filtwav = filtfilt(obj.b(i,:),obj.a(i,:),xx)';
                
                %     Half-wave rectification
                filtwav(filtwav<0) = 0;
                
                %     Filter the band-passed filtered signal to extract its envelope
                %     (Overall shape)
                envelope=filter(obj.blp,obj.alp,filtwav);
                envelope = envelope(:);
                
                %     If noise vocoder is selected, then multiply the envelope with the
                %     noise carrier.
                %    Basically, we modulate the noise by the envelope
                switch vocoder_type
                    case  'NOISE'
                        source = noise./(max(abs(noise)));
                        fn=filtfilt(obj.b(i,:),obj.a(i,:),envelope.*source);
                    case 'TONE'
                        %     If tone vocoder is selected, then multiply the envelope with a
                        %     tone carrier.
                        %    Basically, we modulate the tone by the envelope
                        %     Tone with freq. at the center of the band-pass filter
                        f = exp(mean(log(obj.Wn(i,:)))) * (rate/2);
                        tone=sin(2*pi*(1:length(envelope))*f/rate)';
                        tone = tone(:);
                        fn = envelope.*tone;
                end
                % sum bands with equal gain in each channel
                vocoded_x = vocoded_x + fn;
            end
            
            % Scale output waveform to have same rms as original
            vocoded_x = vocoded_x * (rms(s)/rms(vocoded_x));
        end
    end
end




