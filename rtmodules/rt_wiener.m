%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_wiener < rt_manipulator
    properties
        hamming_win;
        anWin;
        % set parameter values
        %         mu; % smoothing factor in noise spectrum update
        %         a_dd; % smoothing factor in priori update
        %         eta; % VAD threshold
        %         noisePowMat;
        U;
        G_prev;
        posteri_prev;
        
        % noise power
        
        noisePow;
        %constants for a posteriori SPP
        %         q;
        priorFact;
        xiOptDb;
        xiOpt;
        logGLRFact;
        GLRexp;
        PH1mean;
        alphaPH1mean;
        alphaPSD;
    end
    
    methods
        
        function obj=rt_wiener(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Wiener filter';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'a_dd',0.98);
            addParameter(pars,'q',0.5);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('smoothing factor in apriori',pars.Results.a_dd,'minvalue',0, 'maxvalue',1));
            add(obj.p,param_float_slider('a priori speech probability',pars.Results.q,'minvalue',0, 'maxvalue',1));
            
            obj.requires_overlap_add=1; % this module only runs properly with overlap add switched on
            
            s='Wiener filter implementation  Plapous et al 2006. Code from the authors adapted slightly for real time';
            s=[s,'Description : Wiener filter based on tracking a priori SNR using Decision-Directed  '];
            s=[s, 'method, proposed by Plapous et al 2006. The two-step noise reduction '];
            s=[s,' (TSNR) technique removes the annoying reverberation effect while '];
            s=[s,' maintaining the benefits of the decision-directed approach. However, '];
            s=[s,' classic short-time noise reduction techniques, including TSNR, introduce '];
            s=[s,' harmonic distortion in the enhanced speech. To overcome this problem, a '];
            s=[s,' method called harmonic regeneration noise reduction (HRNR)is implemented '];
            s=[s,' in order to refine the a priori SNR used to compute a spectral gain able  '];
            s=[s,' to preserve the speech harmonics. '];
            s=[s, 'references:  '];
            s=[s,'"Unbiased MMSE-Based Noise Power Estimation with Low Complexity and Low Tracking Delay", IEEE TASL, 2012'];
            s=[s,' Plapous, C.; Marro, C.; Scalart, P., "Improved Signal-to-Noise Ratio Estimation for Speech Enhancement", '];
            s=[s,' IEEE Transactions on Audio, Speech, and Language Processing, Vol. 14, Issue 6, pp. 2098 - 2108, Nov. 2006 '];
            s=[s, ' More information: https://en.wikipedia.org/wiki/Wiener_filter'];
            obj.descriptor=s;
            
            
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_manipulator(obj);
            
            %             mu=getvalue(obj.p,'smoothing factor in noise'); % smoothing factor in noise spectrum update
            a_dd=getvalue(obj.p,'smoothing factor in apriori');  % smoothing factor in priori update
            %             eta=getvalue(obj.p,'VAD threshold'); % VAD threshold
            
            fs=obj.parent.SampleRate;
            frame_dur=obj.parent.FrameLength/fs;
            L= frame_dur* fs; % L is frame length (160 for 8k sampling rate)
            obj.hamming_win= hamming(L); % hamming window
            obj.anWin = hanning(L,'periodic');
            obj.U= (obj.hamming_win'* obj.hamming_win)/ L; % normalization factor
            U2 = (obj.anWin'* obj.anWin)/L;
            
            %% noise power estimate
            % for the time beeing: assume a pink noise and calculate
            % initial stats:
            [noissig,ofs]=audioread('/Users/bleeck/Google Drive/projects/realtime/noises/pink.wav',[1,50000]);
            noissig=resample(noissig,fs,ofs);
            n1=1;      n2=L;
            for I=1:5
                noisy_frame=obj.anWin.*noissig(n1:n2);
                noisy_dft_frame_matrix(:,I)=fft(noisy_frame,L);
                n1=n1+L;
                n2=n2+L;
            end
            obj.noisePow=mean(abs(noisy_dft_frame_matrix(1:L/2+1,1:end)).^2,2);%%%compute the initialisation of the noise tracking algorithms.
            
            mat = obj.noisePow/ (L* U2);
            noise_ps = [mat; flipud(mat(2:end-1))];
            
            % initialize posteri
            posteri= noise_ps./ noise_ps;
            posteri_prime= posteri- 1;
            posteri_prime(posteri_prime< 0)= 0;
            priori= a_dd+ (1-a_dd)* posteri_prime;
            
            obj.G_prev= sqrt( priori./ (1+ priori)); % gain function
            obj.posteri_prev= posteri;
            
            
            %constants for a posteriori SPP
            obj.PH1mean  = 0.5;
            obj.alphaPH1mean = 0.9;
            obj.alphaPSD = 0.8;
            q=getvalue(obj.p,'a priori speech probability');
            
            obj.priorFact  = q./(1-q);
            obj.xiOptDb    = 15; % optimal fixed a priori SNR for SPP estimation
            obj.xiOpt      = 10.^(obj.xiOptDb./10);
            obj.logGLRFact = log(1./(1+obj.xiOpt));
            obj.GLRexp     = obj.xiOpt./(1+obj.xiOpt);
            
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            
            
        end
        
        function enhanced=apply(obj,noisy)
            
            a_dd=getvalue(obj.p,'smoothing factor in apriori');  % smoothing factor in priori update
            
            L=length(noisy);
            noisy= noisy.* obj.hamming_win;
            noisy_fft= fft( noisy, L);
            noisy_ps= ( abs( noisy_fft).^ 2)/ (L* obj.U);
            mat=obj.noise_power_estimate(noisy);
            
            noise_ps =[mat;flipud(mat(2:end-1))];  %estimate noise
            
            % ============ voice activity detection
            posteri= noisy_ps./ noise_ps;
            posteri_prime= posteri- 1;
            posteri_prime(  posteri_prime< 0)= 0;
            priori= a_dd* (obj.G_prev.^ 2).* obj.posteri_prev+ (1-a_dd)* posteri_prime;
            
            G= sqrt( priori./ (1+ priori)); % gain function
            enhanced= ifft( noisy_fft.* G, L);
            
            obj.G_prev= G;
            obj.posteri_prev= posteri;
            
            
        end
        
        
        function mat=noise_power_estimate(obj,noisy)
            
            %%%% propose SPP algorithm to estimate the spectral noise power
            %%%% papers: "Unbiased MMSE-Based Noise Power Estimation with Low Complexity and Low Tracking Delay", IEEE TASL, 2012
            %%%% "Noise Power Estimation Based on the Probability of Speech Presence", Timo Gerkmann and Richard Hendriks, WASPAA 2011
            %%%% Input :        noisy:  noisy signal
            %%%    fs:  sampling frequency
            %%%%
            %%%% Output:  noisePowMat:  matrix with estimated noise power for each frame
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%% Copyright (c) 2011, Timo Gerkmann
            %%%%%%%%%%%%%%%%%%%%%% Author: Timo Gerkmann and Richard Hendriks
            %%%%%%%%%%%%%%%%%%%%%% Universitaet Oldenburg
            %%%%%%%%%%%%%%%%%%%%%% KTH Royal Institute of Technology
            %%%%%%%%%%%%%%%%%%%%%% Delft university of Technology
            %%%%%%%%%%%%%%%%%%%%%% Contact: timo.gerkmann@uni-oldenburg.de
            % All rights reserved.
            
            L=length(noisy);
            
            
            noisy_frame   = obj.anWin.*noisy;
            noisyDftFrame = fft(noisy_frame,L);
            noisyDftFrame = noisyDftFrame(1:L/2+1);
            
            noisyPer = noisyDftFrame.*conj(noisyDftFrame);
            snrPost1 =  noisyPer./(obj.noisePow);% a posteriori SNR based on old noise power estimate
            
            
            %% noise power estimation
            GLR     = obj.priorFact .* exp(min(obj.logGLRFact + obj.GLRexp.*snrPost1,200));
            PH1     = GLR./(1+GLR); % a posteriori speech presence probability
            
            obj.PH1mean  = obj.alphaPH1mean * obj.PH1mean + (1-obj.alphaPH1mean) * PH1;
            stuckInd = obj.PH1mean > 0.99;
            PH1(stuckInd) = min(PH1(stuckInd),0.99);
            estimate =  PH1 .* obj.noisePow + (1-PH1) .* noisyPer ;
            obj.noisePow = obj.alphaPSD *obj.noisePow+(1-obj.alphaPSD)*estimate;
            
            mat = obj.noisePow;
            
            
        end
    end
end
