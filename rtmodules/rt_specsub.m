


classdef rt_specsub < rt_manipulator
    properties
%         win
        nFFT
        noise_mu
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        
        function obj=rt_specsub(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Spectral subtraction';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            
            
            addParameter(pars,'Thres',3);
            addParameter(pars,'alpha',2);
            addParameter(pars,'FLOOR',0.002);
            addParameter(pars,'G',0.9);
            
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('Thres',pars.Results.Thres,'minvalue',0, 'maxvalue',10));
            add(obj.p,param_float_slider('alpha',pars.Results.alpha,'minvalue',0.1, 'maxvalue',3));
            add(obj.p,param_float_slider('FLOOR',pars.Results.FLOOR,'minvalue',0, 'maxvalue',0.1));
            add(obj.p,param_float_slider('G',pars.Results.G,'minvalue',0, 'maxvalue',1));
            
            
            obj.descriptor='Spectral subtraction: The implementation is from the book ''Speech enhancement'' by Phillipos Loizou, adapted for real time run (different calculation of initial conditions)\n More information: http://practicalcryptography.com/miscellaneous/machine-learning/tutorial-spectral-subraction/';
            
        end
        
        
        function post_init(obj) % called the second times around
%             Srate=obj.parent.SampleRate;
            len=obj.parent.FrameLength;
%             obj.win=hanning(len);
            obj.nFFT=2^nextpow2(len);
            noise_mean=0;
            
            % calulate the starting noise floor as a pink noise average
            pinknoise=dsp.ColoredNoise('Color','pink','SamplesPerFrame',len);
            for k=1:10
                x=step(pinknoise);
                noise_mean=noise_mean+abs(fft(x,obj.nFFT));
            end
            obj.noise_mu=noise_mean/10;
                     
            
            
            
            
            % =============== Initialize variables ===============
            %
            
            %             len=floor(20*Srate/1000); % Frame size in samples
            %             if rem(len,2)==1, len=len+1; end;
            %             PERC=50; % window overlap in percent of frame size
            %             len1=floor(len*PERC/100);
            %             len2=len-len1;
            
            
            %             Thres=3; % VAD threshold in dB SNRseg
            %             alpha=2.0; % power exponent
            %             FLOOR=0.002;
            %             G=0.9;
            
            %             Thres=getvalue(obj.p,'Thres');
            %             alpha=getvalue(obj.p,'alpha');
            %             FLOOR=getvalue(obj.p,'FLOOR');
            %             G=getvalue(obj.p,'G');
            %
            %             obj.win=hanning(len); %tukey(len,PERC);  % define window
            
            %             winGain=len2/sum(win); % normalization gain for overlap+add with 50% overlap
            %
            %             % Noise magnitude calculations - assuming that the first 5 frames is noise/silence
            %             %
            %             obj.nFFT=2*2^nextpow2(len);
            %             noise_mean=zeros(nFFT,1);
            %             j=1;
            %             for k=1:5
            %                 noise_mean=noise_mean+abs(fft(win.*x(j:j+len-1),nFFT));
            %                 j=j+len;
            %             end
            %             noise_mu=noise_mean/5;
            %             obj.noise_mu=0;
            %
            %             %--- allocate memory and initialize various variables
            %
            %             k=1;
            %             img=sqrt(-1);
            %             x_old=zeros(len1,1);
            %             Nframes=floor(length(x)/len2)-1;
            %             xfinal=zeros(Nframes*len2,1);
            
        end
        
        function enhanced=apply(obj,noisy)
            %             for n=1:Nframes
            Srate=obj.parent.SampleRate;
            len=obj.parent.FrameLength;
            
            Thres=getvalue(obj.p,'Thres');
            alpha=getvalue(obj.p,'alpha');
            FLOOR=getvalue(obj.p,'FLOOR');
            G=getvalue(obj.p,'G');
            
            %                 insign=win.*x(k:k+len-1);     %Windowing
            insign=noisy;
            
            spec=fft(insign,obj.nFFT);     %compute fourier transform of a frame
            sig=abs(spec); % compute the magnitude
            
            %save the noisy phase information
            theta=angle(spec);
            
            SNRseg=10*log10(norm(sig,2)^2/norm(obj.noise_mu,2)^2);
            
            if alpha==1.0
                beta=berouti1(SNRseg);
            else
                beta=berouti(SNRseg);
            end
            
            
            %&&&&&&&&&
            sub_speech=sig.^alpha - beta*obj.noise_mu.^alpha;
            diffw = sub_speech-FLOOR*obj.noise_mu.^alpha;
            
            % Floor negative components
            z=find(diffw <0);
            if~isempty(z)
                sub_speech(z)=FLOOR*obj.noise_mu(z).^alpha;
            end
            
            
            % --- implement a simple VAD detector --------------
            %
            if (SNRseg < Thres)   % Update noise spectrum
                noise_temp = G*obj.noise_mu.^alpha+(1-G)*sig.^alpha;
                obj.noise_mu=noise_temp.^(1/alpha);   % new noise spectrum
            end
            
            
            sub_speech(obj.nFFT/2+2:obj.nFFT)=flipud(sub_speech(2:obj.nFFT/2));  % to ensure conjugate symmetry for real reconstruction
            
            x_phase=(sub_speech.^(1/alpha)).*(cos(theta)+1i*(sin(theta)));
            
            
            % take the IFFT
            enhanced=real(ifft(x_phase));
            
            %
            %             % --- Overlap and add ---------------
            %             xfinal(k:k+len2-1)=x_old+xi(1:len1);
            %             x_old=xi(1+len1:len);
            %
            %
            %
            %             k=k+len2;
            %         end
            %========================================================================================
            
            
            
    end
    end
end



function a=berouti1(SNR)

if SNR>=-5.0 & SNR<=20
    a=3-SNR*2/20;
else
    
    if SNR<-5.0
        a=4;
    end
    
    if SNR>20
        a=1;
    end
    
end
end

function a=berouti(SNR)

if SNR>=-5.0 & SNR<=20
    a=4-SNR*3/20;
else
    
    if SNR<-5.0
        a=5;
    end
    
    if SNR>20
        a=1;
    end
    
end
end
