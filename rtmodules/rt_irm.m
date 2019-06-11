%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% ideal ratio mask
classdef rt_irm < rt_manipulator
    properties
        clean_model;
        noisy_model;
        ibm_buffer;
    end
    
    methods
        
        function obj=rt_irm(parent,varargin)
            obj@rt_manipulator(parent,varargin{:});
            obj.fullname='Ideal ratio mask';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            met={'Spectral based';'Gammatone fb based'};
            addParameter(pars,'Method',met{1});
            addParameter(pars,'NumberChannel',50);
            addParameter(pars,'SpeechThreshold',15);
            addParameter(pars,'IdealMaskReduction',-20);
            
            parse(pars,varargin{:});
            add(obj.p,param_popupmenu('Method',pars.Results.Method,'list',met));
            add(obj.p,param_number('NumberChannel',pars.Results.NumberChannel));
            add(obj.p,param_float_slider('SpeechThreshold',pars.Results.SpeechThreshold,'minvalue',0, 'maxvalue',50));
            add(obj.p,param_float_slider('IdealMaskReduction',pars.Results.IdealMaskReduction,'minvalue',-50, 'maxvalue',0));
            
            obj.requires_noise=1;  % this module requires that noise is switched on
            obj.requires_overlap_add=1;  % this module requires that overlap and add is switched on

        s='IRM: ideal ratio mask reduces the noise in a signal with the knowledge of the clean signal';
            s=[s, 'the parameters allow to change the threshold of reduction and the amount of noise reduction'];
            obj.descriptor=s;
            
            
        end
        
        function post_init(obj) % called the second times around
            method=getvalue(obj.p,'Method');
            switch method
                case 'Gammatone fb based'
                    num_channels=getvalue(obj.p,'NumberChannel');
                    sample_rate=1/obj.parent.SampleRate;
                    lowFreq=100;
                    highFreq=6000;
                    window_length=obj.parent.FrameLength;
                    obj.clean_model=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
                    obj.clean_model=setmode(obj.clean_model,'NAP'); % I only want the NAP
                    obj.noisy_model=caim(sample_rate,num_channels,lowFreq,highFreq,window_length);
                    obj.noisy_model=setmode(obj.noisy_model,'BMM'); % I only need the BMM .
                    x=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
                    obj.ibm_buffer=circbuf(x,num_channels);
                    
                case 'Spectral based'
            end
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            
        end
        
        function enhanced=apply(obj,noisy)
            
            
            clean=obj.parent.clean_stim;
            if isempty(obj.parent.clean_stim) % forgot to switch on noise!
                clean=noisy;
                disp('IRM needs noise switched on!')
            end
            
            method=getvalue(obj.p,'Method');
            switch method
                case 'Gammatone fb based'
                    thresh=-getvalue(obj.p,'SpeechThreshold');
                    maskreduction=getvalue(obj.p,'IdealMaskReduction'); %
                    
                    %% noisy BMM and NAP
                    [bmm_noisy]=step(obj.noisy_model,noisy);
                    %% clean NAP:
                    [~,nap_clean]=step(obj.clean_model,clean);
                    %% clean features:
                    clean_features=mean(nap_clean,2)';  % simple feature: average energy
                    obj.ibm_buffer=push(obj.ibm_buffer,clean_features);
                    %% set up a default mask of a lot attenuation where not enough speech is present
                    mask=maskreduction.*ones(size(clean_features))';  %  default: attenuate a lot
                    %             and let through only the bits with high energy:
                    mask(clean_features>thresh)=0;  % only let through bits with high energy
                    %             figure(22)
                    %             clf
                    %             plot(noisy_features)
                    %             hold on
                    %             plot(clean_features)
                    %             plot(mask-maskreduction,'r')
                    %             line([0,50],[thresh,thresh],'color','g')
                    %             legend('average nap noisy','average nap clean','mask','threshold')
                    %             set(gca,'ylim',[0 50]);
                    
                    bmm_resynth=bmm_noisy; % allocate memory or resynthizing
                    for ch=1:size(bmm_resynth,2) % go through all channels
                        bmm_resynth(:,ch)=bmm_noisy(:,ch).*power(10,mask(ch)/20);
                    end
                    enhanced=sum(bmm_resynth')';  % sum them all up as simplest method of resynthesis
                    
                case 'Spectral based'
                    
                    nfft=obj.parent.FrameLength;% FFT analysis length
                    X = fft(noisy, nfft);
                    S = fft(clean, nfft);
                    % compute the true STFT noise spectrum (assumes additive noise distortion)
                    D = X - S;
                    
                    % compute true SNR and threshold it to produce the ideal binary mask
                    SNR = abs(S).^2 ./ abs(D).^2;
                    maskreduction=getvalue(obj.p,'IdealMaskReduction'); %
                    
                    MASK = ones( size(SNR) )*power(10,maskreduction/20); % don't switch off completely, just
                    LC=getvalue(obj.p,'SpeechThreshold'); %Local mask criterion
                    MASK( SNR>10^(0.1*LC) ) = 1;
                    
                    % apply the ideal binary mask and create modified complex spectrum
                    Y = abs(X) .* MASK .* exp(1j*angle(X));
                    % alternatively, you could perform a sanity check and reconstruct the clean speech...
                    % Y = abs(S) .* exp(j*angle(S));
                    
                    enhanced = real(ifft(Y,nfft));% apply inverse STFT
            end
        end
    end
end
